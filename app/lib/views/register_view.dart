import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_view_model.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  // Exibe um alerta simples com título e mensagem — usado para feedback de erro ou sucesso
  void _mostrarAlerta(BuildContext context, String titulo, String mensagem) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    final cadastroVM = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Exibe o logotipo da aplicação
              Center(child: Image.asset('assets/LogoMain.png', height: 140)),

              const SizedBox(height: 40),

              // Campo de e-mail com validação
              TextField(
                controller: cadastroVM.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDeco('E-mail'),
              ),

              const SizedBox(height: 16),

              // Campo de senha com botão para alternar visibilidade
              TextField(
                controller: cadastroVM.senhaController,
                obscureText: cadastroVM.senhaOculta,
                decoration: _inputDeco('Senha').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      cadastroVM.senhaOculta
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[700],
                    ),
                    onPressed: cadastroVM.toggleSenhaVisibilidade,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Campo para confirmar a senha digitada
              TextField(
                controller: cadastroVM.confirmarSenhaController,
                obscureText: true,
                decoration: _inputDeco('Repita a senha'),
              ),

              const SizedBox(height: 24),

              // Botão "Criar Conta" com loading e tratamento de erro
              cadastroVM.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: () async {
                      final erro = await cadastroVM.registrarUsuario();
                      if (erro != null) {
                        _mostrarAlerta(context, 'Erro', erro);
                      } else {
                        _mostrarAlerta(
                          context,
                          'Sucesso',
                          'Usuário cadastrado com sucesso!',
                        );
                        Navigator.pop(
                          context,
                        ); // Volta para a tela anterior (Login)
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Criar Conta'),
                  ),

              const SizedBox(height: 16),

              // Botão pra cadastro com Google
              OutlinedButton.icon(
                onPressed: () async {
                  final erro = await cadastroVM.registrarComGoogle();
                  if (erro != null) {
                    _mostrarAlerta(context, 'Erro', erro);
                  } else {
                    _mostrarAlerta(
                      context,
                      'Sucesso',
                      'Cadastro com Google realizado!',
                    );
                    Navigator.pop(
                      context,
                    ); // ou redireciona pra tela principal se quiser
                  }
                },
                icon: Image.asset(
                  'assets/google_logo.png',
                  height: 20,
                  width: 20,
                ),
                label: const Text('Sign up with Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),

              // Botão "Voltar" para retornar à tela de login
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '< Voltar',
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

  // Estilo reutilizável para os campos de texto
  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent),
      ),
    );
  }
}
