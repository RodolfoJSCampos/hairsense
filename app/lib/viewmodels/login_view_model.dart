import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginViewModel extends ChangeNotifier {
  // Controladores para os campos de e-mail e senha na tela de login
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool isLoading =
      false; // Usado para exibir indicador de progresso durante login
  bool senhaOculta = true; // Controla visibilidade do campo de senha

  final AuthService _authService =
      AuthService(); // Serviço responsável pela autenticação

  // Alterna entre mostrar ou ocultar a senha digitada
  void toggleSenhaVisibilidade() {
    senhaOculta = !senhaOculta;
    notifyListeners();
  }

  // Realiza login com e-mail e senha utilizando o AuthService
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

      return null; // Login bem-sucedido
    } on FirebaseAuthException catch (e) {
      print('Erro FirebaseAuth: ${e.code}'); // <-- Esse print aqui
      return _traduzErroFirebase(e.code);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Realiza login com uma conta do Google integrada ao Firebase
  Future<String?> loginComGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.loginWithGoogle();

      return null; // Login com Google bem-sucedido
    } on FirebaseAuthException catch (e) {
      return _traduzErroFirebase(e.code); // Erro amigável
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Envia e-mail de recuperação de senha para o e-mail informado
  Future<String?> recuperarSenha() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      return 'Informe um e-mail para recuperação.';
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null; // E-mail enviado com sucesso
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'user-not-found':
          return 'E-mail não está cadastrado.';
        default:
          return 'Erro ao enviar e-mail de recuperação.';
      }
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    }
  }

  // Converte códigos de erro do Firebase em mensagens amigáveis para o usuário
  String _traduzErroFirebase(String code) {
    switch (code) {
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'too-many-requests':
        return 'Muitas tentativas falhas. Tente mais tarde.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet.';
      case 'invalid-credential':
        return 'e-mail ou senha inválidas.';
      default:
        return 'Erro inesperado ao fazer login.';
    }
  }

  // Libera os recursos dos TextEditingControllers quando não forem mais usados
  void disposeControllers() {
    emailController.dispose();
    senhaController.dispose();
  }
}
