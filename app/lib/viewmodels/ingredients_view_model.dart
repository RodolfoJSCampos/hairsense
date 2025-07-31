// lib/viewmodels/ingredients_view_model.dart

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

import '../models/models.dart';

/// Contém as principais funções e ingredientes após análise
class AnalysisResult {
  final List<String> topFunctions;
  final List<IngredientModel> topIngredients;

  AnalysisResult({
    required this.topFunctions,
    required this.topIngredients,
  });
}

class IngredientsViewModel extends ChangeNotifier {
  final List<IngredientModel> _all = [];
  List<IngredientModel> get allIngredients => _all;
  List<IngredientModel> displayed = [];

  static const int _pageSize = 20;
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;

  /// Os ingredientes que o usuário selecionou, na ordem definida por ele.
  final List<IngredientModel> selected = [];

  // --------------------------------------------------------------------------
  // 1) Defina aqui suas funções-excipientes
  static const List<String> _excipientFunctionKeys = [
    'solvent',
    'surfactant',
    'emollient',
    'humectant',
    'film forming',
    'stabilising',
    'stabilizer',
    'antistatic',
  ];

  /// Chaves normalizadas (lower + sem espaço/hífen/_) para comparação
  late final Set<String> _excipientKeysNormalized = _excipientFunctionKeys
      .map((f) => f.toLowerCase().replaceAll(RegExp(r'[\s\-_]'), ''))
      .toSet();

  String _normalize(String s) =>
      s.toLowerCase().trim().replaceAll(RegExp(r'[\s\-_]'), '');

  /// Retorna true se [func] contiver qualquer excipiente por substring
  bool _isExcipientFunction(String func) {
    final norm = _normalize(func);
    return _excipientKeysNormalized.any((exc) => norm.contains(exc));
  }

  // --------------------------------------------------------------------------
  // 2) Mapa de definições de funções cosméticas (do JSON)
  late final Map<String, String> functionDefinitions;

  /// Retorna a definição para uma função (case-insensitive).
  String getFunctionDefinition(String func) {
    final key = func.toLowerCase();
    return functionDefinitions[key] ??
        'Definição não encontrada para "$func".';
  }

  // --------------------------------------------------------------------------
  // 3) Ingredientes válidos para análise
  /// Exclui ingredientes que tenham qualquer função-excipiente
  List<IngredientModel> get _ingredientsForAnalysis {
    return selected.where((ing) {
      return !ing.functions.any(_isExcipientFunction);
    }).toList();
  }

  // --------------------------------------------------------------------------
  // 4) Cálculo de pesos e resultado da análise
  /// Agora aceita opcionalmente nomes INCI de um produto
  AnalysisResult analyze({
    List<String>? inciNames,
    int maxFuncs = 3,
    int maxIngs = 3,
  }) {
    // 1) Constrói a lista-base usando firstWhereOrNull para evitar retorno nulo incorreto
    final rawList = inciNames != null
        ? inciNames
            .map((name) => _all.firstWhereOrNull(
                  (i) => i.inciName.toLowerCase() == name.toLowerCase(),
                ))
            .whereType<IngredientModel>()
            .toList()
        : _ingredientsForAnalysis;

    // 2) Pontua funções não-excipientes nos até 5 primeiros itens
    final scores = <String, int>{};
    for (var i = 0; i < min(rawList.length, 5); i++) {
      final weight = 5 - i;
      for (final func in rawList[i].functions) {
        if (_isExcipientFunction(func)) continue;
        scores[func] = (scores[func] ?? 0) + weight;
      }
    }

    // 3) Ordena e extrai top funções
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topFunctions =
        sorted.take(maxFuncs).map((e) => e.key).toList();

    // 4) Pega até maxIngs ingredientes filtrados
    final topIngredients = rawList.take(maxIngs).toList();

    return AnalysisResult(
      topFunctions: topFunctions,
      topIngredients: topIngredients,
    );
  }

  // ========================================================================
  // 5) Inicialização, paginação, pesquisa, seleção e reorder
  // ========================================================================

  Future<void> init() async {
    try {
      isLoading = true;
      hasError = false;
      notifyListeners();

      // Carrega COSING ingredientes
      final rawIng =
          await rootBundle.loadString('assets/data/cosing_dados_pt-br.json');
      final data = json.decode(rawIng);
      final listDynamic = data is List
          ? data
          : data is Map
              ? data.values.toList()
              : <dynamic>[];

      _all.clear();
      for (final e in listDynamic) {
        _all.add(IngredientModel.fromJson(e as Map<String, dynamic>));
      }
      displayed = _all.take(_pageSize).toList();

      // Carrega definições de funções
      final rawFuncs =
          await rootBundle.loadString('assets/data/funcoes_cosmeticos.json');
      final listaFuncoes = json.decode(rawFuncs) as List<dynamic>;
      functionDefinitions = {
        for (var item in listaFuncoes)
          (item['funcao_ingles'] as String).toLowerCase():
              (item['definicao'] as String)
      };
    } catch (e, st) {
      hasError = true;
      errorMessage = e.toString();
      debugPrint('❌ erro ao init ingredients: $e\n$st');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void loadMore() {
    if (isLoading || displayed.length >= _all.length) return;
    displayed = _all.take(displayed.length + _pageSize).toList();
    notifyListeners();
  }

  void search(String query) {
    final q = query.toLowerCase().trim();
    final filtered = _all.where((ing) {
      return ing.inciName.toLowerCase().contains(q) ||
          ing.description.toLowerCase().contains(q);
    }).toList();
    displayed = filtered.take(_pageSize).toList();
    notifyListeners();
  }

  void toggleSelected(IngredientModel ing) {
    if (selected.contains(ing))
      selected.remove(ing);
    else
      selected.add(ing);
    notifyListeners();
  }

  void clearSelected() {
    selected.clear();
    notifyListeners();
  }

  void reorderSelected(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = selected.removeAt(oldIndex);
    selected.insert(newIndex, item);
    notifyListeners();
  }
}