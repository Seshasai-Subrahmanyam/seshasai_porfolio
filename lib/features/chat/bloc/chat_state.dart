import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';

enum ChatStateStatus { initial, loading, loaded, sending, error }

class ChatState extends Equatable {
  final ChatStateStatus status;
  final List<ChatMessage> messages;
  final ChatPersona persona;
  final ChatMode mode;
  final String conversationId;
  final AvailabilityStatus availability;
  final String? errorMessage;
  final List<String> suggestedPrompts;

  const ChatState({
    this.status = ChatStateStatus.initial,
    this.messages = const [],
    this.persona = ChatPersona.hr,
    this.mode = ChatMode.rag,
    this.conversationId = '',
    this.availability = AvailabilityStatus.openForWork,
    this.errorMessage,
    this.suggestedPrompts = const [],
  });

  ChatState copyWith({
    ChatStateStatus? status,
    List<ChatMessage>? messages,
    ChatPersona? persona,
    ChatMode? mode,
    String? conversationId,
    AvailabilityStatus? availability,
    String? errorMessage,
    List<String>? suggestedPrompts,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      persona: persona ?? this.persona,
      mode: mode ?? this.mode,
      conversationId: conversationId ?? this.conversationId,
      availability: availability ?? this.availability,
      errorMessage: errorMessage,
      suggestedPrompts: suggestedPrompts ?? this.suggestedPrompts,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        persona,
        mode,
        conversationId,
        availability,
        errorMessage,
        suggestedPrompts
      ];
}
