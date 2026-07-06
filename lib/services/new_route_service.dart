import 'package:cloud_firestore/cloud_firestore.dart';

class NewRouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para salvar a rota final (criação — gera um novo documento)
  Future<bool> saveRouteToFirestore(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('routes').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Erro ao salvar no Firestore: $e");
      return false;
    }
  }

  // Método para ATUALIZAR uma rota existente (edição)
  // Atualiza apenas os campos enviados; createdAt e demais campos são preservados.
  Future<bool> updateRouteInFirestore(String id, Map<String, dynamic> data) async {
    try {
      // Garante que o campo 'id' não seja gravado dentro do documento
      final Map<String, dynamic> payload = Map<String, dynamic>.from(data)
        ..remove('id');

      await _firestore.collection('routes').doc(id).update({
        ...payload,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Erro ao atualizar no Firestore: $e");
      return false;
    }
  }

  // Método para EXCLUIR uma rota existente
  Future<bool> deleteRouteFromFirestore(String id) async {
    try {
      await _firestore.collection('routes').doc(id).delete();
      return true;
    } catch (e) {
      print("Erro ao excluir no Firestore: $e");
      return false;
    }
  }
  
   Future<List<Map<String, dynamic>>> getAllRoutes() async {
    try {
      final snapshot = await _firestore
          .collection('routes')
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print('Erro ao buscar rotas: $e');
      return [];
    }
  }

  // ── Rotas criadas por um usuário específico ("Minhas rotas") ─────────────
  Future<List<Map<String, dynamic>>> getRoutesByCreator(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('routes')
          .where('createdBy', isEqualTo: uid)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print('Erro ao buscar rotas do usuário: $e');
      return [];
    }
  }
}