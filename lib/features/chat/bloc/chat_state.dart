import 'package:equatable/equatable.dart';
import '../../../core/models/chat_model.dart';
import '../../../core/models/message_model.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<ChatModel> chats;

  ChatsLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatHistoryLoaded extends ChatState {
  final List<ChatModel> history;

  ChatHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class MessageSending extends ChatState {
  final List<MessageModel> messages;

  MessageSending(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageSent extends ChatState {
  final List<MessageModel> messages;

  MessageSent(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageStreaming extends ChatState {
  final List<MessageModel> messages;
  final String currentStreamContent;

  MessageStreaming(this.messages, this.currentStreamContent);

  @override
  List<Object?> get props => [messages, currentStreamContent];
}

class MessageStreamComplete extends ChatState {
  final List<MessageModel> messages;

  MessageStreamComplete(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
