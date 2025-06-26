import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

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

      await verificarOuCriarPerfil(); // Garante que perfil seja criado

      return null;
    } on FirebaseAuthException catch (e) {
      print('Erro FirebaseAuth: ${e.code}');
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

      await verificarOuCriarPerfil(); // Garante que perfil seja criado

      return null;
    } on FirebaseAuthException catch (e) {
      return _traduzErroFirebase(e.code);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> recuperarSenha() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      return 'Informe um e-mail para recuperação.';
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
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

  Future<void> verificarOuCriarPerfil() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final docRef =
          FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set({
          'nome': user.displayName ?? 'Usuário',
          'email': user.email ?? '',
          'temaEscuro': false,
          'criadoEm': FieldValue.serverTimestamp(),
        });
      }
    }
  }

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
        return 'E-mail ou senha inválidos.';
      default:
        return 'Erro inesperado ao fazer login.';
    }
  }

  void disposeControllers() {
    emailController.dispose();
    senhaController.dispose();
  }
}