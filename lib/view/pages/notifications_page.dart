import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boranemobile/controllers/auth_controller.dart';
import 'package:boranemobile/controllers/notifications_controller.dart';
import 'package:boranemobile/models/notification_model.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:boranemobile/view/widgets/notification_card.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const List<String> _meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  String _tituloSecao(DateTime data) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final ontem = hoje.subtract(const Duration(days: 1));
    final dia = DateTime(data.year, data.month, data.day);

    if (dia == hoje) return 'Hoje';
    if (dia == ontem) return 'Ontem';
    return '${data.day} de ${_meses[data.month - 1]}';
  }

  List<Widget> _buildLista(
    List<NotificationModel> notificacoes,
    NotificationsController controller,
  ) {
    final grupos = <String, List<NotificationModel>>{};
    for (final n in notificacoes) {
      grupos.putIfAbsent(_tituloSecao(n.date), () => []).add(n);
    }

    final widgets = <Widget>[];
    grupos.forEach((titulo, itens) {
      widgets.add(_SectionHeader(title: titulo));
      widgets.add(const SizedBox(height: 12));
      for (final n in itens) {
        widgets.add(NotificationCard(
          notificacao: n,
          onTap: () => controller.marcarComoLida(n),
        ));
      }
      widgets.add(const SizedBox(height: 10));
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final notificationsController = context.watch<NotificationsController>();
    final String currentUid = auth.user?.uid ?? 'usuario_teste';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: Column(
        children: [
          // Top clean bar
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 12,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/LOGO_V2_1.png',
                  height: 44,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'Bora NE',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.black87),
                    onSelected: (value) {
                      if (value == 'marcar_tudo_lido') {
                        notificationsController.marcarTodasComoLidas(currentUid);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'marcar_tudo_lido',
                        child: Text('MARCAR TUDO COMO LIDO'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: notificationsController.getNotifications(currentUid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Não foi possível carregar as notificações.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFF1B81A)),
                  );
                }

                final notificacoes = snapshot.data!;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    const Text(
                      "Notificações",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Fique por dentro de tudo o que acontece na sua conta e nos seus roteiros.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (notificacoes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text(
                            'Você ainda não tem notificações.',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                          ),
                        ),
                      )
                    else
                      ..._buildLista(notificacoes, notificationsController),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(activeTab: BottomNavTab.notificacoes),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
