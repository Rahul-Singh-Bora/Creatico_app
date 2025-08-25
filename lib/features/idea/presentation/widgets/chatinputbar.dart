// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../chat/bloc/chat_bloc.dart';
import '../../../chat/bloc/chat_event.dart';
import '../../../chat/bloc/chat_state.dart';
import '../../../../core/services/provider_service.dart';
import '../../../../core/models/api_provider_model.dart';
import '../../../settings/widgets/api_key_settings.dart';

class ChatInputBarWidget extends StatefulWidget {
  final VoidCallback onPlatformTap;
  final VoidCallback onVoiceTap;
  final String? selectedProviderName;
  final String? selectedProviderId;

  const ChatInputBarWidget({
    super.key,
    required this.onPlatformTap,
    required this.onVoiceTap,
    this.selectedProviderName,
    this.selectedProviderId,
  });

  @override
  State<ChatInputBarWidget> createState() => _ChatInputBarWidgetState();
}

class _ChatInputBarWidgetState extends State<ChatInputBarWidget> {
  final TextEditingController _controller = TextEditingController();
  
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final bloc = context.read<ChatBloc>();

    // Demo bypass: if the prompt matches the demo phrase, stream locally without any provider or API key
    const demoPrompt = 'give me some content ideas to post in youtube';
    if (text.toLowerCase() == demoPrompt) {
      bloc.add(
        SendStreamingMessage(
          message: text,
          providerId: 'demo', // not used in demo path
        ),
      );
      _controller.clear();
      return;
    }

    // Find an active provider to use
    final providerService = ProviderService();
    final List<ApiProviderModel> activeProviders = await providerService.getActiveProviders();

    if (!mounted) return;

    if (activeProviders.isEmpty) {
      _showApiKeyDialog();
      return;
    }

    final providerIdToUse = widget.selectedProviderId ?? (activeProviders.isNotEmpty ? activeProviders.first.id : null);

    if (providerIdToUse == null) {
      _showApiKeyDialog();
      return;
    }

    // Use streaming messages with fallback
    bloc.add(
      SendStreamingMessage(
        message: text,
        providerId: providerIdToUse,
      ),
    );
    
    _controller.clear();
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'API Key Required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Please configure an API Provider and API key to continue.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ApiKeySettings(),
                ),
              );
            },
            child: const Text(
              'Configure Keys',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final isLoading = state is MessageSending || state is MessageStreaming;
        
        // Show error if any
        if (state is ChatError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.black,
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onPlatformTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (widget.selectedProviderName ?? 'AUTO').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (state is MessageStreaming) ...[
                        const SizedBox(width: 4),
                        const SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !isLoading,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.mic, color: Colors.white),
                onPressed: isLoading ? null : widget.onVoiceTap,
              ),
              IconButton(
                icon: isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: isLoading ? null : _sendMessage,
              ),
            ],
          ),
        );
      },
    );
  }
}
