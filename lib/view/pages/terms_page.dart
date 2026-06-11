import 'package:boranemobile/view/pages/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

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
                  color: Colors.orangeAccent,
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
              'Termos de Uso',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Align(alignment: AlignmentGeometry.center),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Termos de Uso e Condições de Serviço – BoraNE',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Última atualização: Junho de 2026.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),

            _bodyText(
              'Seja bem-vindo ao BoraNE!\n\n'
              'Estes Termos de Uso e Condições de Serviço ("Termos") regulam o acesso e o uso do aplicativo digital BoraNE ("Plataforma"), um ecossistema desenvolvido para descobrir, planejar, viver e fortalecer o turismo na região Nordeste do Brasil.\n\n'
              'Ao baixar, instalar ou utilizar o aplicativo, você ("Usuário" ou "Parceiro") concorda integralmente com as condições aqui estabelecidas. Caso não concorde com qualquer termo, orientamos que não utilize a plataforma.',
            ),

            _sectionTitle('1. Descrição dos Serviços (Pilares de Atuação)'),
            _bodyText(
              'O BoraNE opera como um ecossistema facilitador de experiências turísticas regionais e hiperlocais por meio de quatro pilares fundamentais:',
            ),
            _bulletItem(
              'Descubra',
              'Disponibilização de mapas interativos, rotas inteligentes, georreferenciamento de pontos turísticos, gastronomia regional e locais alternativos.',
            ),
            _bulletItem(
              'Planeje',
              'Ferramenta para criação e personalização de roteiros baseados no perfil do viajante (aventura, cultura, descanso) ou acesso a roteiros predefinidos.',
            ),
            _bulletItem(
              'Viva',
              'Agenda cultural atualizada em tempo real com informações sobre shows, feiras, festivais e eventos locais.',
            ),
            _bulletItem(
              'Fortaleça',
              'Espaço dedicado à divulgação, digitalização e conexão direta de pequenos empreendedores locais (artesãos, guias independentes, pousadas de pequeno porte) com os viajantes.',
            ),

            _sectionTitle('2. Cadastro e Elegibilidade'),
            _bulletItem(
              'Contas de Usuário',
              'Para acessar determinadas funcionalidades (como salvamento de roteiros e assinaturas), o usuário precisará criar uma conta fornecendo dados verídicos e atualizados.',
            ),
            _bulletItem(
              'Contas de Parceiros (B2B)',
              'Pequenos empreendedores locais que desejam anunciar ou destacar seus serviços na plataforma devem realizar um cadastro específico, declarando-se legalmente aptos a prestar os serviços anunciados.',
            ),
            _bodyText(
              'A segurança das credenciais de acesso (login e senha) é de responsabilidade exclusiva do usuário.',
            ),

            _sectionTitle('3. Modelo de Negócio e Assinaturas (Freemium)'),
            _bodyText(
              'O BoraNE opera sob o modelo Freemium, dividindo-se em duas modalidades de acesso para o consumidor final (B2C):',
            ),
            _bulletItem(
              'Plano Gratuito',
              'Garante acesso limitado à navegação de mapas interativos e visualização da agenda principal de eventos.',
            ),
            _bulletItem(
              'Plano Premium',
              'Modalidade paga mediante assinatura recorrente nos valores de R\$ 9,90 por mês ou R\$ 89,90 por ano. A assinatura Premium confere acesso a roteiros avançados, modo offline completo, alertas em tempo real e conteúdos exclusivos.',
            ),

            _subSectionTitle('3.1. Cobrança e Cancelamento'),
            _bodyText(
              'As assinaturas são renovadas automaticamente de forma mensal ou anual, dependendo do plano escolhido. O usuário poderá cancelar a assinatura a qualquer momento através das configurações da sua loja de aplicativos (Google Play Store / Apple App Store), mantendo o acesso aos recursos Premium até o fim do período já pago.',
            ),

            _sectionTitle('4. Anúncios, Destaques e Links Afiliados (B2B)'),
            _bulletItem(
              'Publicidade Segmentada e Destaques',
              'A plataforma exibe publicidade direcionada e oferece opções de destaque pago para negócios e eventos locais. O BoraNE não se responsabiliza pela qualidade, cumprimento ou entrega dos produtos e serviços comercializados diretamente pelos anunciantes.',
            ),
            _bulletItem(
              'Links Afiliados',
              'A plataforma pode disponibilizar links de parceiros terceiros para a reserva de serviços. Transações, pagamentos e políticas de cancelamento dessas reservas ocorrem exclusivamente nos ambientes externos dos respectivos parceiros comerciais.',
            ),

            _sectionTitle(
              '5. Limitação de Responsabilidade (Fase de Protótipo/Piloto)',
            ),
            _warningBox(
              '⚠️ NOTA DE PROVA DE CONCEITO / PROTÓTIPO\n\n'
              'O Usuário está ciente de que a plataforma se encontra em fase de protótipo/projeto piloto, com sua amostragem inicial sendo validada prioritariamente na cidade de Garanhuns (PE). Por se tratar de uma versão experimental e de validação de mercado, o sistema pode apresentar instabilidades temporárias, variações de layout ou indisponibilidade de dados de georreferenciamento fora da região de teste inicial.',
            ),
            _bodyText(
              'O BoraNE atua como um agregador de informações e vitrine para a economia do turismo local. Portanto, não nos responsabilizamos por:',
            ),
            _bulletText(
              'Cancelamentos, atrasos ou alterações em eventos integrados na agenda em tempo real.',
            ),
            _bulletText(
              'A conduta, segurança ou qualidade dos serviços prestados por terceiros, guias autônomos ou hospedagens listadas na aba "Fortaleça".',
            ),
            _bulletText(
              'A exatidão absoluta dos mapas gerados por ferramentas terceiras de georreferenciamento.',
            ),

            _sectionTitle('6. Propriedade Intelectual'),
            _bodyText(
              'Todo o conteúdo visual, códigos de programação, design de interface, marcas, logotipos e a identidade cultural expressa no aplicativo pertencem exclusivamente à equipe de desenvolvimento e idealizadores do BoraNE. É proibida a reprodução, engenharia reversa ou distribuição não autorizada de qualquer elemento da plataforma.',
            ),

            _sectionTitle('7. Modificações nos Termos de Uso'),
            _bodyText(
              'Reservamo-nos o direito de alterar estes Termos de Uso a qualquer momento para refletir melhorias técnicas, novos recursos ou adequações legais. Sempre que houver mudanças significativas, os usuários serão notificados através do próprio aplicativo ou por e-mail. O uso continuado da plataforma após as alterações constituirá a aceitação dos novos Termos.',
            ),

            _sectionTitle('8. Legislação Aplicável e Foro'),
            _bodyText(
              'Estes Termos são regidos pelas leis da República Federativa do Brasil (incluindo o Marco Civil da Internet e a Lei Geral de Proteção de Dados - LGPD). Fica eleito o foro da Comarca de Garanhuns - PE para dirimir quaisquer dúvidas ou litígios decorrentes deste documento.',
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

  Widget _subSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
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

  Widget _warningBox(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        border: Border.all(color: const Color(0xFFEBB22F), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF5A4000),
          height: 1.6,
        ),
      ),
    );
  }
}
