import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static const String _baseUrl = 'https://api.mangadex.org';
  final http.Client _http;

  Future<Map<String, dynamic>> getJson(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    try {
      final response = await _http
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw HttpException('Request failed: ${response.statusCode}');
    } on SocketException {
      throw const HttpException('No internet connection');
    } on FormatException {
      throw const HttpException('Invalid response format');
    } on HttpException {
      rethrow;
    } on Exception catch (e) {
      throw HttpException('Unexpected error: $e');
    }
  }
}

