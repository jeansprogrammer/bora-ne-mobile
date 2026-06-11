// models/favorites_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boranemobile/models/destination_model.dart';
import 'package:boranemobile/models/route_creation_model.dart';

class FavoritesModel {
  final String userId;
  final List<DestinationModel> destinations; // Coleção de objetos DestinoModel
  final List<RouteCreationModel> routes;     // Coleção de objetos RouteCreationModel
  final DateTime createdat;

  FavoritesModel({
    required this.userId,
    required this.destinations,
    required this.routes,
    required this.createdat,
  });

  // Converte o DocumentSnapshot do Firestore para o modelo Dart
  factory FavoritesModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Converte a lista de Maps do Firestore em instâncias de DestinoModel
    List<DestinationModel> listaDestinos = [];
    final rawDestinations = data['destinations'] ?? data['destinos'];
    if (rawDestinations != null) {
      listaDestinos = (rawDestinations as List)
          .map((item) {
            final map = item as Map<String, dynamic>;
            return DestinationModel.fromMap(map, id: map['id']);
          })
          .toList();
    }

    // Converte a lista de Maps do Firestore em instâncias de RouteCreationModel
    List<RouteCreationModel> listaRotas = [];
    final rawRoutes = data['routes'] ?? data['rotas'];
    if (rawRoutes != null) {
      listaRotas = (rawRoutes as List)
          .map((item) {
            final map = item as Map<String, dynamic>;
            return RouteCreationModel.fromMap(map, id: map['id']);
          })
          .toList();
    }

    // Suporta chaves createdat, createdAt e dataCriacao
    final timestamp = data['createdat'] ?? data['createdAt'] ?? data['dataCriacao'];
    final DateTime date = timestamp is Timestamp ? timestamp.toDate() : DateTime.now();

    return FavoritesModel(
      userId: doc.id, // O ID do documento é o hash/UID do usuário
      destinations: listaDestinos,
      routes: listaRotas,
      createdat: date,
    );
  }

  // Converte as propriedades para salvar no formato correto do Firestore
  Map<String, dynamic> toMap() {
    return {
      'destinations': destinations.map((e) => e.toMap()).toList(),
      'routes': routes.map((e) => e.toMap()).toList(),
      'createdat': Timestamp.fromDate(createdat),
    };
  }
}