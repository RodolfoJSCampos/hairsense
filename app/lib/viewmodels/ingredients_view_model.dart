import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class IngredientsViewModel extends ChangeNotifier {
  final List<IngredientModel> _all = [];
  List<IngredientModel> displayed = [];

  static const int _pageSize = 20;
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;

  // Lista de ingredientes selecionados
  final List<IngredientModel> selected = [];

  Future<void> init() async {
    try {
      isLoading = true;
      hasError = false;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('ingredients')
          .orderBy('inciName')
          .get();

      _all.clear();
      for (final doc in snapshot.docs) {
        _all.add(IngredientModel.fromJson(doc.data()));
      }

      displayed = _all.take(_pageSize).toList();
    } catch (e, st) {
      hasError = true;
      errorMessage = e.toString();
      debugPrint('❌ erro ao carregar ingredientes do Firestore: $e\n$st');
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

  void toggleSelected(IngredientModel ing) {
    if (selected.contains(ing)) {
      selected.remove(ing);
    } else {
      selected.add(ing);
    }
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