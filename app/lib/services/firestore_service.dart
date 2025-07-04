import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_model.dart';

/// Resultado de uma página paginada de ingredientes
class PaginatedIngredients {
  final List<IngredientModel> items;
  final DocumentSnapshot? lastDoc; // cursor para próxima página

  PaginatedIngredients({required this.items, this.lastDoc});
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// --- SEUS MÉTODOS ATUAIS DE USUÁRIO ---
  Future<void> salvarDadosUsuario(
    String uid,
    Map<String, dynamic> dados,
  ) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .set(dados, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> buscarUsuario(String uid) async {
    return _db.collection('usuarios').doc(uid).get();
  }

  Stream<DocumentSnapshot> escutarUsuario(String uid) {
    return _db.collection('usuarios').doc(uid).snapshots();
  }

  Future<void> atualizarCampoUsuario(
    String uid,
    String campo,
    dynamic valor,
  ) async {
    await _db.collection('usuarios').doc(uid).update({campo: valor});
  }

  Future<PaginatedIngredients> fetchIngredientsPage({
    DocumentSnapshot? startAfter,
    int pageSize = 10,
    String filter = '',
  }) async {
    Query query = _db
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

    final snap = await query.get();

    final items = <IngredientModel>[];
    for (var doc in snap.docs) {
      // 1) data pode ser nulo => Map<String,dynamic>?
      final data = doc.data() as Map<String, dynamic>?;

      // 2) preenchemos um JSON seguro
      final json = <String, dynamic>{'cosingRef': doc.id};
      if (data != null) {
        json.addAll(data);
      }

      // 3) convertemos pro nosso model
      items.add(IngredientModel.fromJson(json));
    }

    final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
    return PaginatedIngredients(items: items, lastDoc: lastDoc);
  }
}
