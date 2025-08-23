import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  // Change this to your Next.js server URL
  static const String baseUrl = 'http://localhost:3000/api';
  
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get authenticated headers with Supabase JWT token
  Map<String, String> _getHeaders() {
    final session = _supabase.auth.currentSession;
    return {
      'Content-Type': 'application/json',
      if (session != null) 'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  /// Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: json.encode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: json.encode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Handle HTTP response and throw appropriate exceptions
  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> responseData;
    
    try {
      responseData = json.decode(response.body);
    } catch (e) {
      throw ApiException('Invalid response format');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      final errorMessage = responseData['error']?.toString() ?? 
                          responseData['message']?.toString() ?? 
                          'Unknown error occurred';
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
