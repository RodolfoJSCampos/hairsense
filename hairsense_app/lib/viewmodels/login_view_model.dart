import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool isLoading = false;
  bool senhaOculta = true;

  final AuthService _authService = AuthService();

  void toggleSenhaVisibilidade() {
    senhaOculta = !senhaOculta;
    notifyListeners();
  }

  Future<String?> loginComEmail() async {
    if (emailController.text.isEmpty || senhaController.text.isEmpty) {
      return 'Preencha todos os campos.';
    }

    try {
      isLoading = true;
      notifyListeners();

      await _authService.loginWithEmail(
        emailController.text,
        senhaController.text,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return _traduzErroFirebase(e.code);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> loginComGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.loginWithGoogle();

      return null;
    } on FirebaseAuthException catch (e) {
      return _traduzErroFirebase(e.code);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _traduzErroFirebase(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'user-disabled':
        return 'Usuário desativado.';
      default:
        return 'Erro ao fazer login. Tente novamente.';
    }
  }

  void disposeControllers() {
    emailController.dispose();
    senhaController.dispose();
  }
}