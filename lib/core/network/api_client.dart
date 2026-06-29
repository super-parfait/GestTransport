import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
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

    _log('$method $uri');

    try {
      final streamedResponse =
          await _httpClient.send(request).timeout(_config.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(_config.receiveTimeout);
      final payload = _decodeResponseBody(response.body);

      _log('[$method] ${response.statusCode} ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoder(_unwrapData(payload));
      }

      throw ApiException.fromStatusCode(response.statusCode, payload);
    } on TimeoutException catch (error) {
      throw ApiException(
        'Le serveur ne répond pas dans le délai imparti.',
        details: error,
      );
    } on http.ClientException catch (error) {
      throw ApiException(
        'Impossible de joindre le serveur. Vérifiez votre connexion.',
        details: error,
      );
    } on FormatException catch (error) {
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

  void _log(String message) {
    if (_config.enableNetworkLogs) {
      debugPrint('[ApiClient] $message');
    }
  }
}
