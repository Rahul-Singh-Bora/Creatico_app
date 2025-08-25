// ignore_for_file: avoid_print, prefer_is_empty, use_rethrow_when_possible

import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../data/repositories/chat_repository.dart';
import '../../../core/models/chat_model.dart';
import '../../../core/models/message_model.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  final List<MessageModel> _messages = [];
  List<ChatModel> _chatHistory = [];
  String _currentStreamingContent = '';
  String? _currentChatId;
  String _currentChatTitle = 'New Chat';

  ChatBloc(this.repository) : super(ChatInitial()) {
    on<LoadChats>((event, emit) async {
      emit(ChatLoading());
      try {
        final chats = await repository.getChats();
        emit(ChatsLoaded(chats));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });

    on<LoadChatHistory>((event, emit) async {
      emit(ChatLoading());
      try {
        final history = await repository.getChatHistory();
        _chatHistory = history;
        emit(ChatHistoryLoaded(history));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });

    on<CreateNewChat>((event, emit) async {
      emit(ChatLoading());
      try {
        final chat = await repository.createChatInHistory(title: event.title);
        _chatHistory.insert(0, chat);
        emit(ChatHistoryLoaded(List.from(_chatHistory)));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });

    on<SendMessage>((event, emit) async {
      // Add user message
      final userMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: 'current',
        content: event.message,
        role: 'user',
        createdAt: DateTime.now(),
      );
      _messages.add(userMessage);
      emit(MessageSending(List.from(_messages)));

      try {
        print('Sending message using providerId=${event.providerId}: ${event.message}');
        
        // Generate AI response
        final response = await repository.generateMessage(
          message: event.message,
          providerId: event.providerId,
        );
        
        print('Response received: ${response.length} characters');

        // Add AI response
        final aiMessage = MessageModel(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          chatId: 'current',
          content: response,
          role: 'assistant',
          createdAt: DateTime.now(),
        );
        _messages.add(aiMessage);
        emit(MessageSent(List.from(_messages)));
      } catch (e) {
        print('Error generating message: $e');
        String errorMessage = 'Failed to generate response';
        
        // Handle specific OpenAI errors
        if (e.toString().contains('quota')) {
          errorMessage = 'Provider quota exceeded. Please add credits or try a different AI provider.';
        } else if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
          errorMessage = 'Invalid API key. Please check your provider API key in settings.';
        } else if (e.toString().contains('429')) {
          errorMessage = 'Rate limit exceeded. Please wait a moment and try again.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        
        emit(ChatError(errorMessage));
      }
    });

    on<SendStreamingMessage>((event, emit) async {
      // Add user message
      final userMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: 'current',
        content: event.message,
        role: 'user',
        createdAt: DateTime.now(),
      );
      _messages.add(userMessage);
      _currentStreamingContent = '';
      
      // Start with user message added
      emit(MessageSending(List.from(_messages)));

      try {
        
        // Try streaming first
        try {
          await emit.forEach<String>(
            repository.generateStreamingMessage(
              message: event.message,
              providerId: event.providerId,
            ),
            onData: (chunk) {
              _currentStreamingContent += chunk;
              return MessageStreaming(List.from(_messages), _currentStreamingContent);
            },
            onError: (error, stackTrace) {
              print('Streaming error: $error');
              throw error;
            },
          );
          
          // Add the completed AI message from streaming
          if (_currentStreamingContent.isNotEmpty) {
            final aiMessage = MessageModel(
              id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
              chatId: 'current',
              content: _currentStreamingContent,
              role: 'assistant',
              createdAt: DateTime.now(),
            );
            _messages.add(aiMessage);
            emit(MessageStreamComplete(List.from(_messages)));
            return;
          }
        } catch (streamError) {
          print('Streaming failed, falling back to regular message: $streamError');
          // Fall back to regular message generation
          try {
            final response = await repository.generateMessage(
              message: event.message,
              providerId: event.providerId,
            );
            
            // Add AI response from fallback
            final aiMessage = MessageModel(
              id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
              chatId: 'current',
              content: response,
              role: 'assistant',
              createdAt: DateTime.now(),
            );
            _messages.add(aiMessage);
            emit(MessageSent(List.from(_messages)));
            return;
          } catch (fallbackError) {
            print('Fallback also failed: $fallbackError');
            throw fallbackError;
          }
        }
      } catch (e) {
        print('Complete failure: $e');
        emit(ChatError('Failed to generate response: ${e.toString()}'));
      }
    });
    
    // Add handler for creating new local chat
    on<CreateLocalChat>((event, emit) async {
      // Save current chat to history if it has messages
      if (_messages.isNotEmpty) {
        _saveCurrentChatToHistory();
      }
      
      // Clear current chat
      _messages.clear();
      _currentChatId = null;
      _currentChatTitle = 'New Chat';
      _currentStreamingContent = '';
      
      emit(ChatInitial());
    });
    
    // Add handler for loading local chat history
    on<LoadLocalChatHistory>((event, emit) async {
      // Just emit the current local history
      emit(ChatHistoryLoaded(List.from(_chatHistory)));
    });
  }
  
  void _saveCurrentChatToHistory() {
    if (_messages.isEmpty) return;
    
    // Generate title from first user message
    final firstUserMessage = _messages.firstWhere(
      (msg) => msg.isUser, 
      orElse: () => _messages.first,
    );
    
    final title = firstUserMessage.content.length > 50 
        ? '${firstUserMessage.content.substring(0, 50)}...'
        : firstUserMessage.content;
    
    final chatId = _currentChatId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    final chat = ChatModel(
      id: chatId,
      userId: 'local_user',
      title: title.isNotEmpty ? title : 'New Chat',
      createdAt: _messages.first.createdAt,
      updatedAt: DateTime.now(),
    );
    
    // Add to beginning of history (most recent first)
    _chatHistory.removeWhere((c) => c.id == chatId); // Remove if exists
    _chatHistory.insert(0, chat);
    
    // Keep only last 10 chats
    if (_chatHistory.length > 10) {
      _chatHistory = _chatHistory.take(10).toList();
    }
  }

  List<MessageModel> get messages => List.from(_messages);
  List<ChatModel> get chatHistory => List.from(_chatHistory);
  String get currentChatTitle => _currentChatTitle;
  bool get hasMessages => _messages.isNotEmpty;
}
