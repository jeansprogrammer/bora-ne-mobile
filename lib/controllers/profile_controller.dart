import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _service = ProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? currentUser;
  bool isLoading = false;

  // ── Verifica se o usuário está logado ─────────────────────────────────────
  bool get isLoggedIn => _auth.currentUser != null;
  User? get firebaseUser => _auth.currentUser;

  ProfileController() {
    // Ouve mudanças de autenticação automaticamente
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        carregarPerfil();
      } else {
        currentUser = null;
        notifyListeners();
      }
    });
  }

  // ── Carrega perfil do Firestore ───────────────────────────────────────────
  Future<void> carregarPerfil([Function? updateState]) async {
    if (_auth.currentUser == null) return;

    isLoading = true;
    notifyListeners();
    updateState?.call();

    try {
      currentUser = await _service.fetchOrCreateUser();
    } catch (e) {
      print('Erro ao carregar perfil: $e');
    } finally {
      isLoading = false;
      notifyListeners();
      updateState?.call();
    }
  }

  // ── Salva alterações do perfil ────────────────────────────────────────────
  Future<void> atualizarPerfil(UserModel usuarioAtualizado) async {
    await _service.updateUser(usuarioAtualizado);
    currentUser = usuarioAtualizado;
    notifyListeners();
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> executarLogout() async {
    await _service.signOut();
    currentUser = null;
    notifyListeners();
  }
}