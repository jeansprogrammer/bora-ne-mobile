import 'package:boranemobile/models/destination_model.dart';
import 'package:boranemobile/models/favorites_model.dart';
import 'package:boranemobile/models/route_creation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'favorites';

  Future<void> salvarFavoritos(FavoritesModel favoritos) async {
    await _db
        .collection(_collectionPath)
        .doc(favoritos.userId)
        .set(favoritos.toMap(), SetOptions(merge: true));
  }

  Future<FavoritesModel?> obterFavoritos(String userId) async {
    DocumentSnapshot doc = await _db.collection(_collectionPath).doc(userId).get();
    
    if (doc.exists) {
      return FavoritesModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> favoritarDestino(String userId, DestinationModel destino) async {
    await _db.collection(_collectionPath).doc(userId).update({
      'destinations': FieldValue.arrayUnion([destino.toMap()]),
    });
  }

  /// Remove um destino do array de favoritos no Firestore buscando pelo ID ou nome.
  Future<void> desfavoritarDestino(String userId, String destinoId, {String? nome}) async {
    final docRef = _db.collection(_collectionPath).doc(userId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final list = List<Map<String, dynamic>>.from(data['destinations'] ?? []);
      list.removeWhere((item) =>
        (destinoId.isNotEmpty && item['id'] == destinoId) ||
        (nome != null && nome.isNotEmpty && item['name'] == nome)
      );
      await docRef.update({'destinations': list});
    }
  }

  Future<void> favoritarRota(String userId, RouteCreationModel rota) async {
    await _db.collection(_collectionPath).doc(userId).update({
      'routes': FieldValue.arrayUnion([rota.toMap()]),
    });
  }

  /// Remove uma rota do array de favoritos no Firestore buscando pelo nome.
  Future<void> desfavoritarRota(String userId, String rotaName) async {
    final docRef = _db.collection(_collectionPath).doc(userId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final list = List<Map<String, dynamic>>.from(data['routes'] ?? []);
      list.removeWhere((item) => item['name'] == rotaName);
      await docRef.update({'routes': list});
    }
  }
}