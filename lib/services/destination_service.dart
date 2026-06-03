import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/destination_model.dart';

class DestinationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Stream de todos os Destinos ──────────────────────────────────────────
  Stream<List<DestinationModel>> getDestinations() {
    return _firestore.collection('destinations').snapshots().map((snap) =>
        snap.docs
            .map((doc) => DestinationModel.fromMap(doc.data(), id: doc.id))
            .toList());
  }

  // ── Busca por nome + cidade (para criação de rota) ───────────────────────
  Future<List<DestinationModel>> buscarDestinationsPorNomeECidade(
      String query, String city) async {
    final queryLower = query.toLowerCase();

    // Busca pelo campo cidade primeiro (Firestore suporta where + where)
    final snapshot = await _firestore
        .collection('destinations')
        .where('city', isEqualTo: city)
        .get();

    // Filtra localmente pelo nome
    return snapshot.docs
        .where((doc) =>
            (doc['name'] as String).toLowerCase().contains(queryLower))
        .map((doc) => DestinationModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  // ── Busca por nome (genérica, sem filtro de cidade) ───────────────────────
  Future<List<DestinationModel>> buscarDestinationsPorNome(String query) async {
    final queryLower = query.toLowerCase();

    final snapshot = await _firestore
        .collection('destinations')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();

    if (snapshot.docs.isEmpty) {
      final all = await _firestore.collection('destinations').get();
      return all.docs
          .where((doc) =>
              (doc['name'] as String).toLowerCase().contains(queryLower))
          .map((doc) => DestinationModel.fromMap(doc.data(), id: doc.id))
          .toList();
    }

    return snapshot.docs
        .map((doc) => DestinationModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  // ── Upload idêntico ao new_route_service.dart ─────────────────────────────
  Future<List<String>> uploadFotos(List<File> fotos) async {
    List<String> downloadUrls = [];

    for (var foto in fotos) {
      try {
        String fileName =
            'destination_${DateTime.now().millisecondsSinceEpoch}_${fotos.indexOf(foto)}.jpg';
        Reference ref =
            _storage.ref().child('destinations_photos').child(fileName);

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

  // ── Salvar novo Destino ───────────────────────────────────────────────────
  Future<String?> salvarDestination(DestinationModel Destination) async {
    try {
      final doc =
          await _firestore.collection('destinations').add(Destination.toMap());
      return doc.id;
    } catch (e) {
      print('Erro ao salvar destination: $e');
      return null;
    }
  }

  // ── Toggle favorito ───────────────────────────────────────────────────────
  Future<void> toggleFavorito(String DestinationId, String uid) async {
    final ref = _firestore.collection('destinations').doc(DestinationId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final favoritadoPor = List<String>.from(doc['favoritedBy'] ?? []);

    if (favoritadoPor.contains(uid)) {
      favoritadoPor.remove(uid);
    } else {
      favoritadoPor.add(uid);
    }

    await ref.update({'favoritedBy': favoritadoPor});
  }

  // ── Compatibilidade ───────────────────────────────────────────────────────
  Future<void> addDestination(DestinationModel Destination) async {
    await _firestore.collection('destinations').add(Destination.toMap());
  }
}