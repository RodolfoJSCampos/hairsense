import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool isLoading = false;
  bool senhaOculta = true;

  final AuthService _authService = AuthService();

  void toggleSenhaVisibilidade() {
    senhaOculta = !senhaOculta;
    notifyListeners();
  }

  Future<String?> registrarUsuario() async {
    final email = emailController.text.trim();
    final senha = senhaController.text;
    final confirmarSenha = confirmarSenhaController.text;

    // 1. Campos obrigatórios
    if (email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
      return 'Preencha todos os campos.';
    }

    // 2. Validação de e-mail
    final emailValido = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailValido.hasMatch(email)) {
      return 'Informe um e-mail válido.';
    }

    // 3. Validação de senha
    if (senha.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres.';
    }

    // 4. Confirmação de senha
    if (senha != confirmarSenha) {
      return 'As senhas não coincidem.';
    }

    // 5. Tentativa de cadastro via AuthService
    try {
      isLoading = true;
      notifyListeners();

      await _authService.cadastrarComEmail(
        email,
        senha,
      ); // ← usando sua função personalizada

      return null; // sucesso
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Este e-mail já está cadastrado.';
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'weak-password':
          return 'Senha fraca. Escolha uma mais segura.';
        default:
          return 'Erro ao cadastrar. Tente novamente.';
      }
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void disposeControllers() {
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
  }
}
