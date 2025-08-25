import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/api_exception.dart';

class ApiClient {
  final Map<String, String> _baseHeaders = {
    "Content-Type": "application/json",
  };

  Map<String, String> get _headers {
    final headers = Map<String, String>.from(_baseHeaders);
    
    // Add authorization header if user is authenticated
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    
    return headers;
  }

  Future<dynamic> get(String url, {Map<String, String>? queryParams}) async {
    var uri = Uri.parse(url);
    if (queryParams != null) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, ...queryParams});
    }
    
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String url) async {
    final response = await http.delete(Uri.parse(url), headers: _headers);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String errorMessage = "API Error: ${response.statusCode}";
      try {
        final errorBody = jsonDecode(response.body);
        // Accept common shapes: { error: string } or plain string
        if (errorBody is Map && errorBody['error'] is String) {
          errorMessage = errorBody['error'];
        } else if (errorBody is String && errorBody.isNotEmpty) {
          errorMessage = errorBody;
        }
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }
}
