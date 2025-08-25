import 'package:equatable/equatable.dart';

abstract class IdeasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadIdeas extends IdeasEvent {}

class GenerateIdea extends IdeasEvent {
  final String prompt;
  final String platform;
  final String tone;

  GenerateIdea({
    required this.prompt,
    required this.platform,
    required this.tone,
  });

  @override
  List<Object?> get props => [prompt, platform, tone];
}
