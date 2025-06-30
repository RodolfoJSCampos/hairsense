// lib/viewmodels/ingredients_view_model.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/ingredient_model.dart';

class IngredientsViewModel extends ChangeNotifier {
  final List<IngredientModel> _all = [];
  List<IngredientModel> displayed = [];

  // estados para a UI
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;

  /// Carrega o JSON primeiro parcial (20 itens) e depois completa
  Future<void> init() async {
    try {
      isLoading = true;
      hasError = false;
      notifyListeners();

      // 1) carrega raw JSON
      final raw =
          await rootBundle.loadString('assets/data/cosing_dados_pt-br.json');
      debugPrint('🔍 JSON carregado: ${raw.length} chars');

      // 2) decodifica
      final data = json.decode(raw);
      final listDynamic = (data is List) 
        ? data 
        : (data is Map) 
            ? data.values.toList() 
            : <dynamic>[];

      debugPrint('🔍 itens totais no JSON: ${listDynamic.length}');

      // 3) mostra rápido os primeiros 20
      displayed = listDynamic
          .take(20)
          .map((e) => IngredientModel.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();

      // 4) preenche _all completinho
      for (final e in listDynamic) {
        _all.add(IngredientModel.fromJson(e as Map<String, dynamic>));
      }
      debugPrint('🔍 lista completa: ${_all.length} ingredientes');
    } catch (e, st) {
      hasError = true;
      errorMessage = e.toString();
      debugPrint('❌ erro ao carregar ingredientes: $e\n$st');
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// filtra por nome ou inci name nos _all e atualiza displayed
  void search(String query) {
    final q = query.toLowerCase();
    final filtered = _all.where((ing) {
      return ing.inciName.toLowerCase().contains(q) ||
             ing.inciName.toLowerCase().contains(q);
    }).toList();

    displayed = filtered.take(20).toList();
    notifyListeners();
  }
}