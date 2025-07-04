
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_model.dart';
import '../services/firestore_service.dart';

class IngredientsViewModel extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  static const int _pageSize = 20;

  final List<IngredientModel> displayed = [];
  DocumentSnapshot? _lastDoc;
  bool hasMore = true;

  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;

  // busca atual (para pesquisa incremental)
  String _currentFilter = '';

  // selecionados
  final List<IngredientModel> selected = [];

  /// Carrega a primeira página (sem filtro)
  Future<void> init() async {
    _lastDoc = null;
    _currentFilter = '';
    hasMore = true;
    displayed.clear();
    await fetchNextPage();
  }

  /// Pesquisa (texto) — reseta tudo e carrega a página 1 com filtro
  Future<void> search(String query) async {
    _lastDoc = null;
    _currentFilter = query.trim().toLowerCase();
    hasMore = true;
    displayed.clear();
    await fetchNextPage();
  }

  /// Chama ao rolar para baixo
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

      // adiciona novos itens
      displayed.addAll(page.items);

      // prepara cursor para a próxima página
      _lastDoc = page.lastDoc;

      // se veio menos que o solicitado, acabou
      if (page.items.length < _pageSize) {
        hasMore = false;
      }
    } catch (e, st) {
      hasError = true;
      errorMessage = e.toString();
      debugPrint('❌ erro ao carregar página de ingredientes: $e\n$st');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// (des)marcar selecionado
  void toggleSelected(IngredientModel ing) {
    if (selected.contains(ing)) {
      selected.remove(ing);
    } else {
      selected.add(ing);
    }
    notifyListeners();
  }

  /// limpa todos os selecionados
  void clearSelected() {
    selected.clear();
    notifyListeners();
  }

  /// reordena a lista de selecionados
  void reorderSelected(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = selected.removeAt(oldIndex);
    selected.insert(newIndex, item);
    notifyListeners();
  }
}