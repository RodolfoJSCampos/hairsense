import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuarioValidadorService {
  Future<bool> validarUsuarioLogadoComPerfil() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return false;

    final docRef =
        FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Se não existir, cria com dados mínimos
      await docRef.set({
        'email': user.email ?? '',
        'temaEscuro': false,
        'criadoEm': FieldValue.serverTimestamp(),
      });
    }

    return true;
  }
}