import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Busca ou cria o documento do usuário no Firestore ─────────────────────
  Future<UserModel?> fetchOrCreateUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }

    // Primeira vez logando → cria documento com dados do Google
    final novoUsuario = UserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL ?? '',
    );
    await ref.set(novoUsuario.toMap());
    return novoUsuario;
  }

  // ── Atualiza dados do usuário ─────────────────────────────────────────────
  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(user.toMap());
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }
}