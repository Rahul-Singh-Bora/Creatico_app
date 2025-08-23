import 'package:creatico/features/idea/data/models/model.dart';
import 'package:equatable/equatable.dart';


abstract class IdeasState extends Equatable {
  @override
  List<Object?> get props => [];
}

class IdeasInitial extends IdeasState {}

class IdeasLoading extends IdeasState {}

class IdeasLoaded extends IdeasState {
  final List<IdeaModel> ideas;

  IdeasLoaded(this.ideas);

  @override
  List<Object?> get props => [ideas];
}

class IdeasError extends IdeasState {
  final String message;

  IdeasError(this.message);

  @override
  List<Object?> get props => [message];
}
