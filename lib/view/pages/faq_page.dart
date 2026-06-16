import 'package:flutter/material.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'pergunta': 'Posso encontrar eventos que estão acontecendo hoje?',
      'resposta':
          'Sim. Na seção "Eventos" você encontra feiras, festivais, apresentações culturais e outras atividades que acontecem na região.',
    },
    {
      'pergunta': 'O BoraNE é gratuito?',
      'resposta':
          'O BoraNE possui um plano gratuito com acesso limitado e um plano Premium (R\$ 9,90/mês ou R\$ 89,90/ano) com recursos avançados como roteiros personalizados, modo offline e alertas em tempo real.',
    },
    {
      'pergunta': 'Posso usar o BoraNE em qualquer cidade do Nordeste?',
      'resposta':
          'O BoraNE está em fase piloto com foco inicial em Garanhuns (PE), mas já conta com conteúdo de diversas cidades nordestinas. A cobertura será ampliada progressivamente.',
    },
    {
      'pergunta': 'Como salvar um local nos favoritos?',
      'resposta':
          'Ao visualizar um destino ou ponto turístico, toque no ícone de coração para salvá-lo na sua lista de favoritos. Você pode acessá-los na aba "Favoritos" no menu inferior.',
    },
    {
      'pergunta': 'O que é o BoraNE?',
      'resposta':
          'O BoraNE é um ecossistema digital de turismo desenvolvido para descobrir, planejar, viver e fortalecer o turismo na região Nordeste do Brasil, conectando viajantes a experiências e empreendedores locais.',
    },
    {
      'pergunta': 'Como criar uma rota personalizada?',
      'resposta':
          'Na aba "Planejar", você pode montar roteiros escolhendo destinos, datas e perfil de viagem (aventura, cultura ou descanso). Roteiros predefinidos também estão disponíveis para inspirar sua viagem.',
    },
    {
      'pergunta': 'Como anunciar meu negócio no BoraNE?',
      'resposta':
          'Pequenos empreendedores locais podem criar uma Conta de Parceiro (B2B) no aplicativo. Após o cadastro, é possível divulgar serviços, produtos e eventos diretamente para viajantes na plataforma.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/images/LOGO_V2_1.png', height: 32),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomNav(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ── Banner amarelo ──
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFEBB22F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Ícone de balões de pergunta
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '?',
                              style: TextStyle(
                                color: Color(0xFFEBB22F),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '?',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Perguntas\nfrequentes',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Lista de FAQs ──
          const SizedBox(height: 8),
          ...List.generate(_faqs.length, (i) {
            final item = _faqs[i];
            return _FaqItem(
              pergunta: item['pergunta']!,
              resposta: item['resposta']!,
            );
          }),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String pergunta;
  final String resposta;

  const _FaqItem({required this.pergunta, required this.resposta});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.pergunta,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                  color: Colors.black54,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 10),
              Text(
                widget.resposta,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.55,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}