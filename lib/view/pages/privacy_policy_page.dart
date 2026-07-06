import 'package:boranemobile/view/pages/user_profile_page.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF1A1A1A),
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserProfilePage(),
                      settings: const RouteSettings(name: '/user_profile_page'),
                    ),
                  );
                },
              ),
            ),
            const Text(
              'Política de Privacidade',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Política de Privacidade – BoraNE',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Última atualização: Julho de 2026.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),

            _bodyText(
              'Esta Política de Privacidade descreve como o BoraNE ("nós", "aplicativo" ou "plataforma") coleta, usa, armazena e protege os dados pessoais dos usuários ("você"), em conformidade com a Lei Geral de Proteção de Dados (Lei nº 13.709/2018 - LGPD).\n\n'
              'Ao utilizar o BoraNE, você concorda com as práticas descritas nesta política. Caso não concorde, recomendamos que não utilize o aplicativo.',
            ),

            _sectionTitle('1. Dados que Coletamos'),
            _bulletItem(
              'Dados de conta',
              'Nome, e-mail, foto de perfil e cidade, obtidos no cadastro (via Google ou e-mail/senha) ou informados por você na edição do perfil.',
            ),
            _bulletItem(
              'Conteúdo gerado pelo usuário',
              'Rotas, destinos, fotos, avaliações e comentários que você cria ou publica dentro do aplicativo.',
            ),
            _bulletItem(
              'Preferências e interações',
              'Favoritos, notificações e histórico de uso das funcionalidades do app.',
            ),
            _bulletItem(
              'Dados de localização',
              'Endereços e coordenadas (cidade, bairro, CEP) informados ao criar rotas e destinos, usados para exibição em mapas.',
            ),

            _sectionTitle('2. Como Usamos os Dados'),
            _bulletText(
              'Para criar e gerenciar sua conta e permitir login nas próximas vezes.',
            ),
            _bulletText(
              'Para exibir, na sua conta, as rotas, destinos, favoritos e notificações associados a você.',
            ),
            _bulletText(
              'Para viabilizar a criação e edição de rotas/destinos e o envio de comentários, sempre vinculados ao usuário autenticado.',
            ),
            _bulletText(
              'Para melhorar a experiência do aplicativo e corrigir problemas técnicos.',
            ),

            _sectionTitle('3. Compartilhamento de Dados'),
            _bodyText(
              'O BoraNE não vende dados pessoais. Alguns dados podem ser processados por prestadores de serviço que operam a infraestrutura do aplicativo:',
            ),
            _bulletItem(
              'Firebase (Google)',
              'Autenticação de conta, armazenamento do banco de dados (rotas, destinos, comentários, favoritos, notificações) e hospedagem de imagens.',
            ),
            _bulletItem(
              'Serviços de geolocalização',
              'Geoapify e ViaCEP, utilizados apenas para confirmar endereços e coordenadas informados na criação de destinos.',
            ),
            _bodyText(
              'Esses parceiros têm acesso apenas ao necessário para prestar o serviço contratado e são obrigados a manter a confidencialidade dos dados.',
            ),

            _sectionTitle('4. Armazenamento e Segurança'),
            _bodyText(
              'Os dados são armazenados em servidores do Firebase (Google Cloud), com controles de acesso e criptografia em trânsito. Apesar dos esforços para proteger suas informações, nenhum sistema é totalmente livre de riscos, e o BoraNE se compromete a agir rapidamente em caso de incidentes de segurança.',
            ),

            _sectionTitle('5. Seus Direitos (LGPD)'),
            _bodyText(
              'Você pode, a qualquer momento e mediante solicitação:',
            ),
            _bulletText('Confirmar a existência de tratamento dos seus dados.'),
            _bulletText('Acessar e corrigir seus dados pessoais.'),
            _bulletText(
              'Solicitar a exclusão da sua conta e dos dados associados a ela.',
            ),
            _bulletText(
              'Revogar consentimentos previamente concedidos, quando aplicável.',
            ),
            _bodyText(
              'Solicitações podem ser feitas pela opção "Reportar problema" no aplicativo ou pelos canais de contato informados abaixo.',
            ),

            _sectionTitle('6. Retenção e Exclusão de Dados'),
            _bodyText(
              'Seus dados são mantidos enquanto sua conta estiver ativa. Ao solicitar a exclusão da conta, removemos os dados pessoais associados, exceto quando a manutenção for exigida por obrigação legal.',
            ),

            _sectionTitle('7. Dados de Menores de Idade'),
            _bodyText(
              'O BoraNE não é direcionado a menores de 18 anos sem consentimento dos responsáveis legais. Caso identifiquemos coleta indevida de dados de menores, tomaremos as medidas necessárias para exclusão.',
            ),

            _sectionTitle('8. Alterações nesta Política'),
            _bodyText(
              'Podemos atualizar esta Política de Privacidade periodicamente para refletir melhorias no aplicativo ou mudanças legais. Alterações relevantes serão comunicadas através do próprio aplicativo.',
            ),

            _sectionTitle('9. Contato'),
            _bodyText(
              'Em caso de dúvidas sobre esta Política de Privacidade ou sobre o tratamento dos seus dados pessoais, entre em contato através da opção "Reportar problema" disponível no seu perfil.',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _bodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF333333),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _bulletItem(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFEBB22F),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFEBB22F),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
