import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Salva ou atualiza os dados de perfil do usuário
  Future<void> salvarDadosUsuario(String uid, Map<String, dynamic> dados) async {
    await _db.collection('usuarios').doc(uid).set(
      dados,
      SetOptions(merge: true), // Mantém campos existentes
    );
  }

  /// Busca os dados de um usuário específico
  Future<DocumentSnapshot> buscarUsuario(String uid) async {
    return await _db.collection('usuarios').doc(uid).get();
  }

  /// Escuta mudanças no documento do usuário
  Stream<DocumentSnapshot> escutarUsuario(String uid) {
    return _db.collection('usuarios').doc(uid).snapshots();
  }

  /// Atualiza somente um campo do usuário (ex: tema, nome)
  Future<void> atualizarCampoUsuario(String uid, String campo, dynamic valor) async {
    await _db.collection('usuarios').doc(uid).update({campo: valor});
  }
}