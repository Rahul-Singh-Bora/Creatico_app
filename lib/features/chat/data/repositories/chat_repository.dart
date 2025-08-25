import '../../../../core/services/api_service.dart';
import '../../../../core/models/chat_model.dart';

class ChatRepository {
  final ApiService _apiService = ApiService();

  Future<List<ChatModel>> getChats() async {
    return await _apiService.getChats();
  }

  Future<ChatModel> createChat({String? title}) async {
    return await _apiService.createChat(title: title);
  }

  Future<List<ChatModel>> getChatHistory() async {
    return await _apiService.getChatHistory();
  }

  Future<ChatModel> createChatInHistory({String? title}) async {
    return await _apiService.createChatInHistory(title: title);
  }

  Future<String> generateMessage({
    required String message,
    required String providerId,
  }) async {
    return await _apiService.generateMessage(
      message: message,
      providerId: providerId,
    );
  }

  Stream<String> generateStreamingMessage({
    required String message,
    required String providerId,
  }) {
    return _apiService.generateStreamingMessage(
      message: message,
      providerId: providerId,
    );
  }
}
