// lib/core/services/provider_service.dart

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../configs/api_client.dart';
import '../configs/api_endpoints.dart';
import '../models/api_provider_model.dart';

class ProviderService {
  final ApiClient _apiClient = ApiClient();
  static const _storage = FlutterSecureStorage();
  static const _storageKey = 'cached_providers';

  // Get all providers from the backend
  Future<List<ApiProviderModel>> getProviders() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.providers);
      final providers = (response['providers'] as List)
          .map((providerJson) => ApiProviderModel.fromJson(providerJson))
          .toList();
      
      // Cache providers locally
      await _cacheProviders(providers);
      
      return providers;
    } catch (e) {
      print('Failed to fetch providers from backend: $e');
      
      // Fallback to cached providers
      return await _getCachedProviders();
    }
  }

  // Get a specific provider
  Future<ApiProviderModel?> getProvider(String providerId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.providers}/$providerId');
      return ApiProviderModel.fromJson(response['provider']);
    } catch (e) {
      print('Failed to fetch provider $providerId: $e');
      
      // Fallback to cached provider
      final cachedProviders = await _getCachedProviders();
      return cachedProviders.firstWhere(
        (p) => p.id == providerId,
        orElse: () => throw Exception('Provider not found'),
      );
    }
  }

  // Create a new provider
  Future<ApiProviderModel> createProvider({
    required String name,
    required String baseUrl,
    required String apiKey,
    String? model,
    RequestConfigModel? requestConfig,
    ResponseConfigModel? responseConfig,
    StreamingConfigModel? streamingConfig,
    Map<String, String>? headers,
  }) async {
    final body = {
      'name': name,
      'baseUrl': baseUrl,
      'apiKey': apiKey,
      'model': model,
      'requestConfig': requestConfig?.toJson(),
      'responseConfig': responseConfig?.toJson(),
      'streamingConfig': streamingConfig?.toJson(),
      'headers': headers,
    };

    final response = await _apiClient.post(ApiEndpoints.providers, body);
    final provider = ApiProviderModel.fromJson(response['provider']);
    
    // Update cache
    await _updateCachedProvider(provider);
    
    return provider;
  }

  // Update an existing provider
  Future<ApiProviderModel> updateProvider(
    String providerId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.providers}/$providerId',
      updates,
    );
    final provider = ApiProviderModel.fromJson(response['provider']);
    
    // Update cache
    await _updateCachedProvider(provider);
    
    return provider;
  }

  // Delete a provider
  Future<void> deleteProvider(String providerId) async {
    await _apiClient.delete('${ApiEndpoints.providers}/$providerId');
    
    // Remove from cache
    await _removeCachedProvider(providerId);
  }

  // Create a provider from a template
  Future<ApiProviderModel> createFromTemplate(
    String templateKey,
    String apiKey, {
    String? name,
    String? model,
  }) async {
    final template = ProviderTemplates.templates[templateKey];
    if (template == null) {
      throw Exception('Template $templateKey not found');
    }

    return await createProvider(
      name: name ?? template['name'],
      baseUrl: template['baseUrl'],
      apiKey: apiKey,
      model: model ?? template['model'],
      requestConfig: RequestConfigModel.fromJson(
        Map<String, dynamic>.from(template['requestConfig']),
      ),
      responseConfig: ResponseConfigModel.fromJson(
        Map<String, dynamic>.from(template['responseConfig']),
      ),
      streamingConfig: template['streamingConfig'] != null
          ? StreamingConfigModel.fromJson(
              Map<String, dynamic>.from(template['streamingConfig']),
            )
          : null,
    );
  }

  // Get active providers (with API keys)
  Future<List<ApiProviderModel>> getActiveProviders() async {
    final providers = await getProviders();
    return providers.where((p) => p.isActive && p.apiKey.isNotEmpty).toList();
  }

  // Test a provider configuration
  Future<bool> testProvider(String providerId) async {
    try {
      // Make a simple test request to the provider
      await _apiClient.post(
        ApiEndpoints.generateMessageStream,
        {
          'content': 'Hello, this is a test message.',
          'providerId': providerId,
          'temperature': 0.7,
          'maxTokens': 50,
        },
      );
      return true;
    } catch (e) {
      print('Provider test failed: $e');
      return false;
    }
  }

  // Cache management
  Future<void> _cacheProviders(List<ApiProviderModel> providers) async {
    final providersJson = providers.map((p) => p.toJson()).toList();
    await _storage.write(
      key: _storageKey,
      value: jsonEncode(providersJson),
    );
  }

  Future<List<ApiProviderModel>> _getCachedProviders() async {
    try {
      final cachedData = await _storage.read(key: _storageKey);
      if (cachedData == null) return [];
      
      final providersJson = jsonDecode(cachedData) as List;
      return providersJson
          .map((json) => ApiProviderModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Failed to read cached providers: $e');
      return [];
    }
  }

  Future<void> _updateCachedProvider(ApiProviderModel provider) async {
    final cachedProviders = await _getCachedProviders();
    final index = cachedProviders.indexWhere((p) => p.id == provider.id);
    
    if (index >= 0) {
      cachedProviders[index] = provider;
    } else {
      cachedProviders.add(provider);
    }
    
    await _cacheProviders(cachedProviders);
  }

  Future<void> _removeCachedProvider(String providerId) async {
    final cachedProviders = await _getCachedProviders();
    cachedProviders.removeWhere((p) => p.id == providerId);
    await _cacheProviders(cachedProviders);
  }

  // Clear all cached data
  Future<void> clearCache() async {
    await _storage.delete(key: _storageKey);
  }
}
