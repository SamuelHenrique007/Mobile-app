import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Cadastrar usuário com nome, email e senha
  Future<User?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user != null) {
      // Salva dados básicos no Firestore
      await _db.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Envia e-mail de verificação
      await user.sendEmailVerification();
    }

    return user;
  }

  /// Login com email e senha
  Future<User?> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Usuário logado atualmente (pode ser null)
  User? get currentUser => _auth.currentUser;

  /// Recarrega o usuário (útil pra ver se email foi verificado)
  Future<User?> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return _auth.currentUser;
    }
    return null;
  }
}
