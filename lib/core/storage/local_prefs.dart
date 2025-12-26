import 'package:shared_preferences/shared_preferences.dart';

/// Keys for local storage
class PrefsKeys {
  PrefsKeys._();

  static const String persona = 'chat_persona';
  static const String mode = 'chat_mode';
  static const String conversationId = 'conversation_id';
  static const String lastAvailability = 'last_availability';
}

/// Local storage wrapper using SharedPreferences
class LocalPrefs {
  final SharedPreferences _prefs;

  LocalPrefs(this._prefs);

  /// Create instance asynchronously
  static Future<LocalPrefs> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalPrefs(prefs);
  }

  // Persona
  String get persona => _prefs.getString(PrefsKeys.persona) ?? 'HR';
  Future<bool> setPersona(String value) =>
      _prefs.setString(PrefsKeys.persona, value);

  // Mode (RAG/CAG)
  String get mode => _prefs.getString(PrefsKeys.mode) ?? 'RAG';
  Future<bool> setMode(String value) => _prefs.setString(PrefsKeys.mode, value);

  // Conversation ID
  String? get conversationId => _prefs.getString(PrefsKeys.conversationId);
  Future<bool> setConversationId(String value) =>
      _prefs.setString(PrefsKeys.conversationId, value);
  Future<bool> clearConversationId() => _prefs.remove(PrefsKeys.conversationId);

  // Last availability status (for caching/fallback)
  String get lastAvailability =>
      _prefs.getString(PrefsKeys.lastAvailability) ?? 'OPEN_FOR_WORK';
  Future<bool> setLastAvailability(String value) =>
      _prefs.setString(PrefsKeys.lastAvailability, value);

  /// Generate a new conversation ID
  String generateConversationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 10000;
    return 'conv_${timestamp}_$random';
  }

  /// Get or create conversation ID
  Future<String> getOrCreateConversationId() async {
    var id = conversationId;
    if (id == null || id.isEmpty) {
      id = generateConversationId();
      await setConversationId(id);
    }
    return id;
  }

  /// Clear all preferences
  Future<bool> clearAll() => _prefs.clear();
}
