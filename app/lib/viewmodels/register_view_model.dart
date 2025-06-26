import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = false;
  bool senhaOculta = true;

  final AuthService _authService = AuthService();

  void toggleSenhaVisibilidade() {
    senhaOculta = !senhaOculta;
    notifyListeners();
  }

  // Cadastro com Google + criação de documento no Firestore
  Future<String?> registrarComGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      final credencial = await _authService.loginWithGoogle();
      final user = credencial.user;

      if (user != null) {
        // Cria perfil básico no Firestore com nome, e-mail e UID
        await _firestoreService.salvarDadosUsuario(user.uid, {
          'email': user.email,
          'nome': user.displayName,
          'criadoEm': Timestamp.now(),
          'loginGoogle': true,
        });
      }

      return null; // sucesso
    } on FirebaseAuthException catch (e) {
      return _traduzErroFirebase(e.code);
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Cadastro com e-mail e senha padrão
  Future<String?> registrarUsuario() async {
    final email = emailController.text.trim();
    final senha = senhaController.text;
    final confirmarSenha = confirmarSenhaController.text;

    if (email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
      return 'Preencha todos os campos.';
    }

    final emailValido = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailValido.hasMatch(email)) {
      return 'Informe um e-mail válido.';
    }

    if (senha.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres.';
    }

    if (senha != confirmarSenha) {
      return 'As senhas não coincidem.';
    }

    try {
      isLoading = true;
      notifyListeners();

      final credencial = await _authService.cadastrarComEmail(email, senha);
      final uid = credencial.user?.uid;

      if (uid != null) {
        await _firestoreService.salvarDadosUsuario(uid, {
          'email': email,
          'criadoEm': Timestamp.now(),
          'loginGoogle': false,
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return _traduzErroFirebase(e.code);
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Interpreta códigos de erro do Firebase e retorna mensagens amigáveis
  String _traduzErroFirebase(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha fraca. Escolha uma mais segura.';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com este e-mail.';
      case 'user-disabled':
        return 'Conta desativada.';
      default:
        return 'Erro ao cadastrar. Tente novamente.';
    }
  }

  void disposeControllers() {
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
  }
}