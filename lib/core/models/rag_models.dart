import 'package:equatable/equatable.dart';

/// RAG query request model matching Python server API
class RagQueryRequest extends Equatable {
  /// The question to ask about the resume
  final String question;

  /// Persona: 'hr', 'peer', 'founder', or 'default'
  final String persona;

  const RagQueryRequest({
    required this.question,
    this.persona = 'default',
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'persona': persona,
      };

  @override
  List<Object?> get props => [question, persona];
}

/// RAG query response model matching Python server API
class RagQueryResponse extends Equatable {
  /// The answer from the RAG system
  final String answer;

  /// The persona used for the response
  final String persona;

  /// Number of source documents used
  final int sourcesCount;

  const RagQueryResponse({
    required this.answer,
    required this.persona,
    required this.sourcesCount,
  });

  factory RagQueryResponse.fromJson(Map<String, dynamic> json) {
    return RagQueryResponse(
      answer: json['answer'] as String? ?? '',
      persona: json['persona'] as String? ?? 'default',
      sourcesCount: json['sources_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [answer, persona, sourcesCount];
}

/// Health check response from RAG server
class RagHealthResponse extends Equatable {
  final String status;
  final String message;

  const RagHealthResponse({
    required this.status,
    required this.message,
  });

  factory RagHealthResponse.fromJson(Map<String, dynamic> json) {
    return RagHealthResponse(
      status: json['status'] as String? ?? 'unknown',
      message: json['message'] as String? ?? '',
    );
  }

  bool get isHealthy => status == 'healthy' || status == 'ok';

  @override
  List<Object?> get props => [status, message];
}

/// Rebuild response from RAG server
class RagRebuildResponse extends Equatable {
  final String status;
  final int documentsIndexed;

  const RagRebuildResponse({
    required this.status,
    required this.documentsIndexed,
  });

  factory RagRebuildResponse.fromJson(Map<String, dynamic> json) {
    return RagRebuildResponse(
      status: json['status'] as String? ?? 'unknown',
      documentsIndexed: json['documents_indexed'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [status, documentsIndexed];
}
