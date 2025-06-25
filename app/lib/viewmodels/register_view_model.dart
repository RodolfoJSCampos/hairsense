import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
    if (
        emailController.text.isEmpty ||
        senhaController.text.isEmpty) {
      return 'Preencha todos os campos.';
    }
    if (senhaController.text != confirmarSenhaController.text) {
  return 'As senhas não coincidem.';
}

    try {
      isLoading = true;
      notifyListeners();

      await _authService.cadastrarComEmail(
        emailController.text,
        senhaController.text,
      );

      return null;
    } on Exception catch (e) {
      return 'Erro ao cadastrar: ${e.toString()}';
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