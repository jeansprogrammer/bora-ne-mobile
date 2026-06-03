import 'package:boranemobile/models/destination_model.dart';
import 'package:boranemobile/models/favorites_model.dart';
import 'package:boranemobile/models/route_creation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'favoritos';

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
      'destinos': FieldValue.arrayUnion([destino.toMap()]),
    });
  }

  /// Remove um [DestinoModel] exato do array de favoritos no Firestore.
  Future<void> desfavoritarDestino(String userId, DestinationModel destino) async {
    await _db.collection(_collectionPath).doc(userId).update({
      'destinos': FieldValue.arrayRemove([destino.toMap()]),
    });
  }

  Future<void> favoritarRota(String userId, RouteCreationModel rota) async {
    await _db.collection(_collectionPath).doc(userId).update({
      'rotas': FieldValue.arrayUnion([rota.toMap()]),
    });
  }

  /// Remove uma [RouteCreationModel] exata do array de rotas favoritas no Firestore.
  Future<void> desfavoritarRota(String userId, RouteCreationModel rota) async {
    await _db.collection(_collectionPath).doc(userId).update({
      'rotas': FieldValue.arrayRemove([rota.toMap()]),
    });
  }
  
}