import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeySettings extends StatefulWidget {
  const ApiKeySettings({super.key});

  @override
  State<ApiKeySettings> createState() => _ApiKeySettingsState();
}

class _ApiKeySettingsState extends State<ApiKeySettings> {
  final _storage = const FlutterSecureStorage();
  final Map<String, TextEditingController> _controllers = {
    'grok': TextEditingController(),
    'openai': TextEditingController(),
    'anthropic': TextEditingController(),
  };
  
  final Map<String, bool> _isEditing = {
    'grok': false,
    'openai': false,
    'anthropic': false,
  };

  final Map<String, String> _providers = {
    'grok': 'Grok (X.AI)',
    'openai': 'OpenAI',
    'anthropic': 'Anthropic',
  };

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    for (final provider in _controllers.keys) {
      final key = await _storage.read(key: '${provider}_api_key');
      if (key != null && key.isNotEmpty) {
        // Show that key exists but don't show actual value
        _controllers[provider]!.text = '';
      }
    }
  }

  Future<bool> _hasApiKey(String provider) async {
    final key = await _storage.read(key: '${provider}_api_key');
    return key != null && key.isNotEmpty;
  }

  Future<void> _saveApiKey(String provider, String apiKey) async {
    if (apiKey.trim().isNotEmpty) {
      await _storage.write(key: '${provider}_api_key', value: apiKey.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_providers[provider]} API key saved successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          _isEditing[provider] = false;
          _controllers[provider]!.clear();
        });
      }
    }
  }

  Future<void> _clearApiKey(String provider) async {
    await _storage.delete(key: '${provider}_api_key');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_providers[provider]} API key removed'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _controllers[provider]!.clear();
        _isEditing[provider] = false;
      });
    }
  }

  Widget _buildApiKeyCard(String provider, String name) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder<bool>(
                  future: _hasApiKey(provider),
                  builder: (context, snapshot) {
                    final hasKey = snapshot.data == true;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasKey)
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                        if (hasKey) const SizedBox(width: 4),
                        Text(
                          hasKey ? 'Configured' : 'Not configured',
                          style: TextStyle(
                            color: hasKey ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controllers[provider],
              style: const TextStyle(color: Colors.white),
              enableInteractiveSelection: true, // Enable copy/paste
              canRequestFocus: true,
              decoration: InputDecoration(
                hintText: 'Paste your $name API key here',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orangeAccent, width: 1),
                ),
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.paste, color: Colors.grey),
                      onPressed: () async {
                        final clipboardData = await Clipboard.getData('text/plain');
                        if (clipboardData?.text != null) {
                          _controllers[provider]!.text = clipboardData!.text!;
                        }
                      },
                      tooltip: 'Paste from clipboard',
                    ),
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.orangeAccent),
                      onPressed: () => _saveApiKey(provider, _controllers[provider]!.text),
                      tooltip: 'Save API key',
                    ),
                  ],
                ),
              ),
              validator: null, // No validation to prevent floating messages
              autovalidateMode: AutovalidateMode.disabled, // Disable auto validation
              onFieldSubmitted: (value) => _saveApiKey(provider, value),
            ),
            const SizedBox(height: 8),
            FutureBuilder<bool>(
              future: _hasApiKey(provider),
              builder: (context, snapshot) {
                final hasKey = snapshot.data == true;
                if (hasKey) {
                  return Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _clearApiKey(provider),
                        icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                        label: const Text(
                          'Remove Key',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('API Key Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure your AI provider API keys',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your API keys are stored securely on your device and used only to make requests to the respective AI services.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: _providers.entries.map((entry) {
                  final provider = entry.key;
                  final name = entry.value;
                  return _buildApiKeyCard(provider, name);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
