import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  static int _requestSequence = 0;
  final http.Client _httpClient;
  final TokenStorage _tokenStorage;
  final AppConfig _config;

  const ApiClient({
    required http.Client httpClient,
    required TokenStorage tokenStorage,
    required AppConfig config,
  })  : _httpClient = httpClient,
        _tokenStorage = tokenStorage,
        _config = config;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) {
    return _request(
      method: 'POST',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) {
    return _request(
      method: 'PUT',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<T> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) {
    return _request(
      method: 'PATCH',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) {
    return _request(
      method: 'DELETE',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<T> uploadFile<T>(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) async {
    final uri = _buildUri(path, null);
    final request = http.MultipartRequest('POST', uri);
    final accessToken = _tokenStorage.readAccessToken();
    final requestId = _nextRequestId();
    final stopwatch = Stopwatch()..start();

    request.headers.addAll({
      'Accept': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
      ...?headers,
    });
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    _logRequest(
      requestId: requestId,
      method: 'POST',
      uri: uri,
      body: {
        fieldName: _extractFileName(filePath),
        'multipart': true,
      },
    );

    try {
      final streamedResponse =
          await _httpClient.send(request).timeout(_config.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(_config.receiveTimeout);
      final payload = _decodeResponseBody(response.body);

      stopwatch.stop();
      _logResponse(
        requestId: requestId,
        method: 'POST',
        uri: uri,
        statusCode: response.statusCode,
        elapsedMs: stopwatch.elapsedMilliseconds,
        payload: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoder(_unwrapData(payload));
      }

      throw ApiException.fromStatusCode(response.statusCode, payload);
    } on TimeoutException catch (error) {
      stopwatch.stop();
      _logFailure(
        requestId: requestId,
        method: 'POST',
        uri: uri,
        elapsedMs: stopwatch.elapsedMilliseconds,
        message: 'Timeout',
      );
      throw ApiException(
        'Le serveur ne répond pas dans le délai imparti.',
        details: error,
      );
    } on http.ClientException catch (error) {
      stopwatch.stop();
      _logFailure(
        requestId: requestId,
        method: 'POST',
        uri: uri,
        elapsedMs: stopwatch.elapsedMilliseconds,
        message: 'ClientException: ${error.message}',
      );
      throw ApiException(
        'Impossible de joindre le serveur. Vérifiez votre connexion.',
        details: error,
      );
    } on FormatException catch (error) {
      stopwatch.stop();
      _logFailure(
        requestId: requestId,
        method: 'POST',
        uri: uri,
        elapsedMs: stopwatch.elapsedMilliseconds,
        message: 'FormatException: ${error.message}',
      );
      throw ApiException(
        'Réponse serveur invalide.',
        details: error,
      );
    }
  }

  Future<T> _request<T>({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final request = http.Request(method, uri);
    final accessToken = _tokenStorage.readAccessToken();
    final requestId = _nextRequestId();
    final stopwatch = Stopwatch()..start();

    request.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
      ...?headers,
    });

    if (body != null) {
      request.body = jsonEncode(body);
    }

    _logRequest(
      requestId: requestId,
      method: method,
      uri: uri,
      body: body,
    );

    try {
      final streamedResponse =
          await _httpClient.send(request).timeout(_config.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(_config.receiveTimeout);
      final payload = _decodeResponseBody(response.body);

      stopwatch.stop();
      _logResponse(
        requestId: requestId,
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        elapsedMs: stopwatch.elapsedMilliseconds,
        payload: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoder(_unwrapData(payload));
      }

      throw ApiException.fromStatusCode(response.statusCode, payload);
    } on TimeoutException catch (error) {
      stopwatch.stop();
      _logFailure(
        requestId: requestId,
        method: method,
        uri: uri,
        elapsedMs: stopwatch.elapsedMilliseconds,
        message: 'Timeout',
      );
      throw ApiException(
        'Le serveur ne répond pas dans le délai imparti.',
        details: error,
      );
    } on http.ClientException catch (error) {
      stopwatch.stop();
      _logFailure(
        requestId: requestId,
        method: method,
        uri: uri,
        elapsedMs: stopwatch.elapsedMilliseconds,
        message: 'ClientException: ${error.message}',
      );
      throw ApiException(
        'Impossible de joindre le serveur. Vérifiez votre connexion.',
        details: error,
      );
    } on FormatException catch (error) {
      stopwatch.stop();
      _logFailure(
        requestId: requestId,
        method: method,
        uri: uri,
        elapsedMs: stopwatch.elapsedMilliseconds,
        message: 'FormatException: ${error.message}',
      );
      throw ApiException(
        'Réponse serveur invalide.',
        details: error,
      );
    }
  }

  Uri _buildUri(
    String path,
    Map<String, dynamic>? queryParameters,
  ) {
    final baseUri = Uri.parse(_config.resolvePath(path));
    if (queryParameters == null || queryParameters.isEmpty) {
      return baseUri;
    }

    return baseUri.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  dynamic _decodeResponseBody(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    return jsonDecode(body);
  }

  dynamic _unwrapData(dynamic payload) {
    if (payload is Map<String, dynamic> && payload.containsKey('data')) {
      return payload['data'];
    }

    return payload;
  }

  static int _nextRequestId() => ++_requestSequence;

  void _logRequest({
    required int requestId,
    required String method,
    required Uri uri,
    Map<String, dynamic>? body,
  }) {
    _log('[#$requestId][REQ] $method $uri');

    if (body != null && body.isNotEmpty) {
      _log('[#$requestId][REQ-BODY] ${_formatPayload(body)}');
    }
  }

  void _logResponse({
    required int requestId,
    required String method,
    required Uri uri,
    required int statusCode,
    required int elapsedMs,
    required dynamic payload,
  }) {
    _log('[#$requestId][RES] $statusCode ${elapsedMs}ms $method $uri');
    _log('[#$requestId][RES-BODY] ${_formatPayload(payload)}');
  }

  void _logFailure({
    required int requestId,
    required String method,
    required Uri uri,
    required int elapsedMs,
    required String message,
  }) {
    _log('[#$requestId][ERR] ${elapsedMs}ms $method $uri -> $message');
  }

  String _formatPayload(dynamic payload) {
    final safePayload = _redactSensitivePayload(payload);
    final serialized = switch (safePayload) {
      null => '<empty>',
      String value => value.trim().isEmpty ? '<empty>' : value,
      _ => jsonEncode(safePayload),
    };

    return _truncate(serialized);
  }

  dynamic _redactSensitivePayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload.map(
        (key, value) => MapEntry(
          key,
          _isSensitiveKey(key)
              ? _redactedValue(value)
              : _redactSensitivePayload(value),
        ),
      );
    }

    if (payload is Map) {
      return Map<String, dynamic>.from(payload).map(
        (key, value) => MapEntry(
          key,
          _isSensitiveKey(key)
              ? _redactedValue(value)
              : _redactSensitivePayload(value),
        ),
      );
    }

    if (payload is List) {
      return payload.map(_redactSensitivePayload).toList(growable: false);
    }

    return payload;
  }

  bool _isSensitiveKey(String key) {
    final normalized = key.trim().toLowerCase();
    return normalized == 'password' ||
        normalized == 'accesstoken' ||
        normalized == 'access_token' ||
        normalized == 'refreshtoken' ||
        normalized == 'refresh_token' ||
        normalized == 'token';
  }

  String _redactedValue(dynamic value) {
    if (value == null) {
      return '<redacted>';
    }

    final raw = value.toString();
    if (raw.length <= 8) {
      return '<redacted>';
    }

    return '${raw.substring(0, 4)}...${raw.substring(raw.length - 4)}';
  }

  String _extractFileName(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final segments = normalized.split('/');
    return segments.isEmpty ? filePath : segments.last;
  }

  String _truncate(String value, {int maxLength = 420}) {
    if (value.length <= maxLength) {
      return value;
    }

    final hiddenLength = value.length - maxLength;
    return '${value.substring(0, maxLength)}... (+$hiddenLength chars)';
  }

  void _log(String message) {
    if (_config.enableNetworkLogs) {
      debugPrint('[ApiClient] $message');
    }
  }
}
