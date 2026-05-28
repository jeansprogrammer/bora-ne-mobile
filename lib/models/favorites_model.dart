// models/favorites_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boranemobile/models/destino_model.dart';
import 'package:boranemobile/models/route_creation_model.dart';

class FavoritesModel {
  final String userId;
  final List<DestinoModel> destinos; // Coleção de objetos DestinoModel
  final List<RouteCreationModel> rotas;     // Coleção de objetos RouteCreationModel
  final DateTime dataCriacao;

  FavoritesModel({
    required this.userId,
    required this.destinos,
    required this.rotas,
    required this.dataCriacao,
  });

  // Converte o DocumentSnapshot do Firestore para o modelo Dart
  factory FavoritesModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Converte a lista de Maps do Firestore em instâncias de DestinoModel
    List<DestinoModel> listaDestinos = [];
    if (data['destinos'] != null) {
      listaDestinos = (data['destinos'] as List)
          .map((item) => DestinoModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    // Converte a lista de Maps do Firestore em instâncias de RouteCreationModel
    List<RouteCreationModel> listaRotas = [];
    if (data['rotas'] != null) {
      listaRotas = (data['rotas'] as List)
          .map((item) => RouteCreationModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return FavoritesModel(
      userId: doc.id, // O ID do documento é o hash/UID do usuário
      destinos: listaDestinos,
      rotas: listaRotas,
      dataCriacao: (data['dataCriacao'] as Timestamp).toDate(),
    );
  }

  // Converte as propriedades para salvar no formato correto do Firestore
  Map<String, dynamic> toMap() {
    return {
      'destinos': destinos.map((e) => e.toMap()).toList(),
      'rotas': rotas.map((e) => e.toMap()).toList(),
      'dataCriacao': Timestamp.fromDate(dataCriacao),
    };
  }
}