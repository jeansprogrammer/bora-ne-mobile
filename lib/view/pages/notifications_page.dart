import 'package:flutter/material.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        
        centerTitle: true,
      ),
      
      body: SafeArea(
        child: ListView(
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

            const _SectionHeader(title: "Hoje"),
            const SizedBox(height: 12),
            const _NotificationCard(
              title: "Roteiro salvo",
              subtitle: "Praia de Maracaípe foi adicionado aos seus favoritos.",
              time: "19:45",
              icon: Icons.favorite,
            ),
            _NotificationCard(
              title: "Novidade no destino",
              subtitle: "Novas dicas de passeios em Porto de Galinhas para você!",
              time: "17:30",
              icon: Icons.notifications_active,
            ),
            const _NotificationCard(
              title: "Roteiro atualizado",
              subtitle: 'Seu roteiro \"Fim de semana em Olinda\" foi atualizado com novas atrações.',
              time: "15:10",
              icon: Icons.map,
            ),
            
            const SizedBox(height: 10),
            const _SectionHeader(title: "Ontem"),
            const SizedBox(height: 12),
            const _NotificationCard(
              title: "Promoção especial",
              subtitle: "Descontos exclusivos em passeios selecionados. Aproveite!",
              time: "20:20",
              icon: Icons.local_offer,
            ),
      
            const SizedBox(height: 10),
            const _SectionHeader(title: "10 de maio"),
            const SizedBox(height: 12),
            const _NotificationCard(
              title: "Avalie sua experiência",
              subtitle: "Como foi seu passeio na Cachoeira de Bonito? Conte pra gente!",
              time: "18:05",
              icon: Icons.star,
            ),
            
            const SizedBox(height: 10),
            const _SectionHeader(title: "8 de maio"),
            const SizedBox(height: 12),
            const _NotificationCard(
              title: "Dica boraNE",
              subtitle: "Não esqueça de levar protetor solar e água para curtir o melhor do dia!",
              time: "10:15",
              icon: Icons.campaign, // Ícone de megafone/dica
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
       bottomNavigationBar: const CustomBottomNav(activeTab: BottomNavTab.notificacoes)
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

class _NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  const _NotificationCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,

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
              icon,
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.chevron_right,
              color: Colors.orange,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}