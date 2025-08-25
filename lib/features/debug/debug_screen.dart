import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/services/provider_service.dart';
import '../../core/models/api_provider_model.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final ApiService _apiService = ApiService();
  String _result = '';
  bool _isLoading = false;

  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing API...';
    });

    try {
      // Fetch active providers and pick the first one
      final ProviderService providerService = ProviderService();
      final List<ApiProviderModel> activeProviders = await providerService.getActiveProviders();

      if (activeProviders.isEmpty) {
        setState(() {
          _result += '\n\nError: No active providers with API keys configured. Please add one in Providers.';
          _isLoading = false;
        });
        return;
      }

      final provider = activeProviders.first;
      setState(() {
        _result += '\n\nUsing provider:';
        _result += '\n- Name: ${provider.name}';
        _result += '\n- Model: ${provider.model ?? "(default)"}';
      });

      setState(() {
        _result += '\n\nSending test message to backend...';
      });

      final response = await _apiService.generateMessage(
        message: 'Hello, this is a test message.',
        providerId: provider.id,
      );

      setState(() {
        _result += '\n\nSuccess! Response received:';
        _result += '\n$response';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result += '\n\nError occurred:';
        _result += '\n$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Debug API', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API Connection Test',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testApi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
              ),
              child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Test API Call'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Result:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty ? 'No result yet. Click "Test API Call" to begin.' : _result,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
