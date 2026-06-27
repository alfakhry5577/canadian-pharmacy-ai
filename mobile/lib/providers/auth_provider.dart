import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import 'core_providers.dart';

enum AuthStatus { bootstrapping, unauthenticated, authenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? token;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.token, this.errorMessage});

  const AuthState.initial() : this(status: AuthStatus.bootstrapping);

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({AuthStatus? status, UserModel? user, String? token, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(const AuthState.initial()) {
    _bootstrap();
  }

  final Ref ref;

  Future<void> _bootstrap() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.readToken();
    if (token == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    final result = await ref.read(authRepositoryProvider).me();
    result.when(
      success: (user) => state = AuthState(status: AuthStatus.authenticated, user: user, token: token),
      failure: (_) async {
        await storage.deleteToken();
        state = const AuthState(status: AuthStatus.unauthenticated);
      },
    );
  }

  Future<bool> login({required String email, required String password}) async {
    final result = await ref.read(authRepositoryProvider).login(email: email, password: password);
    return result.when(
      success: (data) async {
        await ref.read(secureStorageProvider).saveToken(data.token);
        state = AuthState(status: AuthStatus.authenticated, user: data.user, token: data.token);
        return true;
      },
      failure: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    String role = 'customer',
  }) async {
    final result = await ref.read(authRepositoryProvider).register(
          fullName: fullName,
          email: email,
          phone: phone,
          password: password,
          role: role,
        );
    return result.when(
      success: (data) async {
        await ref.read(secureStorageProvider).saveToken(data.token);
        state = AuthState(status: AuthStatus.authenticated, user: data.user, token: data.token);
        return true;
      },
      failure: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Invoked by the Dio auth interceptor on any 401 response.
  void handleUnauthorized() {
    if (state.status == AuthStatus.authenticated) {
      ref.read(secureStorageProvider).clearAll();
      state = const AuthState(status: AuthStatus.unauthenticated, errorMessage: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجددًا');
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
