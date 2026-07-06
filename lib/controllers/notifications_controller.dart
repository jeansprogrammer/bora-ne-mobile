import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsController extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  String? errorMessage;

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _service.getNotifications(userId);
  }

  Future<void> addNotification(NotificationModel notification) async {
    errorMessage = null;
    try {
      await _service.addNotification(notification);
    } catch (e) {
      errorMessage = 'Erro ao criar notificação: $e';
      debugPrint(errorMessage);
      notifyListeners();
    }
  }

  Future<void> marcarComoLida(NotificationModel notificacao) async {
    if (notificacao.id == null || notificacao.read) return;
    try {
      await _service.markAsRead(notificacao.id!);
    } catch (e) {
      errorMessage = 'Erro ao marcar notificação como lida: $e';
      debugPrint(errorMessage);
      notifyListeners();
    }
  }

  Future<void> marcarTodasComoLidas(String userId) async {
    try {
      await _service.markAllAsRead(userId);
    } catch (e) {
      errorMessage = 'Erro ao marcar notificações como lidas: $e';
      debugPrint(errorMessage);
      notifyListeners();
    }
  }
}
