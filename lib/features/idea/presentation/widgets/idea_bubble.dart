import 'package:creatico/features/idea/data/models/model.dart';
import 'package:flutter/material.dart';


class IdeaBubble extends StatelessWidget {
  final IdeaModel idea;

  const IdeaBubble({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(idea.content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              "${idea.platform} • ${idea.tone}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
