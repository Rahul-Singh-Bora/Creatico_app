import 'package:creatico/features/idea/data/models/model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/api_service.dart';

class IdeasRepository {
  final ApiService _apiService = ApiService();

  Future<List<IdeaModel>> getIdeas() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    return await _apiService.getIdeas(userId: user.id);
  }

  Future<IdeaModel> createIdea({
    required String content,
    required String platform,
    required String tone,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    return await _apiService.createIdea(
      userId: user.id,
      content: content,
      platform: platform,
      tone: tone,
    );
  }

  // For compatibility with existing generateIdea method
  Future<IdeaModel> generateIdea({
    required String prompt,
    required String platform,
    required String tone,
  }) async {
    return await createIdea(
      content: prompt,
      platform: platform,
      tone: tone,
    );
  }
}
