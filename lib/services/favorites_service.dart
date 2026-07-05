import 'package:boranemobile/models/destination_model.dart';
import 'package:boranemobile/models/favorites_model.dart';
import 'package:boranemobile/models/route_creation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'favorites';

  // ── Garante que o documento do usuário existe antes de qualquer operação ──
  Future<void> _garantirDocumento(String userId) async {
    final docRef = _db.collection(_collectionPath).doc(userId);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'destinations': [],
        'routes': [],
        'createdat': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> salvarFavoritos(FavoritesModel favoritos) async {
    await _db
        .collection(_collectionPath)
        .doc(favoritos.userId)
        .set(favoritos.toMap(), SetOptions(merge: true));
  }

  Future<FavoritesModel?> obterFavoritos(String userId) async {
    final doc = await _db.collection(_collectionPath).doc(userId).get();
    if (doc.exists) return FavoritesModel.fromFirestore(doc);
    return null;
  }

  // ── Destinos ──────────────────────────────────────────────────────────────

  Future<void> favoritarDestino(String userId, DestinationModel destino) async {
    await _garantirDocumento(userId);
    // Salva só os campos essenciais para não pesar o documento de favoritos
    final map = {
      'id':         destino.id ?? '',
      'name':       destino.name,
      'city':       destino.city,
      'state':      destino.state,
      'coverPhoto': destino.coverPhoto,
      'categories': destino.categories,
      'neighborhood': destino.neighborhood,
      'description': destino.description,
      'photos':     destino.photos,
      'street':     destino.street,
      'number':     destino.number,
      'cep':        destino.cep,
      'latitude':   destino.latitude,
      'longitude':  destino.longitude,
      'favoritedBy': destino.favoritedBy,
    };
    await _db.collection(_collectionPath).doc(userId).update({
      'destinations': FieldValue.arrayUnion([map]),
    });
  }

  Future<void> desfavoritarDestino(
      String userId, String destinoId, {String? nome}) async {
    final docRef = _db.collection(_collectionPath).doc(userId);
    final doc = await docRef.get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final list = List<Map<String, dynamic>>.from(data['destinations'] ?? []);
    list.removeWhere((item) =>
        (destinoId.isNotEmpty && item['id'] == destinoId) ||
        (nome != null && nome.isNotEmpty && item['name'] == nome));
    await docRef.update({'destinations': list});
  }

  // ── Rotas ─────────────────────────────────────────────────────────────────

  Future<void> favoritarRota(String userId, RouteCreationModel rota) async {
    await _garantirDocumento(userId);
    // Salva só os campos essenciais (sem a lista de destinations embutida)
    final map = {
      'id':          rota.id ?? '',
      'name':        rota.name,
      'description': rota.description,
      'categories':  rota.categories,
      'city':        rota.city,
      'state':       rota.state,
      'coverPhoto':  rota.coverPhoto,
      'photos':      rota.photos,
      'favoritedBy': rota.favoritedBy,
    };
    await _db.collection(_collectionPath).doc(userId).update({
      'routes': FieldValue.arrayUnion([map]),
    });
  }

  Future<void> desfavoritarRota(String userId, String rotaName) async {
    final docRef = _db.collection(_collectionPath).doc(userId);
    final doc = await docRef.get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final list = List<Map<String, dynamic>>.from(data['routes'] ?? []);
    list.removeWhere((item) => item['name'] == rotaName);
    await docRef.update({'routes': list});
  }
}