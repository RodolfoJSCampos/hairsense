import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

class IngredientsViewModel extends ChangeNotifier {
  final List<IngredientModel> _all = [];
  List<IngredientModel> displayed = [];

  static const int _pageSize = 20;
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;

  // 1) nova lista de selecionados
  final List<IngredientModel> selected = [];

  Future<void> init() async {
    try {
      isLoading = true;
      hasError = false;
      notifyListeners();

      final raw = await rootBundle.loadString('assets/data/cosing_dados_pt-br.json');
      final data = json.decode(raw);
      final listDynamic = (data is List)
          ? data
          : (data is Map)
              ? data.values.toList()
              : <dynamic>[];

      // popula _all
      for (final e in listDynamic) {
        _all.add(IngredientModel.fromJson(e as Map<String, dynamic>));
      }
      // exibe primeira página
      displayed = _all.take(_pageSize).toList();
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
    final nextMax = displayed.length + _pageSize;
    displayed = _all.take(nextMax).toList();
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

  // 2) método para (des)marcar selecionado
  void toggleSelected(IngredientModel ing) {
    if (selected.contains(ing)) {
      selected.remove(ing);
    } else {
      selected.add(ing);
    }
    notifyListeners();
  }

  // 3) opcional: limpar todos os selecionados
  void clearSelected() {
    selected.clear();
    notifyListeners();
  }
}