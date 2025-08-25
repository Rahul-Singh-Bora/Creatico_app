import 'package:creatico/features/idea/bloc/idea_event.dart';
import 'package:creatico/features/idea/bloc/idea_state.dart';
import 'package:creatico/features/idea/data/models/model.dart';
import 'package:creatico/features/idea/data/repositories/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IdeasBloc extends Bloc<IdeasEvent, IdeasState> {
  final IdeasRepository repository;
  final List<IdeaModel> _ideas = [];

  IdeasBloc(this.repository) : super(IdeasInitial()) {
    on<LoadIdeas>((event, emit) async {
      emit(IdeasLoading());
      try {
        final ideas = await repository.getIdeas();
        _ideas.clear();
        _ideas.addAll(ideas);
        emit(IdeasLoaded(List.from(_ideas)));
      } catch (e) {
        emit(IdeasError(e.toString()));
      }
    });
    
    on<GenerateIdea>((event, emit) async {
      emit(IdeasLoading());
      try {
        final idea = await repository.generateIdea(
          prompt: event.prompt,
          platform: event.platform,
          tone: event.tone,
        );
        _ideas.add(idea);
        emit(IdeasLoaded(List.from(_ideas)));
      } catch (e) {
        emit(IdeasError(e.toString()));
      }
    });
  }
}
