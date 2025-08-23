import 'package:creatico/features/idea/bloc/idea_bloc.dart';
import 'package:creatico/features/idea/bloc/idea_state.dart';
import 'package:creatico/features/idea/presentation/widgets/idea_bubble.dart';
import 'package:creatico/features/idea/presentation/widgets/idea_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IdeasChatScreen extends StatelessWidget {
  const IdeasChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Creative Ideas")),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<IdeasBloc, IdeasState>(
              builder: (context, state) {
                if (state is IdeasInitial) {
                  return const Center(child: Text("Start generating ideas!"));
                } else if (state is IdeasLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is IdeasLoaded) {
                  return ListView.builder(
                    reverse: true,
                    itemCount: state.ideas.length,
                    itemBuilder: (context, index) {
                      final idea = state.ideas.reversed.toList()[index];
                      return IdeaBubble(idea: idea);
                    },
                  );
                } else if (state is IdeasError) {
                  return Center(child: Text("Error: ${state.message}"));
                }
                return const SizedBox();
              },
            ),
          ),
          IdeaInput(),
        ],
      ),
    );
  }
}
