// ignore_for_file: deprecated_member_use

import 'package:creatico/shared/widgets/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../chat/bloc/chat_bloc.dart';
import '../../../chat/bloc/chat_event.dart';
import '../../../chat/bloc/chat_state.dart';
import '../../../../core/models/chat_model.dart';
import '../../../settings/widgets/api_key_settings.dart';
import '../../../debug/debug_screen.dart';
import 'package:intl/intl.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    super.initState();
    // Load chat history when drawer is opened
    // For now, we'll manage local chat history until backend is ready
    _loadLocalHistory();
  }
  
  void _loadLocalHistory() {
    // Load local chat history
    context.read<ChatBloc>().add(LoadLocalChatHistory());
  }

  void _createNewChat() {
    // Create new local chat (saves current chat to history if it has messages)
    context.read<ChatBloc>().add(CreateLocalChat());
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: <Widget>[
          // Search header
          const DrawerHeaderWithSearch(),

          // New Chat button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createNewChat,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('New Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Chat History
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (state is ChatError) {
                  return Center(
                    child: Text(
                      'Error loading history: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final chatBloc = context.read<ChatBloc>();
                List<ChatModel> chatHistory = [];
                
                if (state is ChatHistoryLoaded) {
                  chatHistory = state.history;
                } else {
                  chatHistory = chatBloc.chatHistory;
                }
                
                // Add current chat to the list if it has messages
                final currentChatTitle = chatBloc.hasMessages ? chatBloc.currentChatTitle : null;
                
                // Show empty state like ChatGPT
                if (chatHistory.isEmpty && currentChatTitle == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No chats found',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Calculate total items (current chat + history)
                final totalItems = (currentChatTitle != null ? 1 : 0) + chatHistory.length;
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemCount: totalItems,
                  itemBuilder: (context, index) {
                    // First item is current chat if it exists
                    if (currentChatTitle != null && index == 0) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[800]?.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Icon(
                            Icons.chat_bubble,
                            color: Colors.orangeAccent,
                            size: 18,
                          ),
                          title: Text(
                            currentChatTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: const Text(
                            'Current chat',
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 11.0,
                            ),
                          ),
                          trailing: Icon(
                            Icons.more_horiz,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                        ),
                      );
                    }
                    
                    // Adjust index for history items
                    final historyIndex = currentChatTitle != null ? index - 1 : index;
                    final chat = chatHistory[historyIndex];
                    final date = DateFormat('MMM dd').format(chat.createdAt);
                    final isToday = DateTime.now().difference(chat.createdAt).inDays == 0;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 1.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                        title: Text(
                          chat.title,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          isToday ? 'Today' : date,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11.0,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_horiz,
                            color: Colors.grey[500],
                            size: 16,
                          ),
                          color: Colors.grey[800],
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red[400], size: 16),
                                  const SizedBox(width: 8),
                                  const Text('Delete', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                             
                            }
                          },
                        ),
                        onTap: () {
                        
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Horizontal Divider
          const Divider(
            color: Colors.white12,
            height: 1,
          ),

          // Settings section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ListTile(
              leading: const Icon(Icons.key, color: Colors.orangeAccent),
              title: const Text(
                'API Key Settings',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ApiKeySettings(),
                  ),
                );
              },
            ),
          ),

          // Debug section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.redAccent),
              title: const Text(
                'Debug API',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DebugScreen(),
                  ),
                );
              },
            ),
          ),

          const Divider(
            color: Colors.white12,
            height: 1,
          ),

          // User Profile Section at the bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blue, // Placeholder for the profile picture
                  child: Text('R', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12.0),
                const Text(
                  'Rahul singh',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}