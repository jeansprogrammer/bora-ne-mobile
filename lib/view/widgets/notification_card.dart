import 'package:flutter/material.dart';
import 'package:boranemobile/models/notification_model.dart';

/// Card padrão usado para exibir uma notificação na lista de notificações.
/// Notificações não lidas ganham um fundo amarelo queimado claro e uma
/// bolinha laranja queimado ao lado do horário.
class NotificationCard extends StatelessWidget {
  final NotificationModel notificacao;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notificacao,
    this.onTap,
  });

  static const Color _corFundoNaoLida = Color(0xFFFFF3D9);
  static const Color _corBolinhaNaoLida = Color(0xFFCC5500);

  IconData get _icone {
    switch (notificacao.type) {
      case 'favorito':
        return Icons.favorite;
      case 'roteiro':
        return Icons.map;
      case 'destino':
        return Icons.notifications_active;
      case 'promocao':
        return Icons.local_offer;
      case 'avaliacao':
        return Icons.star;
      case 'dica':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  String get _hora {
    final h = notificacao.date.hour.toString().padLeft(2, '0');
    final m = notificacao.date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final naoLida = !notificacao.read;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: naoLida ? _corFundoNaoLida : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icone,
                color: Colors.orange.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notificacao.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hora,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notificacao.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (naoLida) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: _corBolinhaNaoLida,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
