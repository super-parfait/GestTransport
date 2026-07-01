import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../data/models/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

enum SessionStatus {
  loading,
  unauthenticated,
  authenticated,
}

class SessionController extends ChangeNotifier {
  final AuthRepository _authRepository;

  SessionStatus _status = SessionStatus.loading;
  UserSession? _session;
  String? _errorMessage;
  bool _isSubmitting = false;

  SessionController(this._authRepository);

  SessionStatus get status => _status;
  UserSession? get session => _session;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get isAuthenticated => _status == SessionStatus.authenticated;

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Future<void> restoreSession() async {
    _status = SessionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _authRepository.restoreSession();
      _status = _session == null
          ? SessionStatus.unauthenticated
          : SessionStatus.authenticated;
    } catch (_) {
      _session = null;
      _status = SessionStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _authRepository.login(
        LoginRequest(
          phone: identifier.trim(),
          password: password.trim(),
        ),
      );
      _status = SessionStatus.authenticated;
      return true;
    } on ApiException catch (error) {
      _session = null;
      _status = SessionStatus.unauthenticated;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _session = null;
      _status = SessionStatus.unauthenticated;
      _errorMessage = 'Connexion impossible pour le moment.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
    required String role,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _authRepository.register(
        RegisterRequest(
          name: fullName.trim(),
          phone: phone.trim(),
          password: password.trim(),
          role: role.trim(),
        ),
      );
      _status = SessionStatus.authenticated;
      return true;
    } on ApiException catch (error) {
      _session = null;
      _status = SessionStatus.unauthenticated;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _session = null;
      _status = SessionStatus.unauthenticated;
      _errorMessage = 'Inscription impossible pour le moment.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _session = null;
    _errorMessage = null;
    _status = SessionStatus.unauthenticated;
    notifyListeners();
  }
}
