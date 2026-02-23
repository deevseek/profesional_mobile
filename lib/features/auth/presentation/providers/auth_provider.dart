import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/auth/data/models/login_request.dart';
import 'package:profesionalservis_mobile/features/auth/data/models/user_model.dart';
import 'package:profesionalservis_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:profesionalservis_mobile/storage/secure_storage_service.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(
    repository: ref.watch(authRepositoryProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );
  notifier.bootstrap();
  return notifier;
});

class AuthState {
  const AuthState({
    this.token,
    this.user,
    this.errorMessage,
    this.isBootstrapping = false,
    this.isSubmitting = false,
  });

  final String? token;
  final UserModel? user;
  final String? errorMessage;
  final bool isBootstrapping;
  final bool isSubmitting;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    String? token,
    UserModel? user,
    String? errorMessage,
    bool? isBootstrapping,
    bool? isSubmitting,
    bool clearToken = false,
    bool clearUser = false,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      token: clearToken ? null : (token ?? this.token),
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required AuthRepository repository,
    required SecureStorageService storage,
  }) : _repository = repository,
       _storage = storage,
       super(const AuthState());

  final AuthRepository _repository;
  final SecureStorageService _storage;

  Future<void> bootstrap() async {
    state = state.copyWith(isBootstrapping: true, clearErrorMessage: true);

    try {
      final token = await _storage.readToken();
      state = state.copyWith(
        token: token,
        isBootstrapping: false,
      );
    } catch (_) {
      state = state.copyWith(
        isBootstrapping: false,
        clearToken: true,
        clearUser: true,
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    final sanitizedEmail = email.trim();

    if (sanitizedEmail.isEmpty || password.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Email dan password wajib diisi.',
        isSubmitting: false,
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);

    try {
      final response = await _repository.login(
        LoginRequest(email: sanitizedEmail, password: password),
      );

      await _storage.saveToken(response.token);

      state = state.copyWith(
        token: response.token,
        user: response.user,
        isSubmitting: false,
        clearErrorMessage: true,
      );
      return true;
    } on DioException catch (_) {
      state = state.copyWith(
        errorMessage: 'Login gagal. Periksa email/password Anda.',
        isSubmitting: false,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Terjadi kesalahan saat login.',
        isSubmitting: false,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearToken();
    state = state.copyWith(
      clearToken: true,
      clearUser: true,
      clearErrorMessage: true,
      isSubmitting: false,
    );
  }

  Future<void> handleUnauthorized() async {
    if (!state.isAuthenticated) {
      return;
    }
    await logout();
  }
}
