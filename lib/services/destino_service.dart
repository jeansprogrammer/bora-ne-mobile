import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destino_model.dart';

class DestinoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ESTE É O MÉTODO QUE ESTÁ FALTANDO (Erro da imagem 4676a2)
  Stream<List<DestinoModel>> getDestinos() {
    return _firestore.collection('destinos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DestinoModel.fromMap(doc.data());
      }).toList();
    });
  }

  // Método para adicionar (usado na carga de dados)
  Future<void> addDestino(DestinoModel destino) async {
    await _firestore.collection('destinos').add(destino.toMap());
  }

  // Método para busca dinâmica no Firestore
  Future<List<Map<String, dynamic>>> buscarDestinosNoFirestore(String query) async {
    var snapshot = await _firestore
        .collection('destinos')
        .where('nome', isGreaterThanOrEqualTo: query)
        .where('nome', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs.map((doc) => {
      "name": doc['nome'],
      "lat": (doc.data().containsKey('latitude') ? doc['latitude'] : 0.0).toDouble(),
      "lon": (doc.data().containsKey('longitude') ? doc['longitude'] : 0.0).toDouble(),
    }).toList();
  }
}