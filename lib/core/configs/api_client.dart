import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final Map<String, String> defaultHeaders = {
    "Content-Type": "application/json",
  };

  Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse(url), headers: defaultHeaders);
    return _handleResponse(response);
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: defaultHeaders,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("API Error: ${response.statusCode} ${response.body}");
    }
  }
}
