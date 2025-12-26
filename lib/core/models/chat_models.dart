import 'package:equatable/equatable.dart';

/// Persona types for chat
enum ChatPersona {
  hr('HR'),
  techLead('TECH_LEAD'),
  founder('FOUNDER'),
  peerDev('PEER_DEV');

  final String value;
  const ChatPersona(this.value);

  static ChatPersona fromString(String value) {
    return ChatPersona.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChatPersona.hr,
    );
  }

  String get displayName {
    switch (this) {
      case ChatPersona.hr:
        return 'HR Recruiter';
      case ChatPersona.techLead:
        return 'Tech Lead';
      case ChatPersona.founder:
        return 'Founder / CEO';
      case ChatPersona.peerDev:
        return 'Peer Developer';
    }
  }

  // String get icon {
  //   switch (this) {
  //     case ChatPersona.hr:
  //       return '👔';
  //     case ChatPersona.techLead:
  //       return '🔧';
  //     case ChatPersona.founder:
  //       return '🚀';
  //     case ChatPersona.peerDev:
  //       return '💻';
  //   }
  // }
}

/// Chat mode (RAG vs CAG)
enum ChatMode {
  rag('RAG');
  // cag('CAG');

  final String value;
  const ChatMode(this.value);

  static ChatMode fromString(String value) {
    return ChatMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChatMode.rag,
    );
  }

  String get displayName {
    switch (this) {
      case ChatMode.rag:
        return 'RAG (Retrieval)';
      // case ChatMode.cag:
      //   return 'CAG (Conversational)';
    }
  }

  String get description {
    switch (this) {
      case ChatMode.rag:
        return 'Retrieves specific resume sections for accurate answers';
      // case ChatMode.cag:
      //   return 'Natural conversation with context awareness';
    }
  }
}

/// CTA importance level
enum CtaImportance {
  low,
  medium,
  high;

  static CtaImportance fromString(String value) {
    return CtaImportance.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => CtaImportance.low,
    );
  }
}

/// Chat message (user or AI)
class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestedPrompts;
  final ChatCta? cta;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.suggestedPrompts,
    this.cta,
  });

  factory ChatMessage.user({
    required String content,
  }) {
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.ai({
    required String content,
    List<String>? suggestedPrompts,
    ChatCta? cta,
  }) {
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      suggestedPrompts: suggestedPrompts,
      cta: cta,
    );
  }

  @override
  List<Object?> get props =>
      [id, content, isUser, timestamp, suggestedPrompts, cta];
}

/// Call to action in chat response
class ChatCta extends Equatable {
  final String label;
  final CtaImportance importance;

  const ChatCta({
    required this.label,
    required this.importance,
  });

  factory ChatCta.fromJson(Map<String, dynamic> json) {
    return ChatCta(
      label: json['label'] as String? ?? '',
      importance:
          CtaImportance.fromString(json['importance'] as String? ?? 'low'),
    );
  }

  @override
  List<Object?> get props => [label, importance];
}

/// Chat request to Make.com
class ChatRequest extends Equatable {
  final String section = 'chat';
  final String persona;
  final String mode;
  final String availability;
  final String conversationId;
  final String userQuery;

  const ChatRequest({
    required this.persona,
    required this.mode,
    required this.availability,
    required this.conversationId,
    required this.userQuery,
  });

  Map<String, dynamic> toJson() => {
        'section': section,
        'persona': persona,
        'mode': mode,
        'availability': availability,
        'conversation_id': conversationId,
        'user_query': userQuery,
      };

  @override
  List<Object?> get props =>
      [persona, mode, availability, conversationId, userQuery];
}

/// Chat response from Make.com
class ChatResponse extends Equatable {
  final String answerMarkdown;
  final List<String> suggestedPrompts;
  final ChatCta? cta;

  const ChatResponse({
    required this.answerMarkdown,
    required this.suggestedPrompts,
    this.cta,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      answerMarkdown: json['answer_markdown'] as String? ?? '',
      suggestedPrompts: (json['suggested_prompts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      cta: json['cta'] != null
          ? ChatCta.fromJson(json['cta'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [answerMarkdown, suggestedPrompts, cta];
}
