import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destino_model.dart';

class FirestoreService {
  // 1. Instancia o Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Nome da coleção no Firestore (facilita se você precisar mudar depois)
  final String _colecao = 'destinos';

  // 2. Adicionar um novo Destino (addDestino)
  Future<void> addDestino(DestinoModel destino) async {
    try {
      await _db.collection(_colecao).add(destino.toMap());
      print("Destino adicionado com sucesso!");
    } catch (e) {
      print("Erro ao adicionar destino: $e");
      rethrow; // Repassa o erro para o Controller tratar
    }
  }

  // 3. Buscar todos os Destinos (getDestinos)
  // Retorna um Stream para que a interface atualize em tempo real se o banco mudar
  Stream<List<DestinoModel>> getDestinos() {
    return _db.collection(_colecao).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Combinamos o ID do documento com os dados do mapa
        Map<String, dynamic> data = doc.data();
        return DestinoModel.fromMap(data);
      }).toList();
    });
  }

  // 4. Deletar um Destino (deleteDestino)
  // Nota: Para deletar, precisamos do ID do documento que o Firestore gera
  Future<void> deleteDestino(String docId) async {
    try {
      await _db.collection(_colecao).doc(docId).delete();
      print("Destino removido com sucesso!");
    } catch (e) {
      print("Erro ao deletar: $e");
      rethrow;
    }
  }
}