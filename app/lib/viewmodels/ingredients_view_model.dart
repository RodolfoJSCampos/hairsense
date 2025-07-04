import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_model.dart';
import '../services/firestore_service.dart';

class IngredientsViewModel extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  static const int _pageSize = 20;

  final List<IngredientModel> displayed = [];
  final Set<String> _fetchedIds = {};
  final Set<String> _fetchedNames = {}; // ← novo set de nomes

  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  bool hasMore = true;
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;
  String _currentFilter = '';
  final List<IngredientModel> selected = [];

  Future<void> init() async {
    displayed.clear();
    _fetchedIds.clear();
    _fetchedNames.clear(); // limpa nomes
    _lastDoc = null;
    _currentFilter = '';
    hasMore = true;
    await fetchNextPage();
  }

  Future<void> search(String query) async {
    displayed.clear();
    _fetchedIds.clear();
    _fetchedNames.clear(); // limpa nomes
    _lastDoc = null;
    _currentFilter = query.trim().toLowerCase();
    hasMore = true;
    await fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final page = await _service.fetchIngredientsPage(
        startAfter: _lastDoc,
        pageSize: _pageSize,
        filter: _currentFilter,
      );

      for (var ing in page.items) {
        final name = ing.inciName.trim().toLowerCase();
        // só adiciona se ID e nome forem únicos
        if (_fetchedIds.add(ing.cosingRef) && _fetchedNames.add(name)) {
          displayed.add(ing);
        }
      }

      _lastDoc = page.lastDoc;
      if (page.items.length < _pageSize) {
        hasMore = false;
      }
    } catch (e, st) {
      hasError = true;
      errorMessage = e.toString();
      debugPrint('❌ fetchNextPage erro: $e\n$st');
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
