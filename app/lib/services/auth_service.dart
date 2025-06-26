import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Realiza o login do usuário utilizando e-mail e senha cadastrados
  Future<UserCredential> loginWithEmail(String email, String senha) async {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  // Permite autenticação via conta do Google integrada ao Firebase
  Future<UserCredential> loginWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw FirebaseAuthException(code: 'cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  // Cadastra um novo usuário no Firebase utilizando e-mail e senha
  Future<UserCredential> cadastrarComEmail(String email, String senha) async {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }
}

