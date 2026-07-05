import '../data/notification_seeds.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';

/// Carga única de notificações de exemplo no Firestore, para testar a tela
/// de notificações. Ver instruções de uso em main.dart.
class NotificationSeedService {
  final NotificationService _notificationService = NotificationService();

  Future<void> executarCarga({String userId = 'usuario_teste'}) async {
    final notificacoes = gerarNotificacoesIniciais();
    print("🚀 Iniciando importação de ${notificacoes.length} notificações...");

    for (var item in notificacoes) {
      try {
        final notificacao = NotificationModel(
          userId: userId,
          title: item['title'],
          description: item['description'],
          type: item['type'],
          date: item['date'],
          read: item['read'] ?? false,
        );

        await _notificationService.addNotification(notificacao);
        print("✅ Sucesso: ${notificacao.title}");
      } catch (e) {
        print("❌ Falha ao inserir ${item['title']}: $e");
      }
    }
    print("🏁 Importação concluída!");
  }
}
