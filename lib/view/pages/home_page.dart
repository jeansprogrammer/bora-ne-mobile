import 'package:boranemobile/view/pages/route_detail.dart';
import 'package:boranemobile/view/pages/routedestinos_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:boranemobile/view/widgets/route_carousel.dart';
import 'package:boranemobile/view/widgets/destination_card.dart';
import 'package:boranemobile/view/widgets/city_selector_sheet.dart';
import 'package:boranemobile/view/pages/search_page.dart';
import 'package:boranemobile/services/location_service.dart';
import 'package:boranemobile/data/category_data.dart';
import 'package:provider/provider.dart';
import 'package:boranemobile/controllers/auth_controller.dart';

class HomePage extends StatefulWidget {
  final String? cidadeInicial;

  const HomePage({super.key, this.cidadeInicial});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado de localização compartilhado com o Editar Perfil: qualquer
  // mudança feita lá (ou aqui) se reflete automaticamente nos dois lugares.
  final LocationService _locationService = LocationService();

  String? get _cidadeAtiva =>
      widget.cidadeInicial ?? _locationService.cidadeAtiva;
  bool get _estaCarregandoLocalizacao => _locationService.estaCarregando;

  @override
  void initState() {
    super.initState();
    _locationService.addListener(_onLocationChanged);
    if (widget.cidadeInicial == null) {
      _locationService.init();
    }
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onLocationChanged() {
    if (mounted) setState(() {});
  }

  // ── Popup de seleção de cidade (compartilhado com o Editar Perfil) ───────

  Future<void> _abrirSeletorCidade() => showCitySelectorSheet(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: const CustomBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ──────────────────────────────────────────────────────
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Image.asset('assets/images/LOGO_V2_1.png', height: 44),
                ),
              ),

              // ── Barra de Localização (clicável) ──────────────────────────
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: GestureDetector(
                    onTap: _estaCarregandoLocalizacao
                        ? null
                        : _abrirSeletorCidade,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.orangeAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.orangeAccent, size: 18),
                          const SizedBox(width: 6),
                          if (_estaCarregandoLocalizacao) ...[
                            const SizedBox(
                              width: 12, height: 12,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.orangeAccent),
                            ),
                            const SizedBox(width: 6),
                            const Text('Detectando sua cidade...',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500)),
                          ] else if (_cidadeAtiva != null) ...[
                            Text(
                              'Mostrando rotas de $_cidadeAtiva',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.orangeAccent, size: 16),
                          ] else
                            GestureDetector(
                              onTap: _abrirSeletorCidade,
                              child: const Text(
                                'Definir localização / Permitir GPS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orangeAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Barra de pesquisa ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SearchPage())),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06),
                            blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'O que você está procurando?',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 14),
                          child: Icon(Icons.search, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Carrossel de rotas ────────────────────────────────────────
              RouteCarousel(city: _cidadeAtiva,onTapRota: (rotaSelecionada) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RouteDetailPage(rota: rotaSelecionada),
                ),
                );
              },),

              const SizedBox(height: 20),

              // ── Categorias ────────────────────────────────────────────────
              _buildCategoriasSection(),

              const SizedBox(height: 20),

              // ── Próximo a você ────────────────────────────────────────────
              _buildProximoAVoce(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── SEÇÃO CATEGORIAS ──────────────────────────────────────────────────────

  // Mapeamento nome → arquivo de ícone em assets/images/
  static const Map<String, String> _iconeCategoria = {
    'Cultural':       'cultural_icon.png',
    'Histórico':      'historico_icon.png',
    'Religioso':      'religioso_icon.png',
    'Natureza':       'natureza_icon.png',
    'Lazer':          'lazer_icon.png',
    'Entretenimento': 'entretenimento_icon.png',
    'Aventura':       'aventura_icon.png',
    'Esportes':       'esportes_icon.png',
    'Gastronomia':    'gastronomia_icon.png',
    'Compras':        'compras_icon.png',
    'Hospedagem':     'hospedagem_icon.png',
    'Eventos':        'eventos_icon.png',
    'Experiências':   'experiencias_icon.png',
  };

  Widget _buildCategoriasSection() {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoriasBoraNE.length,
        itemBuilder: (_, i) {
          final cat = categoriasBoraNE[i];
          final icone = _iconeCategoria[cat.name] ?? 'aventura_icon.png';

          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RouteDestinosPage(
                    categoriaInicial: cat.name,
                    cidadeInicial: _cidadeAtiva, 
                  ),
                )),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/$icone',
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                        // fallback para emoji se a imagem não existir
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(cat.emoji,
                              style: const TextStyle(fontSize: 30)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── PRÓXIMO A VOCÊ — destinos da cidade ──────────────────────────────────

  Widget _buildProximoAVoce() {
    final stream = (_cidadeAtiva != null && _cidadeAtiva!.isNotEmpty)
        ? FirebaseFirestore.instance
            .collection('destinations')
            .where('city', isEqualTo: _cidadeAtiva)
            .limit(3)
            .snapshots()
        : FirebaseFirestore.instance
            .collection('destinations')
            .limit(3)
            .snapshots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título sem botão lateral
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Próximo a você',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: Colors.orangeAccent));
            }

            // Sem destinos na cidade → fallback geral
            if ((!snapshot.hasData || snapshot.data!.docs.isEmpty) &&
                _cidadeAtiva != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Text(
                      'Ainda não temos destinos em $_cidadeAtiva. Confira outras opções:',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey, height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('destinations')
                        .limit(3)
                        .snapshots(),
                    builder: (context, fb) {
                      if (fb.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Colors.orangeAccent));
                      }
                      if (!fb.hasData || fb.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Nenhum destino disponível.',
                              style: TextStyle(color: Colors.grey)),
                        );
                      }
                      return _buildDestinosList(fb.data!.docs);
                    },
                  ),
                ],
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Nenhum destino encontrado.',
                    style: TextStyle(color: Colors.grey)),
              );
            }

            return _buildDestinosList(snapshot.data!.docs);
          },
        ),
      ],
    );
  }

  Widget _buildDestinosList(List<QueryDocumentSnapshot> docs) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final currentUid = authController.user?.uid ?? '';

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc  = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return DestinationCard(id: doc.id, data: data, currentUid: currentUid);
          },
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RouteDestinosPage(cidadeInicial: _cidadeAtiva)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ver mais',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.black54),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}