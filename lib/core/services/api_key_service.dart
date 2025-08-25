import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyService {
  static const _storage = FlutterSecureStorage();

  // Get API key for a specific provider
  static Future<String?> getApiKey(String provider) async {
    return await _storage.read(key: '${provider}_api_key');
  }

  // Save API key for a specific provider
  static Future<void> saveApiKey(String provider, String apiKey) async {
    await _storage.write(key: '${provider}_api_key', value: apiKey);
  }

  // Check if API key exists for a provider
  static Future<bool> hasApiKey(String provider) async {
    final key = await getApiKey(provider);
    return key != null && key.isNotEmpty;
  }

  // Get all configured API keys (legacy method)
  static Future<Map<String, String>> getAllApiKeys() async {
    final providers = ['grok', 'openai', 'anthropic'];
    final Map<String, String> apiKeys = {};
    
    for (final provider in providers) {
      final key = await getApiKey(provider);
      if (key != null && key.isNotEmpty) {
        apiKeys[provider] = key;
      }
    }
    
    return apiKeys;
  }

  // Remove API key for a specific provider
  static Future<void> removeApiKey(String provider) async {
    await _storage.delete(key: '${provider}_api_key');
  }

  // Clear all API keys (legacy method)
  static Future<void> clearAllApiKeys() async {
    final providers = ['grok', 'openai', 'anthropic'];
    for (final provider in providers) {
      await removeApiKey(provider);
    }
  }

  // Migration helper: Get legacy API keys for migration to new provider system
  static Future<Map<String, String>> getLegacyApiKeysForMigration() async {
    return await getAllApiKeys();
  }
}
