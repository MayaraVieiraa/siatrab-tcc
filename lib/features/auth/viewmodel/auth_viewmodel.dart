import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;
  final String? userEmail;
  final String? userName;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
    this.userEmail,
    this.userName,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
    String? userEmail,
    String? userName,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage ?? this.errorMessage,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
    );
  }
}

class AuthViewModel extends Notifier<AuthState> {
  final _auth = FirebaseAuth.instance;

  @override
  AuthState build() {
    // Verifica se já há usuário logado ao abrir o app
    final user = _auth.currentUser;
    if (user != null) {
      return AuthState(
        isAuthenticated: true,
        userEmail: user.email,
        userName: user.displayName ?? 'Usuário',
      );
    }
    return const AuthState();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userEmail: user.email,
        userName: user.displayName ?? 'Usuário',
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _translateError(e.code),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro de conexão. Tente novamente.',
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Salva o nome no perfil do Firebase
      await credential.user!.updateDisplayName(name);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userEmail: email,
        userName: name,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _translateError(e.code),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao cadastrar. Tente novamente.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  String _translateError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'email-already-in-use':
        return 'Este email já está cadastrado.';
      case 'weak-password':
        return 'Senha muito fraca. Use no mínimo 6 caracteres.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos.';
      case 'invalid-credential':
        return 'Email ou senha inválidos.';
      default:
        return 'Erro de autenticação. Tente novamente.';
    }
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);
