import 'package:boranemobile/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _colecao = 'notification';

  Future<void> addNotification(NotificationModel notification) async {
    try {
      await _db.collection(_colecao).add(notification.toMap());
      print("Notificação adicionado com sucesso!");
    } catch (e) {
      print("Erro ao adicionar notificação: $e");
      rethrow; // Repassa o erro para o Controller tratar
    }
  }

  Stream<List<NotificationModel>> getNotification() {
    return _db.collection(_colecao).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return NotificationModel.fromMap(data);
      }).toList();
    });
  }

  Future<void> deleteNotification(String docId) async {
    try {
      await _db.collection(_colecao).doc(docId).delete();
      print("Notificação removido com sucesso!");
    } catch (e) {
      print("Erro ao deletar: $e");
      rethrow;
    }
  }
}