import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/destination_model.dart';

class DestinationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ───────────────────────────────────────────────────────────────
  // Destinos
  // ───────────────────────────────────────────────────────────────

  Stream<List<DestinationModel>> getDestinations() {
    return _firestore
        .collection('destinations')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => DestinationModel.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<List<DestinationModel>> getAllDestinations() async {
    try {
      final snapshot = await _firestore.collection('destinations').get();

      return snapshot.docs
          .map((doc) => DestinationModel.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar destinos: $e');
      return [];
    }
  }

  Future<List<DestinationModel>> buscarDestinationsPorNomeECidade(
    String query,
    String city,
  ) async {
    final queryLower = query.toLowerCase();

    final snapshot = await _firestore
        .collection('destinations')
        .where('city', isEqualTo: city)
        .get();

    return snapshot.docs
        .where(
          (doc) => (doc['name'] as String).toLowerCase().contains(queryLower),
        )
        .map((doc) => DestinationModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

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
          .where(
            (doc) => (doc['name'] as String).toLowerCase().contains(queryLower),
          )
          .map((doc) => DestinationModel.fromMap(doc.data(), id: doc.id))
          .toList();
    }

    return snapshot.docs
        .map((doc) => DestinationModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  Future<List<String>> uploadFotos(List<File> fotos) async {
    List<String> downloadUrls = [];

    for (var foto in fotos) {
      try {
        String fileName =
            'destination_${DateTime.now().millisecondsSinceEpoch}_${fotos.indexOf(foto)}.jpg';

        Reference ref = _storage
            .ref()
            .child('destinations_photos')
            .child(fileName);

        UploadTask uploadTask = ref.putFile(foto);

        TaskSnapshot snapshot = await uploadTask;

        String url = await snapshot.ref.getDownloadURL();

        downloadUrls.add(url);
      } catch (e) {
        print("Erro ao fazer upload: $e");
      }
    }

    return downloadUrls;
  }

  Future<String?> salvarDestination(DestinationModel destination) async {
    try {
      final doc = await _firestore
          .collection('destinations')
          .add(destination.toMap());

      return doc.id;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> addDestination(DestinationModel destination) async {
    await _firestore.collection('destinations').add(destination.toMap());
  }

  // ───────────────────────────────────────────────────────────────
  // Favoritos
  // ───────────────────────────────────────────────────────────────

  Future<void> toggleFavorito(String destinationId, String uid) async {
    final ref = _firestore.collection('destinations').doc(destinationId);

    final doc = await ref.get();

    if (!doc.exists) return;

    final favoritedBy = List<String>.from(doc['favoritedBy'] ?? []);

    if (favoritedBy.contains(uid)) {
      favoritedBy.remove(uid);
    } else {
      favoritedBy.add(uid);
    }

    await ref.update({'favoritedBy': favoritedBy});
  }

  // ───────────────────────────────────────────────────────────────
  // Comentários
  // ───────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getComments(String destinationId) {
    return _firestore
        .collection('destinations')
        .doc(destinationId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addComment({
    required String destinationId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    print("Entrou no DestinationService");

    await _firestore
        .collection('destinations')
        .doc(destinationId)
        .collection('comments')
        .add({
          'userId': userId,
          'userName': userName,
          'message': message,
          'createdAt': FieldValue.serverTimestamp(),
        });

    print("Comentário salvo no Firestore");
  }
}
