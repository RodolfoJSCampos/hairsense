// lib/viewmodels/products_view_model.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

import '../models/models.dart';
import 'ingredients_view_model.dart';   // <— importa AnalysisResult


class ProductsViewModel extends ChangeNotifier {
  final List<Product> _all = [];
  List<Product> displayed = [];

  final List<IngredientModel> _allIngredients = [];
  final Map<String, String> _functionDefinitions = {};

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
  late final Set<String> _excipientKeysNorm =
      _excipientFunctionKeys.map(_normalize).toSet();

  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  Future<void> init() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      // 1) produtos
      final prodJson =
          await rootBundle.loadString('assets/data/hair_filtered.json');
      final List prodList = json.decode(prodJson) as List;
      _all
        ..clear()
        ..addAll(prodList.map((e) => Product.fromJson(e)));

      // 2) COSING ingredientes
      final cosingJson =
          await rootBundle.loadString('assets/data/cosing_dados_pt-br.json');
      final dynamic cosingData = json.decode(cosingJson);
      final List rawIngredientList = cosingData is List
          ? cosingData
          : (cosingData is Map ? cosingData.values.toList() : []);
      _allIngredients
        ..clear()
        ..addAll(rawIngredientList
            .map((e) => IngredientModel.fromJson(e as Map<String, dynamic>)));

      // 3) definições de função
      final funcsJson =
          await rootBundle.loadString('assets/data/funcoes_cosmeticos.json');
      final List funcsList = json.decode(funcsJson) as List;
      for (var item in funcsList) {
        final key = (item['funcao_ingles'] as String).toLowerCase();
        _functionDefinitions[key] = item['definicao'] as String;
      }

      displayed = List<Product>.from(_all);
    } catch (e, st) {
      hasError = true;
      errorMessage = e.toString();
      debugPrint('❌ init error: $e\n$st');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  static String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[\s\-_]'), '');

  bool _isExcipient(String func) {
    final norm = _normalize(func);
    return _excipientKeysNorm.any((exc) => norm.contains(exc));
  }

  String getFunctionDefinition(String func) {
    return _functionDefinitions[func.toLowerCase()] ??
        'Definição não encontrada para "$func".';
  }

  /// Retorna as top funções de um produto
  List<String> getFunctionsFor(Product product, {int maxFuncs = 3}) {
    final counts = <String, int>{};
    final ingrList = product.ingredients;
    final total = ingrList.length;

    for (var i = 0; i < total; i++) {
      final rawName = ingrList[i].toLowerCase();
      final idx = _allIngredients.indexWhere(
        (ing) => ing.inciName.toLowerCase() == rawName,
      );
      if (idx == -1) continue;

      final ingModel = _allIngredients[idx];
      final weight = total - i;

      for (var func in ingModel.functions) {
        if (_isExcipient(func)) continue;
        counts[func] = (counts[func] ?? 0) + weight;
      }
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(maxFuncs).map((e) => e.key).toList();
  }

  /// Entrega um AnalysisResult para a tela de análise
  AnalysisResult analysisResult(Product product) {
    final topFuncs = getFunctionsFor(product);

    final topIngs = product.ingredients
        .map((inci) => _allIngredients.firstWhereOrNull(
              (ing) => ing.inciName.toLowerCase() == inci.toLowerCase(),
            ))
        .whereType<IngredientModel>()
        .toList();

    return AnalysisResult(
      topFunctions: topFuncs,
      topIngredients: topIngs,
    );
  }

  void search(String term) {
    final q = term.trim().toLowerCase();
    displayed = q.isEmpty
        ? List<Product>.from(_all)
        : _all.where((p) => p.name.toLowerCase().contains(q)).toList();
    notifyListeners();
  }
}