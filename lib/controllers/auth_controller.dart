import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? 'dummy-client-id.apps.googleusercontent.com' : null,
  );

  User? get user => _auth.currentUser;
  bool get isLoggedIn => user != null;

  AuthController() {
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Limpa a sessão em cache para que o seletor de contas do Google
      // sempre seja exibido, em vez de logar direto com a última conta usada.
      await _googleSignIn.signOut();
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      notifyListeners();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (defaultTargetPlatform != TargetPlatform.windows) {
      await _googleSignIn.signOut();
    }
    notifyListeners();
  }
}