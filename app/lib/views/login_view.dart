import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/services.dart';         
import '../viewmodels/viewmodels.dart';     
import '../widgets/widgets.dart';           

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  void _mostrarAlerta(BuildContext context, String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _aplicarTemaSalvo(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();
    final temaEscuro = doc.data()?['temaEscuro'] ?? false;
    Provider.of<ThemeController>(context, listen: false)
        .alternarTema(temaEscuro);
  }

  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<LoginViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Image.asset('assets/LogoMain.png', height: 140),
              ),
              const SizedBox(height: 40),

              // E-mail
              TextField(
                controller: loginVM.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDeco('E-mail'),
              ),

              const SizedBox(height: 20),

              // Senha
              TextField(
                controller: loginVM.senhaController,
                obscureText: loginVM.senhaOculta,
                decoration: _inputDeco('Senha').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      loginVM.senhaOculta
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey.shade700,
                    ),
                    onPressed: loginVM.toggleSenhaVisibilidade,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final erro = await loginVM.recuperarSenha();
                    if (erro != null) {
                      _mostrarAlerta(context, 'Erro', erro);
                    } else {
                      _mostrarAlerta(
                        context,
                        'Sucesso',
                        'E-mail de recuperação enviado!',
                      );
                    }
                  },
                  child: const Text('Esqueci minha senha...'),
                ),
              ),

              const SizedBox(height: 20),

              // Botão Entrar
              loginVM.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        final erro = await loginVM.loginComEmail();
                        if (erro != null) {
                          _mostrarAlerta(context, 'Erro', erro);
                        } else {
                          await _aplicarTemaSalvo(context);
                          Navigator.pushReplacementNamed(
                            context,
                            '/home_view',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Entrar'),
                    ),

              const SizedBox(height: 16),

              // Entrar com Google
              OutlinedButton.icon(
                onPressed: () async {
                  final erro = await loginVM.loginComGoogle();
                  if (erro != null) {
                    _mostrarAlerta(context, 'Erro', erro);
                  } else {
                    await _aplicarTemaSalvo(context);
                    Navigator.pushReplacementNamed(
                      context,
                      '/home_view',
                    );
                  }
                },
                icon: Image.asset(
                  'assets/google_logo.png',
                  height: 20,
                  width: 20,
                ),
                label: const Text('Entrar com Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),

              // Link para cadastro
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register_view');
                  },
                  child: const Text(
                    'Realizar cadastro',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent),
      ),
    );
  }
}