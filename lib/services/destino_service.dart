import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/destino_model.dart';

class DestinoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Stream de todos os destinos ──────────────────────────────────────────
  Stream<List<DestinoModel>> getDestinos() {
    return _firestore.collection('destinos').snapshots().map((snap) =>
        snap.docs
            .map((doc) => DestinoModel.fromMap(doc.data(), id: doc.id))
            .toList());
  }

  // ── Busca por nome ────────────────────────────────────────────────────────
  Future<List<DestinoModel>> buscarDestinosPorNome(String query) async {
    final queryLower = query.toLowerCase();

    final snapshot = await _firestore
        .collection('destinos')
        .where('nome', isGreaterThanOrEqualTo: query)
        .where('nome', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();

    if (snapshot.docs.isEmpty) {
      final all = await _firestore.collection('destinos').get();
      return all.docs
          .where((doc) =>
              (doc['nome'] as String).toLowerCase().contains(queryLower))
          .map((doc) => DestinoModel.fromMap(doc.data(), id: doc.id))
          .toList();
    }

    return snapshot.docs
        .map((doc) => DestinoModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  // ── Upload idêntico ao new_route_service.dart ─────────────────────────────
  Future<List<String>> uploadFotos(List<File> fotos) async {
    List<String> downloadUrls = [];

    for (var foto in fotos) {
      try {
        String fileName =
            'destino_${DateTime.now().millisecondsSinceEpoch}_${fotos.indexOf(foto)}.jpg';
        Reference ref =
            _storage.ref().child('destinos_fotos').child(fileName);

        UploadTask uploadTask = ref.putFile(foto);
        TaskSnapshot snapshot = await uploadTask;

        String url = await snapshot.ref.getDownloadURL();
        downloadUrls.add(url);
      } catch (e) {
        print("Erro ao fazer upload de imagem: $e");
      }
    }
    return downloadUrls;
  }

  // ── Salvar novo destino ───────────────────────────────────────────────────
  Future<String?> salvarDestino(DestinoModel destino) async {
    try {
      final doc =
          await _firestore.collection('destinos').add(destino.toMap());
      return doc.id;
    } catch (e) {
      print('Erro ao salvar destino: $e');
      return null;
    }
  }

  // ── Toggle favorito ───────────────────────────────────────────────────────
  Future<void> toggleFavorito(String destinoId, String uid) async {
    final ref = _firestore.collection('destinos').doc(destinoId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final favoritadoPor = List<String>.from(doc['favoritadoPor'] ?? []);

    if (favoritadoPor.contains(uid)) {
      favoritadoPor.remove(uid);
    } else {
      favoritadoPor.add(uid);
    }

    await ref.update({'favoritadoPor': favoritadoPor});
  }

  // ── Compatibilidade ───────────────────────────────────────────────────────
  Future<void> addDestino(DestinoModel destino) async {
    await _firestore.collection('destinos').add(destino.toMap());
  }
}