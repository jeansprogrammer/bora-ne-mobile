import 'package:cloud_firestore/cloud_firestore.dart';

class NewRouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para salvar a rota final
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
}