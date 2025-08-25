// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../chat/bloc/chat_bloc.dart';
import '../../../chat/bloc/chat_state.dart';
import '../../../../core/models/message_model.dart';
import 'streaming_indicator.dart';

class ChatMessagesListWidget extends StatelessWidget {
  const ChatMessagesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        List<MessageModel> messages = [];
        bool isLoading = false;
        
        if (state is MessageSending || state is MessageSent || state is MessageStreaming || state is MessageStreamComplete) {
          final chatBloc = context.read<ChatBloc>();
          messages = chatBloc.messages;
          isLoading = state is MessageSending;
          
          // Handle streaming content
          if (state is MessageStreaming) {
            // Add a temporary streaming message
            messages = [...messages];
            if (state.currentStreamContent.isNotEmpty) {
              final streamingMessage = MessageModel(
                id: 'streaming',
                chatId: 'current',
                content: state.currentStreamContent + '█', // Add blinking cursor
                role: 'assistant',
                createdAt: DateTime.now(),
              );
              messages.add(streamingMessage);
            } else {
              // Show initial typing indicator
              final typingMessage = MessageModel(
                id: 'typing',
                chatId: 'current',
                content: '•••',
                role: 'assistant',
                createdAt: DateTime.now(),
              );
              messages.add(typingMessage);
            }
            isLoading = false; // Don't show loading spinner during streaming
          }
        } else if (state is ChatLoading) {
          isLoading = true;
        } else if (state is ChatError) {
          // Show existing messages even on error
          final chatBloc = context.read<ChatBloc>();
          messages = chatBloc.messages;
        }

        if (messages.isEmpty && !isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Start a conversation',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 72),
          itemCount: messages.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (isLoading && index == 0) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: const SizedBox(
                    width: 40,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              );
            }

            final messageIndex = isLoading ? index - 1 : index;
            final message = messages[messages.length - 1 - messageIndex];
            final isUser = message.isUser;

            final mdStyle = MarkdownStyleSheet(
              p: const TextStyle(color: Colors.white, height: 1.5),
              listBullet: const TextStyle(color: Colors.white),
              h1: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              h3: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              code: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
            );

            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blueAccent : Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: message.id == 'streaming'
                    ? StreamingIndicator(
                        isStreaming: true,
                        text: message.content.replaceAll('█', ''),
                      )
                    : MarkdownBody(
                        data: message.content,
                        styleSheet: mdStyle,
                        softLineBreak: true,
                        shrinkWrap: true,
                        extensionSet: md.ExtensionSet.gitHubWeb,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
