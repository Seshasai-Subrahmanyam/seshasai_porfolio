/// Environment configuration for the portfolio application.
///
/// Reads compile-time defines for API URLs.
/// Usage: flutter run --dart-define=RAG_SERVER_URL=http://localhost:8000
class Env {
  Env._();

  /// Local RAG server URL for chat functionality
  static const String ragServerUrl = String.fromEnvironment('RAG_SERVER_URL',
      defaultValue:
          "https://resume-rag-fastapi.onrender.com" //'http://localhost:8000',
      );

  /// Make.com webhook URL for availability status
  static const String makeAvailabilityUrl = String.fromEnvironment(
    'MAKE_AVAILABILITY_URL',
    defaultValue: '',
  );

  /// Make.com webhook URL for project story generation
  static const String makeProjectStoryUrl = String.fromEnvironment(
    'MAKE_PROJECT_STORY_URL',
    defaultValue: '',
  );

  /// Whether to use local fallback data when webhooks are not configured
  static bool get useLocalFallback => makeAvailabilityUrl.isEmpty;

  /// Base timeout for API requests in seconds
  static const int apiTimeoutSeconds = 30;
}
