import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {}

class LoadChatHistory extends ChatEvent {}

class CreateNewChat extends ChatEvent {
  final String? title;

  CreateNewChat({this.title});

  @override
  List<Object?> get props => [title];
}

class SendMessage extends ChatEvent {
  final String message;
  final String providerId;

  SendMessage({
    required this.message,
    required this.providerId,
  });

  @override
  List<Object?> get props => [message, providerId];
}

class SendStreamingMessage extends ChatEvent {
  final String message;
  final String providerId;

  SendStreamingMessage({
    required this.message,
    required this.providerId,
  });

  @override
  List<Object?> get props => [message, providerId];
}

class CreateLocalChat extends ChatEvent {
  @override
  List<Object?> get props => [];
}

class LoadLocalChatHistory extends ChatEvent {
  @override
  List<Object?> get props => [];
}
