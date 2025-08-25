// ignore_for_file: avoid_print

import '../configs/api_client.dart';
import '../configs/api_endpoints.dart';
import '../models/chat_model.dart';
import '../../features/idea/data/models/model.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final ApiClient _apiClient = ApiClient();

  // Demo-only hardcoded streaming for a specific prompt (no backend, no keys)
  static const String _demoPrompt = 'give me some content ideas to post in youtube';
  static const String _demoReply = '''Got it 🚀 You want YouTube content ideas — here are some solid directions you can take, depending on your interests and what kind of audience you want to grow:

🎥 Tech & Coding (if you want to share your skills)
- "Day in the Life of a CS Student / Developer" – vlog-style, relatable.
- Crash Courses (e.g., "MERN Stack in 15 Minutes", "Intro to Machine Learning Basics").
- Build Something Cool ("I Built a Chatbot in 24 Hours", "Creating a Weather App with Flutter").
- Explainers ("What is AI, really?", "How the Internet Actually Works").
- Tech Trends ("5 Skills Every Developer Needs in 2025").

📚 Learning & Study Content
- Study with me (Pomodoro style, live or recorded).
- "How I Learn Machine Learning / Coding Faster."
- Tutorials on tools you use (GitHub, VS Code, Supabase, etc.).
- Explaining tough math or CS concepts in simple terms.

🎯 Self-Growth / Productivity
- Productivity hacks for students/developers.
- Your workflow setups (apps, tools, coding environment).
- "Things I Wish I Knew Before Starting B.Tech CSE."

🤳 Lifestyle / Relatable Student Content
- Campus life vlogs (Roorkee College of Engineering experiences).
- Day in the life (study + coding + fun).
- "Struggles of a CS Student" (funny/skit-style).

🔥 Trending/Short-form Content Ideas
- 30–60 second tech tips (like using ChatGPT, shortcuts in VS Code).
- "Did you know?" facts about AI, coding, or tech.
- Small coding challenges ("Guess the Output?").
- Reaction-style shorts (reacting to coding memes, AI news).

⚡ My suggestion: Start with short, easy-to-produce content (like Shorts or explainers), then move into longer tutorials/vlogs once you find what clicks with your audience.

👉 Do you want me to create a 3-month content plan for you (video titles + formats + posting schedule), so you can just follow and upload?
''';

  // Chat endpoints
  Future<List<ChatModel>> getChats() async {
    final response = await _apiClient.get(ApiEndpoints.chats);
    final chats = (response['chats'] as List)
        .map((chatJson) => ChatModel.fromJson(chatJson))
        .toList();
    return chats;
  }

  Future<ChatModel> createChat({String? title}) async {
    final response = await _apiClient.post(
      ApiEndpoints.chats,
      {'title': title ?? 'New Chat'},
    );
    return ChatModel.fromJson(response['chat']);
  }

  // History endpoints
  Future<List<ChatModel>> getChatHistory() async {
    final response = await _apiClient.get(ApiEndpoints.history);
    return (response as List)
        .map((chatJson) => ChatModel.fromJson(chatJson))
        .toList();
  }

  Future<ChatModel> createChatInHistory({String? title}) async {
    final response = await _apiClient.post(
      ApiEndpoints.history,
      {'title': title ?? 'New Chat'},
    );
    return ChatModel.fromJson(response);
  }

  // Message generation using provider ID
  Future<String> generateMessage({
    required String message,
    required String providerId,
    double? temperature,
    int? maxTokens,
  }) async {
    // DEMO: return hardcoded full reply if the message matches the demo prompt
    if (message.trim().toLowerCase() == _demoPrompt) {
      return _demoReply;
    }

    final response = await _apiClient.post(
      ApiEndpoints.generateMessage,
      {
        'content': message,
        'providerId': providerId,
        'temperature': temperature ?? 0.7,
        'maxTokens': maxTokens ?? 1000,
      },
    );
    return response['reply'] ?? '';
  }

  // Streaming message generation with fallback
  Stream<String> generateStreamingMessage({
    required String message,
    required String providerId,
    double? temperature,
    int? maxTokens,
  }) async* {
    // DEMO: stream hardcoded content for the exact demo prompt without any network
    if (message.trim().toLowerCase() == _demoPrompt) {
      yield* _demoStreaming(_demoReply);
      return;
    }

    try {
      print('Attempting SSE streaming...');
      
      // First, try real SSE streaming
      await for (final chunk in _tryRealStreaming(message, providerId, temperature, maxTokens)) {
        yield chunk;
      }
    } catch (streamingError) {
      print('SSE streaming failed: $streamingError');
      print('Falling back to simulated streaming...');
      
      try {
        // Fallback to simulated streaming using regular API
        await for (final chunk in _simulateStreaming(message, providerId, temperature, maxTokens)) {
          yield chunk;
        }
      } catch (fallbackError) {
        print('Simulated streaming also failed: $fallbackError');
        throw Exception('All streaming methods failed: $fallbackError');
      }
    }
  }

  // Try real SSE streaming from backend
  Stream<String> _tryRealStreaming(
    String message,
    String providerId,
    double? temperature,
    int? maxTokens,
  ) async* {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    };
    
    // Add authorization header if available
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    final body = jsonEncode({
      'content': message,
      'providerId': providerId,
      'temperature': temperature ?? 0.7,
      'maxTokens': maxTokens ?? 1000,
    });

    final request = http.Request('POST', Uri.parse(ApiEndpoints.generateMessageStream))
      ..headers.addAll(headers)
      ..body = body;

    final client = http.Client();
    
    try {
      final response = await client.send(request);
      
      if (response.statusCode == 405) {
        throw Exception('Streaming endpoint not implemented (405)');
      }
      
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: Streaming request failed');
      }

      print('SSE stream connected successfully');
      
      // Parse SSE stream
      String buffer = '';
      await for (List<int> chunk in response.stream) {
        final chunkString = String.fromCharCodes(chunk);
        buffer += chunkString;
        
        // Process complete events
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // Keep incomplete line in buffer
        
        for (String line in lines) {
          line = line.trim();
          
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            
            if (data == '[DONE]') {
              print('Stream completed with [DONE]');
              return;
            }
            
            if (data.isEmpty) continue;
            
            try {
              final jsonData = jsonDecode(data);
              if (jsonData is Map) {
                if (jsonData['type'] == 'content') {
                  yield jsonData['content'] ?? '';
                } else if (jsonData['type'] == 'error') {
                  throw Exception(jsonData['message'] ?? 'Stream error');
                } else if (jsonData['choices'] is List && jsonData['choices'].isNotEmpty) {
                  // OpenAI format
                  final choice = jsonData['choices'][0];
                  final delta = choice['delta'];
                  if (delta != null && delta['content'] != null) {
                    yield delta['content'];
                  }
                }
              }
            } catch (jsonError) {
              // If JSON decode fails, treat as plain text chunk
              if (data.isNotEmpty) {
                yield data;
              }
            }
          } else if (line.startsWith('event: ')) {
            // Handle event types if needed
            continue;
          }
        }
      }
    } finally {
      client.close();
    }
  }

  // Simulate streaming by yielding word-like tokens with natural pauses
  Stream<String> _simulateStreaming(
    String message,
    String providerId,
    double? temperature,
    int? maxTokens,
  ) async* {
    print('Using simulated streaming...');

    // Get the full response first
    final fullResponse = await generateMessage(
      message: message,
      providerId: providerId,
      temperature: temperature,
      maxTokens: maxTokens,
    );

    print('Got full response: ${fullResponse.length} characters');

    final tokens = _tokenizeForTyping(fullResponse);
    final rand = math.Random();

    for (final t in tokens) {
      yield t;
      await Future.delayed(_delayForToken(t, rand));
    }

    print('Simulated streaming completed');
  }

  // Demo-only local streaming (word-by-word with natural pauses)
  Stream<String> _demoStreaming(String content) async* {
    final rand = math.Random();
    final tokens = _tokenizeForTyping(content);
    for (final t in tokens) {
      yield t;
      await Future.delayed(_delayForToken(t, rand));
    }
  }

  // Ideas endpoints
  Future<List<IdeaModel>> getIdeas({required String userId}) async {
    final response = await _apiClient.get(
      ApiEndpoints.ideas,
      queryParams: {'userId': userId},
    );
    return (response as List)
        .map((ideaJson) => IdeaModel.fromJson(ideaJson))
        .toList();
  }

  Future<IdeaModel> createIdea({
    required String userId,
    required String content,
    required String platform,
    required String tone,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.ideas,
      {
        'userId': userId,
        'content': content,
        'platform': platform,
        'tone': tone,
      },
    );
    return IdeaModel.fromJson(response);
  }
  // Break content into tokens: whitespace, words (incl. apostrophes), and punctuation
  List<String> _tokenizeForTyping(String text) {
    final regex = RegExp(r"(\s+|[\w’']+|[^\w\s])");
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  // Compute a natural delay for a token to simulate human typing rhythm
  Duration _delayForToken(String token, math.Random rand) {
    // Trim to detect punctuation vs whitespace easily
    final t = token;

    // Handle newlines with larger pauses
    if (t.contains('\n\n')) {
      return Duration(milliseconds: 260 + rand.nextInt(200));
    }
    if (t.contains('\n')) {
      return Duration(milliseconds: 160 + rand.nextInt(140));
    }

    // Punctuation pauses
    if (t == '.' || t == '!' || t == '?') {
      return Duration(milliseconds: 140 + rand.nextInt(120));
    }
    if (t == ',' || t == ':' || t == ';') {
      return Duration(milliseconds: 80 + rand.nextInt(80));
    }

    // Whitespace (spaces, tabs) — short pause
    if (RegExp(r'^\s+$').hasMatch(t)) {
      return Duration(milliseconds: 25 + rand.nextInt(30));
    }

    // Words: base per-word delay with slight length scaling and jitter
    final lengthFactor = (t.length * 6).clamp(18, 90); // 6ms per char, clamped
    final jitter = rand.nextInt(30); // +/- jitter
    return Duration(milliseconds: lengthFactor + jitter);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
