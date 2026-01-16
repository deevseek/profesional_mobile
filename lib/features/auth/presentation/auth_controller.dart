import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  AuthUser? _user;
  String? _errorMessage;
  bool _busy = false;

  AuthStatus get status => _status;
  AuthUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _busy;

  Future<void> initialize() async {
    if (_status != AuthStatus.initial) {
      return;
    }
    _setBusy(true);
    _errorMessage = null;
    try {
      final user = await _authRepository.getCurrentUser();
      _user = user;
      _status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    } catch (error) {
      if (_isUnauthorized(error)) {
        await logout();
        return;
      }
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Unable to load profile. Please sign in.';
    } finally {
      _setBusy(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      final user = await _authRepository.login(email: email, password: password);
      _user = user;
      _status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    } catch (error) {
      if (_isUnauthorized(error)) {
        await logout();
        return;
      }
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Login failed. Please check your credentials.';
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    _setBusy(true);
    _errorMessage = null;
    try {
      await _authRepository.logout();
    } finally {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _setBusy(false);
    }
  }

  bool _isUnauthorized(Object error) {
    if (error is UnauthorizedException) {
      return true;
    }
    if (error is DioException) {
      return error.error is UnauthorizedException || error.response?.statusCode == 401;
    }
    return false;
  }

  void _setBusy(bool value) {
    if (_busy == value) {
      return;
    }
    _busy = value;
    notifyListeners();
  }
}
