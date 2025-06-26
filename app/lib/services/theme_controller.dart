import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void alternarTema() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}