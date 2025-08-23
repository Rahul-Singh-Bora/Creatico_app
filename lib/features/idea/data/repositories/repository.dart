import 'dart:convert';
import 'package:creatico/features/idea/data/models/model.dart';
import 'package:http/http.dart' as http;


class IdeasRepository {
  final String baseUrl;

  IdeasRepository({required this.baseUrl});

  Future<IdeaModel> generateIdea({
    required String prompt,
    required String platform,
    required String tone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ideas/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        'platform': platform,
        'tone': tone,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return IdeaModel.fromJson(data);
    } else {
      throw Exception('Failed to generate idea');
    }
  }
}
