import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode temaAtual = ThemeMode.light;

  void alternarTema() {
    temaAtual =
        temaAtual == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}