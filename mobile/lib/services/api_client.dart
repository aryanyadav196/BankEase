import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.endpoint,
    this.safeResponse,
  });
  final String message;
  final int? statusCode;
  final String? endpoint;
  final String? safeResponse;
  bool get isUnauthorized => statusCode == 401;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();
  final String baseUrl;
  final http.Client _client;

  Future<dynamic> get(String path, {String? token}) async {
    _logRequest('GET', path);
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$path'),
        headers: headers,
      );
      final decoded = _decode(response.body);
      _logResponse('GET', path, response.statusCode, decoded, response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _message(decoded, 'Request failed.'),
          statusCode: response.statusCode,
          endpoint: path,
          safeResponse: _safeResponse(decoded, response.body),
        );
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on FormatException {
      throw ApiException(
        'The server returned an invalid response.',
        endpoint: path,
      );
    } catch (_) {
      throw ApiException(
        'Unable to reach BankEase. Check that the backend is running and the API URL is correct.',
        endpoint: path,
      );
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    _logRequest('POST', path);
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: jsonEncode(body),
      );
      final decoded = _decode(response.body);
      _logResponse('POST', path, response.statusCode, decoded, response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _message(decoded, 'Request failed.'),
          statusCode: response.statusCode,
          endpoint: path,
          safeResponse: _safeResponse(decoded, response.body),
        );
      }
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on ApiException {
      rethrow;
    } on FormatException {
      throw ApiException(
        'The server returned an invalid response.',
        endpoint: path,
      );
    } catch (_) {
      throw ApiException(
        'Unable to reach BankEase. Check that the backend is running and the API URL is correct.',
        endpoint: path,
      );
    }
  }

  Future<Map<String, dynamic>> patch(String path, {String? token}) async {
    _logRequest('PATCH', path);
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl$path'),
        headers: headers,
      );
      final decoded = _decode(response.body);
      _logResponse('PATCH', path, response.statusCode, decoded, response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _message(decoded, 'Request failed.'),
          statusCode: response.statusCode,
          endpoint: path,
          safeResponse: _safeResponse(decoded, response.body),
        );
      }
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on ApiException {
      rethrow;
    } on FormatException {
      throw ApiException(
        'The server returned an invalid response.',
        endpoint: path,
      );
    } catch (_) {
      throw ApiException(
        'Unable to reach BankEase. Check that the backend is running and the API URL is correct.',
        endpoint: path,
      );
    }
  }

  Future<Map<String, dynamic>> delete(String path, {String? token}) async {
    _logRequest('DELETE', path);
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$path'),
        headers: headers,
      );
      final decoded = _decode(response.body);
      _logResponse('DELETE', path, response.statusCode, decoded, response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _message(decoded, 'Request failed.'),
          statusCode: response.statusCode,
          endpoint: path,
          safeResponse: _safeResponse(decoded, response.body),
        );
      }
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on ApiException {
      rethrow;
    } on FormatException {
      throw ApiException(
        'The server returned an invalid response.',
        endpoint: path,
      );
    } catch (_) {
      throw ApiException(
        'Unable to reach BankEase. Check that the backend is running and the API URL is correct.',
        endpoint: path,
      );
    }
  }

  dynamic _decode(String body) => body.trim().isEmpty ? null : jsonDecode(body);

  String _message(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return fallback;
  }

  String _safeResponse(dynamic data, String rawBody) {
    if (data == null) {
      return rawBody.trim().isEmpty
          ? 'empty response body'
          : 'non-JSON response';
    }
    return jsonEncode(_redact(data));
  }

  dynamic _redact(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(
          key,
          _isSensitiveKey(key.toString()) ? '[redacted]' : _redact(item),
        ),
      );
    }
    if (value is List) return value.map(_redact).toList();
    return value;
  }

  bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('token') ||
        normalized.contains('password') ||
        normalized.contains('secret') ||
        normalized.contains('authorization');
  }

  void _logRequest(String method, String path) {
    debugPrint('[BankEase API] $method $path');
  }

  void _logResponse(
    String method,
    String path,
    int statusCode,
    dynamic decoded,
    String rawBody,
  ) {
    if (statusCode < 200 || statusCode >= 300) {
      debugPrint(
        '[BankEase API] $method $path -> HTTP $statusCode: '
        '${_safeResponse(decoded, rawBody)}',
      );
    } else {
      debugPrint('[BankEase API] $method $path -> HTTP $statusCode');
    }
  }
}
