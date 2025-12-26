import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/data.dart';
import '../../../core/network/rag_api_client.dart';
import '../../../core/storage/local_prefs.dart';
import '../../../core/models/models.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final RagApiClient _ragClient;
  final LocalPrefs _prefs;
  final ResumeRepository _resumeRepository;

  ChatBloc({
    required RagApiClient ragClient,
    required LocalPrefs prefs,
    required ResumeRepository resumeRepository,
  })  : _ragClient = ragClient,
        _prefs = prefs,
        _resumeRepository = resumeRepository,
        super(const ChatState()) {
    on<LoadChatSettings>(_onLoadSettings);
    on<SendMessage>(_onSendMessage);
    on<ChangePersona>(_onChangePersona);
    on<ChangeMode>(_onChangeMode);
    on<ClearChat>(_onClearChat);
  }

  Future<void> _onLoadSettings(
      LoadChatSettings event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStateStatus.loading));
    try {
      final convId = await _prefs.getOrCreateConversationId();
      final persona = ChatPersona.fromString(_prefs.persona);
      final mode = ChatMode.fromString(_prefs.mode);
      final personalInfo = await _resumeRepository.getPersonalInfo();
      final availabilityStatus = AvailabilityStatus.fromString(
          personalInfo.availability ?? 'OPEN_FOR_WORK');
      emit(state.copyWith(
        status: ChatStateStatus.loaded,
        conversationId: convId,
        persona: persona,
        mode: mode,
        availability: availabilityStatus,
        suggestedPrompts: _getDefaultPrompts(persona),
      ));
    } catch (e) {
      emit(state.copyWith(
          status: ChatStateStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    final userMsg = ChatMessage.user(content: event.message);
    emit(state.copyWith(
        status: ChatStateStatus.sending,
        messages: [...state.messages, userMsg],
        suggestedPrompts: []));
    try {
      // Map persona to Python server format
      final personaValue = _mapPersonaToRagFormat(state.persona);

      final request = RagQueryRequest(
        question: event.message,
        persona: personaValue,
      );

      final response = await _ragClient.query(request);

      final aiMsg = ChatMessage.ai(
        content: response.answer,
        suggestedPrompts: _getFollowUpPrompts(state.persona),
      );

      emit(state.copyWith(
          status: ChatStateStatus.loaded,
          messages: [...state.messages, aiMsg],
          suggestedPrompts: _getFollowUpPrompts(state.persona)));
    } catch (e) {
      final errorMsg = ChatMessage.ai(
          content: 'Sorry, something went wrong. Please try again later.');
      emit(state.copyWith(
          status: ChatStateStatus.error,
          messages: [...state.messages, errorMsg],
          errorMessage: e.toString()));
    }
  }

  /// Maps ChatPersona enum to Python RAG server persona format
  String _mapPersonaToRagFormat(ChatPersona persona) {
    switch (persona) {
      case ChatPersona.hr:
        return 'hr';
      case ChatPersona.techLead:
        return 'peer'; // Tech lead maps to peer
      case ChatPersona.founder:
        return 'founder';
      case ChatPersona.peerDev:
        return 'peer';
    }
  }

  /// Get follow-up prompts based on current persona
  List<String> _getFollowUpPrompts(ChatPersona persona) {
    switch (persona) {
      case ChatPersona.hr:
        return [
          'Which role are you hiring for (Flutter lead, Generative AI engineer, or a hybrid), and what level of ownership do you expect?',
          'Do you want more emphasis on my fintech/mobile banking work (AeonPay, HDFC Securities, BHIM UPI) or my AI/agentic projects (MCP, A2A, Google ADK, n8n automation)?',
          'What timeline and work model are you targeting (immediate join, notice period flexibility, remote/hybrid/on-site)?'
        ];

      case ChatPersona.techLead:
        return [
          'Do you want a deep dive on my Flutter architecture choices (SOLID + BLoC, modularization, navigation) or on security (ECDH, HMAC derivation, AES-GCM)?',
          'Should I walk through an end-to-end onboarding flow implementation (document capture, OCR extraction, liveness, face match) and how it integrates with backend APIs (gRPC/FastAPI)?',
          'What are your expectations around documentation, code analysis, and best practices?'
        ];

      case ChatPersona.founder:
        return [
          'What’s the biggest business outcome you want to move first—activation/onboarding conversion, fraud reduction, automation cost savings, or faster releases?',
          'Are you more interested in my 0-to-1 fintech platform experience (leading AeonPay from inception) or in applying agentic automation (multi-agent systems, n8n workflows) to accelerate your team?',
          'What constraints matter most right now—time-to-market, security/compliance, budget, or platform scope (iOS/Android/Web/Desktop)?'
        ];

      case ChatPersona.peerDev:
        return [
          'What kind of Flutter app are you building—fintech, onboarding/identity, or something else—and which state management style are you using (BLoC, GetX, MVVM)?',
          'Are you facing performance issues (jank, rebuilds, isolates), native integration needs (platform channels/federated plugins), or API/security challenges (gRPC, encryption)?',
          'Do you want tips mainly on Flutter architecture and debugging, or on agentic automation and LLM workflows (n8n, LangChain, MCP/A2A)?'
        ];
    }
  }

  Future<void> _onChangePersona(
      ChangePersona event, Emitter<ChatState> emit) async {
    await _prefs.setPersona(event.persona.value);
    emit(state.copyWith(
        persona: event.persona,
        suggestedPrompts: _getDefaultPrompts(event.persona)));
  }

  Future<void> _onChangeMode(ChangeMode event, Emitter<ChatState> emit) async {
    await _prefs.setMode(event.mode.value);
    emit(state.copyWith(mode: event.mode));
  }

  Future<void> _onClearChat(ClearChat event, Emitter<ChatState> emit) async {
    final newConvId = _prefs.generateConversationId();
    await _prefs.setConversationId(newConvId);
    emit(state.copyWith(
        messages: [],
        conversationId: newConvId,
        suggestedPrompts: _getDefaultPrompts(state.persona)));
  }

  List<String> _getDefaultPrompts(ChatPersona persona) {
    switch (persona) {
      case ChatPersona.hr:
        return [
          'Could you summarize your 7 years of experience in Flutter and Generative AI?',
          'Have you led teams or mentored developers in AI-powered mobile app projects?',
          'Are you open to hybrid or remote roles within fintech or emerging tech domains?',
          'What certifications or hackathon achievements are you most proud of?',
          'What are your expected career growth goals for the next 2 years?'
        ];

      case ChatPersona.techLead:
        return [
          'Describe how you architected the AeonPay mobile banking app using SOLID and BLoC principles.',
          'How do you ensure security in Flutter apps — any experience with ECDH, AES-GCM, or HMAC key derivation?',
          'Can you walk through your multi-platform Flutter deployment?',
          'Tell me about integrating AI agents or LLM pipelines within Flutter workflows.',
          'How do you structure communication between Flutter and backend APIs like gRPC or FastAPI?'
        ];

      case ChatPersona.founder:
        return [
          'Have you built or architected 0-to-1 products using AI or automation?',
          'How did you use Generative AI and multi-agent systems to accelerate engineering cycles?',
          'Explain your experience in reducing onboarding time and improving conversion in fintech apps.',
          'What’s your approach to balancing innovation, reliability, and release velocity?',
          'Could your n8n-based automation workflows be extended into a full SaaS product?'
        ];

      case ChatPersona.peerDev:
        return [
          'Which Flutter design patterns do you prefer — BLoC, MVVM, or Provider — and why?',
          'What’s your workflow for debugging complex widget rebuilds or async issues?',
          'Share how you’ve blended n8n automation with Flutter or backend workflows.',
          'What’s your approach to testing AI-integrated or asynchronous modules in Flutter?',
          'Any favorite community libraries, plugins, or productivity tools for AI or UI work?'
        ];
    }
  }
}
