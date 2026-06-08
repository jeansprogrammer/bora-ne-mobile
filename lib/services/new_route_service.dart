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
}