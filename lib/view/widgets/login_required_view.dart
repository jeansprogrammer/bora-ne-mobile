import 'package:flutter/material.dart';
import 'package:boranemobile/view/pages/login_page.dart';

/// Tela cheia exibida no lugar de conteúdo restrito quando o usuário está
/// navegando como Convidado (ex.: Favoritos, Notificações).
class LoginRequiredView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onLoggedIn;

  const LoginRequiredView({
    super.key,
    this.icon = Icons.lock_outline,
    required this.title,
    required this.message,
    this.onLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.orangeAccent),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade600, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                  onLoggedIn?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7B119),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Entrar',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mostra, em um bottom sheet, a mesma mensagem de "faça login" usada em
/// telas inteiras — para ações pontuais (favoritar, comentar, criar).
Future<void> showLoginRequiredSheet(
  BuildContext context, {
  IconData icon = Icons.lock_outline,
  required String title,
  required String message,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: LoginRequiredView(icon: icon, title: title, message: message),
    ),
  );
}
