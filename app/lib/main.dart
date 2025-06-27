import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'services/usuario_validador_service.dart';
import 'services/theme_controller.dart';

import 'viewmodels/login_view_model.dart';
import 'viewmodels/register_view_model.dart';
import 'viewmodels/ingredients_view_model.dart';  // <– não esqueça deste import!

import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/home_view.dart';
import 'views/ingredients_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Garante perfil criado antes de rodar o app
  await UsuarioValidadorService().validarUsuarioLogadoComPerfil();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, tema, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'HairSense',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: tema.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/login_view',
            routes: {
              '/login_view': (c) => const LoginView(),
              '/register_view': (c) => ChangeNotifierProvider(
                    create: (_) => RegisterViewModel(),
                    child: const RegisterView(),
                  ),
              '/home_view': (c) => const HomeView(),
              '/ingredients_view': (c) => ChangeNotifierProvider(
                    create: (_) => IngredientsViewModel(),
                    child: const IngredientsView(),
                  ),
            },
          );
        },
      ),
    );
  }
}