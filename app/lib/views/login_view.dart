import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_view_model.dart';
import '../viewmodels/register_view_model.dart';
import '../views/register_view.dart';

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

  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<LoginViewModel>(context);
    final tamanho = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                  controller: loginVM.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDeco('E-mail'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: loginVM.senhaController,
                  obscureText: loginVM.senhaOculta,
                  decoration: _inputDeco('Senha').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        loginVM.senhaOculta ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[700],
                      ),
                      onPressed: loginVM.toggleSenhaVisibilidade,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                loginVM.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          final erro = await loginVM.loginComEmail();
                          if (erro != null) {
                            _mostrarAlerta(context, 'Erro', erro);
                          } else {
                            _mostrarAlerta(context, 'Sucesso', 'Login realizado!');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Entrar'),
                      ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final erro = await loginVM.loginComGoogle();
                    if (erro != null) {
                      _mostrarAlerta(context, 'Erro', erro);
                    } else {
                      _mostrarAlerta(context, 'Sucesso', 'Login com Google realizado!');
                    }
                  },
                  icon: Image.asset('assets/google_logo.png', height: 20, width: 20),
                  label: const Text('Entrar com Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.grey),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => RegisterViewModel(),
                          child: const RegisterView(),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Realizar cadastro',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
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