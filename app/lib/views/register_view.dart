import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_view_model.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

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

  @override
  Widget build(BuildContext context) {
    final cadastroVM = Provider.of<RegisterViewModel>(context);
    final tamanho = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: Colors.blue[900],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: tamanho.height - 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: cadastroVM.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDeco('E-mail'),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                cadastroVM.isLoading
                    ? const CircularProgressIndicator()
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
                            // Voltar para tela de login após cadastro (opcional):
                            // Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Cadastrar'),
                      ),
              ],
            ),
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
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent),
      ),
    );
  }
}