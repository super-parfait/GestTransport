class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? details;

  const ApiException(
    this.message, {
    this.statusCode,
    this.details,
  });

  factory ApiException.fromStatusCode(
    int statusCode,
    dynamic payload,
  ) {
    final message = _extractMessage(payload);

    switch (statusCode) {
      case 400:
        return ApiException(
          message.isEmpty ? 'Requête invalide.' : message,
          statusCode: statusCode,
          details: payload,
        );
      case 401:
        return ApiException(
          message.isEmpty
              ? 'Session invalide. Veuillez vous reconnecter.'
              : message,
          statusCode: statusCode,
          details: payload,
        );
      case 403:
        return ApiException(
          message.isEmpty ? 'Accès refusé.' : message,
          statusCode: statusCode,
          details: payload,
        );
      case 404:
        return ApiException(
          message.isEmpty ? 'Ressource introuvable.' : message,
          statusCode: statusCode,
          details: payload,
        );
      case 422:
        return ApiException(
          message.isEmpty ? 'Données invalides.' : message,
          statusCode: statusCode,
          details: payload,
        );
      default:
        return ApiException(
          message.isEmpty ? 'Erreur serveur ($statusCode).' : message,
          statusCode: statusCode,
          details: payload,
        );
    }
  }

  static String _extractMessage(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final direct = payload['message'];
      if (direct is String && direct.trim().isNotEmpty) {
        return direct.trim();
      }

      final error = payload['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }

      final errors = payload['errors'];
      if (errors is Map<String, dynamic> && errors.isNotEmpty) {
        final firstValue = errors.values.first;
        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }
        return firstValue.toString();
      }
    }

    if (payload is String && payload.trim().isNotEmpty) {
      return payload.trim();
    }

    return '';
  }

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}
