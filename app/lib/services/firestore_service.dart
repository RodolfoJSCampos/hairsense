import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_model.dart';

/// Resultado de uma página paginada de ingredientes
class PaginatedIngredients {
  final List<IngredientModel> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;

  PaginatedIngredients({required this.items, this.lastDoc});
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Salva dados do usuário
  Future<void> salvarDadosUsuario(
    String uid,
    Map<String, dynamic> dados,
  ) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .set(dados, SetOptions(merge: true));
  }

  /// Busca um documento de usuário
  Future<DocumentSnapshot<Map<String, dynamic>>> buscarUsuario(
    String uid,
  ) async {
    return _db.collection('usuarios').doc(uid).get();
  }

  /// Stream de atualizações do usuário
  Stream<DocumentSnapshot<Map<String, dynamic>>> escutarUsuario(
    String uid,
  ) {
    return _db.collection('usuarios').doc(uid).snapshots();
  }

  /// Atualiza um campo específico do usuário
  Future<void> atualizarCampoUsuario(
    String uid,
    String campo,
    dynamic valor,
  ) async {
    await _db.collection('usuarios').doc(uid).update({campo: valor});
  }

  /// Busca uma página de ingredientes, paginada e opcionalmente filtrada
  Future<PaginatedIngredients> fetchIngredientsPage({
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int pageSize = 20,
    String filter = '',
  }) async {
    // Monta a query tipada
    Query<Map<String, dynamic>> query = _db
        .collection('ingredients')
        .orderBy('inciName')
        .limit(pageSize);

    if (filter.isNotEmpty) {
      final term = filter.toLowerCase().trim();
      query = query.startAt([term]).endAt(['$term\uf8ff']);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    // Executa a query
    final snap = await query.get();

    // LOG #1: imprime todos os IDs que o Firestore devolveu
    debugPrint(
      '🆔 snap.docs IDs: [${snap.docs.map((d) => d.id).join(', ')}]',
    );

    // Converte cada doc usando o factory que garante cosingRef = doc.id
    final items = snap.docs.map((doc) {
      // LOG #2: payload bruto
      debugPrint(
        '   • raw doc.id=${doc.id}, data keys=${doc.data().keys.toList()}',
      );
      return IngredientModel.fromFirestore(doc);
    }).toList();

    final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
    return PaginatedIngredients(items: items, lastDoc: lastDoc);
  }
}