import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'viewmodels/login_view_model.dart';
import 'views/login_view.dart';
import 'services/theme_controller.dart'; // ← importa o controller que criamos

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa o Firebase
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
            home: const LoginView(),
          );
        },
      ),
    );
  }
}