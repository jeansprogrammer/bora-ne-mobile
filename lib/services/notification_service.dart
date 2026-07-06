import 'package:boranemobile/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Serviço dedicado às notificações do usuário, armazenadas na coleção
/// de nível superior "notifications", cada documento referenciando o
/// destinatário via `userId`.
class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionPath = 'notifications';

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _db.collection(_collectionPath);

  /// Stream com as notificações de um usuário, mais recentes primeiro.
  ///
  /// A ordenação é feita no cliente (não via `orderBy` do Firestore) para
  /// que a consulta use apenas um filtro de igualdade em `userId`, sem
  /// exigir a criação manual de um índice composto no Firestore.
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final notificacoes = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), id: doc.id))
          .toList();

      notificacoes.sort((a, b) => b.date.compareTo(a.date));

      return notificacoes;
    });
  }

  Future<void> addNotification(NotificationModel notification) async {
    await _notificationsRef.add(notification.toMap());
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({'read': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot =
        await _notificationsRef.where('userId', isEqualTo: userId).get();

    final naoLidas =
        snapshot.docs.where((doc) => (doc.data()['read'] ?? false) == false);
    if (naoLidas.isEmpty) return;

    final batch = _db.batch();
    for (final doc in naoLidas) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationsRef.doc(notificationId).delete();
  }
}
