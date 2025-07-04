import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'services/services.dart';
import 'viewmodels/viewmodels.dart';
import 'views/views.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();

  // Ativa persistência e define cache ilimitado
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

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
        ChangeNotifierProvider(create: (_) => IngredientsViewModel()),
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
              '/register_view':
                  (c) => ChangeNotifierProvider(
                    create: (_) => RegisterViewModel(),
                    child: const RegisterView(),
                  ),
              '/home_view':
                  (c) => ChangeNotifierProvider(
                    create: (_) => HomeViewModel(),
                    child: const HomeView(),
                  ),
              '/ingredients_view':
                  (c) => ChangeNotifierProvider(
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
