import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // Configure the backend base URL via .env
  // Add API_BASE_URL=https://your-deployment-url (or http://localhost:3000 for local dev)
  static String get baseUrl {
    String url = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
    // Android emulator cannot reach host's localhost; use 10.0.2.2
    if (Platform.isAndroid && (url.contains('localhost') || url.contains('127.0.0.1'))) {
      url = url.replaceFirst('127.0.0.1', 'localhost');
      url = url.replaceFirst('localhost', '10.0.2.2');
    }
    return url;
  }

  // Auth endpoints
  static String get login => "$baseUrl/api/auth/login";
  static String get register => "$baseUrl/api/auth/register";

  // Chat endpoints
  static String get chats => "$baseUrl/api/chat";
  static String get history => "$baseUrl/api/history";
  static String get generateMessage => "$baseUrl/api/generate_message";
  static String get streamMessage => "$baseUrl/api/stream_message";
  static String get generateMessageStream => "$baseUrl/api/generate_message_stream";
  
  // Idea endpoints
  static String get ideas => "$baseUrl/api/ideas";
  
  // Provider endpoints
  static String get providers => "$baseUrl/api/providers";
}
