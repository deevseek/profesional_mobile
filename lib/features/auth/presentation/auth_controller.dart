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
      
      if (user == null) {
        if (kDebugMode) {
          print('❌ [INIT] No user found - no token or invalid token');
        }
        _status = AuthStatus.unauthenticated;
      } else {
        if (kDebugMode) {
          print('✅ [INIT] User authenticated: ${user.name}');
        }
        _user = user;
        _status = AuthStatus.authenticated;
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ [INIT ERROR] $error');
      }
      if (_isUnauthorized(error)) {
        await logout();
        return;
      }
      // On any other error, show login page
      _status = AuthStatus.unauthenticated;
      if (kDebugMode) {
        _errorMessage = 'Unable to load profile: $error';
      }
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
      if (kDebugMode) {
        print('❌ [LOGIN ERROR] $error');
      }
      if (_isUnauthorized(error)) {
        await logout();
        _errorMessage = 'Invalid email or password.';
        return;
      }
      _status = AuthStatus.unauthenticated;
      
      // Extract detailed error message
      if (error is ApiException) {
        _errorMessage = error.message;
      } else if (error is DioException) {
        _errorMessage = error.message ?? 'Connection error. Please try again.';
      } else {
        _errorMessage = error.toString();
      }
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
