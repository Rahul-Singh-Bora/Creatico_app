import 'package:creatico/features/idea/bloc/idea_bloc.dart';
import 'package:creatico/features/idea/bloc/idea_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class IdeaInput extends StatefulWidget {
  const IdeaInput({super.key});

  @override
  State<IdeaInput> createState() => _IdeaInputState();
}

class _IdeaInputState extends State<IdeaInput> {
  final TextEditingController _controller = TextEditingController();
  String _selectedPlatform = "Twitter";
  String _selectedTone = "Casual";

  final platforms = ["Twitter", "Instagram", "LinkedIn", "YouTube"];
  final tones = ["Casual", "Professional", "Funny", "Inspirational"];

  void _sendIdea() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<IdeasBloc>().add(
          GenerateIdea(
            prompt: text,
            platform: _selectedPlatform,
            tone: _selectedTone,
          ),
        );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Type a keyword or prompt...",
                  border: InputBorder.none,
                ),
              ),
            ),
            DropdownButton<String>(
              value: _selectedPlatform,
              items: platforms
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPlatform = v!),
            ),
            DropdownButton<String>(
              value: _selectedTone,
              items: tones
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedTone = v!),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendIdea,
            ),
          ],
        ),
      ),
    );
  }
}
