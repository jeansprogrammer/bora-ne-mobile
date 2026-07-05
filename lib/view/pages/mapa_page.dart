import 'dart:convert';
import 'package:boranemobile/models/destination_model.dart';
import 'package:boranemobile/services/location_service.dart';
import 'package:boranemobile/view/widgets/photo_carousel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:boranemobile/view/widgets/route_card.dart';

/// Modo de abertura do mapa.
/// [destino] → pin único, painel com info do destino + rotas que o contêm.
/// [rota]    → múltiplos pins, painel com info da rota; ao clicar num pin
///             o painel muda para a info daquele destino.
enum MapaMode { destino, rota }

class TelaMapa extends StatefulWidget {
  // ── Modo destino ──────────────────────────────────────────────────────────
  final DestinationModel? destino;

  // ── Modo rota ─────────────────────────────────────────────────────────────
  final String? nomeRota;
  final List<Map<String, dynamic>>? destinosRota;

  const TelaMapa.destino({super.key, required DestinationModel destino})
      : destino = destino,
        nomeRota = null,
        destinosRota = null;

  const TelaMapa.rota({
    super.key,
    required String nomeRota,
    required List<Map<String, dynamic>> destinosRota,
  })  : destino = null,
        nomeRota = nomeRota,
        destinosRota = destinosRota;

  MapaMode get mode =>
      destino != null ? MapaMode.destino : MapaMode.rota;

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final MapController _mapController = MapController();
  final String _apiKey = "aeccc7dd6dea4139a6cf6da8046a2f75";
  final String _mapStyleUrl =
      "https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=aeccc7dd6dea4139a6cf6da8046a2f75";

  // ── Modo dinâmico (pode mudar ao clicar em rota da lista) ────────────────
  late MapaMode _modoAtual;
  // Guarda o destino original para voltar ao clicar em "Voltar"
  DestinationModel? _destinoOriginal;
  // Dados da rota ativa (modo rota)
  String _nomeRotaAtual = '';
  List<Map<String, dynamic>> _destinosRotaAtual = [];

  // ── Estado de navegação (compartilhado entre modos) ──────────────────────
  List<LatLng> _rotaPontos = [];
  String _distanciaTexto = '';
  String _tempoTexto = '';
  bool _carregandoNav = false;
  LatLng? _userLocation;

  // ── Modo destino: rotas que contêm este destino ──────────────────────────
  List<Map<String, dynamic>> _rotasComDestino = [];
  bool _carregandoRotas = true;

  // ── Modo rota: índice do pin selecionado (null = mostra info da rota) ────
  int? _indexSelecionado;

  // ── Destinos válidos (modo rota) ─────────────────────────────────────────
  List<DestinationModel> get _destinosRota {
    return _destinosRotaAtual
        .where((d) =>
            (d['latitude'] ?? 0.0) != 0.0 ||
            (d['longitude'] ?? 0.0) != 0.0)
        .map((d) => DestinationModel.fromMap(d))
        .toList();
  }

  DestinationModel? get _destinoSelecionado =>
      _indexSelecionado != null ? _destinosRota[_indexSelecionado!] : null;

  @override
  void initState() {
    super.initState();
    _modoAtual = widget.mode;
    _destinoOriginal = widget.destino;
    _nomeRotaAtual = widget.nomeRota ?? '';
    _destinosRotaAtual = widget.destinosRota ?? [];
    if (_modoAtual == MapaMode.destino) {
      _buscarRotasComDestino();
    } else {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _enquadrarTodos());
    }
  }

  // ── Troca para modo rota ao clicar numa rota da lista ────────────────────
  void _abrirRotaNoMapa(Map<String, dynamic> rota) {
    final destinos = (rota['destinations'] as List? ?? [])
        .map((d) => Map<String, dynamic>.from(d as Map))
        .toList();

    // Localiza o destino de origem dentro da nova rota, para manter seus
    // dados exibidos no painel enquanto o mapa mostra todos os pins da rota.
    int? indexDestino;
    if (_destinoOriginal != null) {
      final destinosValidos = destinos
          .where((d) =>
              (d['latitude'] ?? 0.0) != 0.0 || (d['longitude'] ?? 0.0) != 0.0)
          .map((d) => DestinationModel.fromMap(d))
          .toList();
      final nome = _destinoOriginal!.name.toLowerCase();
      final id = _destinoOriginal!.id ?? '';
      final idx = destinosValidos.indexWhere((d) =>
          d.name.toLowerCase() == nome || (id.isNotEmpty && d.id == id));
      indexDestino = idx == -1 ? null : idx;
    }

    setState(() {
      _modoAtual = MapaMode.rota;
      _nomeRotaAtual = rota['name'] ?? 'Rota';
      _destinosRotaAtual = destinos;
      _indexSelecionado = indexDestino;
      _rotaPontos = [];
      _distanciaTexto = '';
      _tempoTexto = '';
      _userLocation = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _enquadrarTodos());
  }

  // ── Volta para o destino original ────────────────────────────────────────
  void _voltarParaDestino() {
    setState(() {
      _modoAtual = MapaMode.destino;
      _nomeRotaAtual = '';
      _destinosRotaAtual = [];
      _indexSelecionado = null;
      _rotaPontos = [];
      _distanciaTexto = '';
      _tempoTexto = '';
      _userLocation = null;
    });
    if (_destinoOriginal != null) {
      _mapController.move(
        LatLng(_destinoOriginal!.latitude, _destinoOriginal!.longitude),
        15,
      );
    }
  }

  // ── Modo destino: busca rotas que contêm este destino ────────────────────
  Future<void> _buscarRotasComDestino() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('routes').get();
      final nome = widget.destino!.name.toLowerCase();
      final id = widget.destino!.id ?? '';
      final rotas = snap.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .where((rota) {
        final destinations = rota['destinations'];
        if (destinations == null || destinations is! List) return false;
        return destinations.any((d) {
          if (d is! Map) return false;
          final dNome = (d['name'] ?? '').toString().toLowerCase();
          final dId = (d['id'] ?? '').toString();
          return dNome == nome || (id.isNotEmpty && dId == id);
        });
      }).toList();

      if (mounted) {
        setState(() {
          _rotasComDestino = rotas;
          _carregandoRotas = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _carregandoRotas = false);
    }
  }

  // ── Modo rota: enquadra todos os pins no mapa ────────────────────────────
  void _enquadrarTodos() {
    final pontos = _destinosRota
        .map((d) => LatLng(d.latitude, d.longitude))
        .toList();
    if (pontos.isEmpty) return;
    if (pontos.length == 1) {
      _mapController.move(pontos.first, 14);
      return;
    }
    _mapController.fitCamera(CameraFit.bounds(
      bounds: LatLngBounds.fromPoints(pontos),
      padding: const EdgeInsets.all(60),
    ));
  }

  // ── Navegação GPS ─────────────────────────────────────────────────────────
  Future<void> _iniciarNavegacao(DestinationModel alvo) async {
    setState(() {
      _carregandoNav = true;
      _rotaPontos = [];
      _distanciaTexto = '';
      _tempoTexto = '';
    });

    final pos = await LocationService().obterPosicaoAtual();
    if (!mounted) return;
    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Não foi possível obter sua localização.')));
      setState(() => _carregandoNav = false);
      return;
    }

    final origem = LatLng(pos.latitude, pos.longitude);
    final dest = LatLng(alvo.latitude, alvo.longitude);
    setState(() => _userLocation = origem);

    try {
      final url = Uri.parse(
        'https://api.geoapify.com/v1/routing'
        '?waypoints=${origem.latitude},${origem.longitude}'
        '|${dest.latitude},${dest.longitude}'
        '&mode=drive&apiKey=$_apiKey',
      );
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final feat = data['features'][0];
          final double dist = feat['properties']['distance'].toDouble();
          final double time = feat['properties']['time'].toDouble();
          final List geom = feat['geometry']['coordinates'][0];
          final pontos = geom
              .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();
          setState(() {
            _rotaPontos = pontos;
            _distanciaTexto = '${(dist / 1000).toStringAsFixed(1)} km';
            _tempoTexto = '${(time / 60).round()} min';
            _carregandoNav = false;
          });
          if (pontos.isNotEmpty) {
            _mapController.fitCamera(CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(pontos),
              padding: const EdgeInsets.all(60),
            ));
          }
        }
      }
    } catch (_) {
      if (mounted) setState(() => _carregandoNav = false);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // ── Mapa ─────────────────────────────────────────────────────────
          Positioned.fill(child: _buildMap()),

          // ── Botão voltar ──────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.15), blurRadius: 6)],
                ),
                child: const Icon(Icons.arrow_back,
                    color: Colors.black, size: 22),
              ),
            ),
          ),

          // ── Painel deslizável ─────────────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.12,
            maxChildSize: 0.80,
            snap: true,
            snapSizes: const [0.12, 0.32, 0.80],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(
                      color: Colors.black12, blurRadius: 12,
                      offset: Offset(0, -3))],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    // Alça
                    Center(child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )),

                    _modoAtual == MapaMode.destino
                        ? _buildPainelDestino()
                        : _buildPainelRota(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Mapa: pins e camadas ──────────────────────────────────────────────────
  Widget _buildMap() {
    final isDestino = _modoAtual == MapaMode.destino;
    final destinoLatLng = isDestino && _destinoOriginal != null
        ? LatLng(_destinoOriginal!.latitude, _destinoOriginal!.longitude)
        : (_destinosRota.isNotEmpty
            ? LatLng(_destinosRota.first.latitude,
                _destinosRota.first.longitude)
            : const LatLng(-8.8908, -36.4969));

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: destinoLatLng,
        initialZoom: isDestino ? 15 : 13,
        onTap: isDestino
            ? null
            : (_, __) => setState(() => _indexSelecionado = null),
      ),
      children: [
        TileLayer(
          urlTemplate: _mapStyleUrl,
          userAgentPackageName: 'com.boranemobile.app',
        ),
        if (_rotaPontos.isNotEmpty)
          PolylineLayer(polylines: [
            Polyline(
              points: _rotaPontos, strokeWidth: 5.0,
              color: const Color(0xFFF1B81A),
            ),
          ]),
        MarkerLayer(markers: [
          // Modo destino: pin único
          if (isDestino)
            Marker(
              width: 48, height: 48, point: destinoLatLng,
              child: const Icon(Icons.location_pin,
                  color: Color(0xFFF1B81A), size: 44),
            ),
          // Modo rota: pins numerados
          if (!isDestino)
            ...List.generate(_destinosRota.length, (i) {
              final d = _destinosRota[i];
              final sel = _indexSelecionado == i;
              return Marker(
                width: sel ? 52 : 40,
                height: sel ? 52 : 40,
                point: LatLng(d.latitude, d.longitude),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _indexSelecionado = i);
                    _mapController.move(
                        LatLng(d.latitude, d.longitude), 15);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.location_pin,
                          color: sel
                              ? const Color(0xFFF1B81A)
                              : Colors.red.shade400,
                          size: sel ? 48 : 36),
                      Positioned(
                        top: sel ? 6 : 4,
                        child: Text('${i + 1}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: sel ? 13 : 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          // Pin do usuário
          if (_userLocation != null)
            Marker(
              width: 36, height: 36, point: _userLocation!,
              child: const Icon(Icons.my_location,
                  color: Colors.blue, size: 30),
            ),
        ]),
      ],
    );
  }

  // ── Painel: modo destino ──────────────────────────────────────────────────
  Widget _buildPainelDestino() {
    final d = _destinoOriginal!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerComIr(
          nome: d.name,
          endereco: _buildEndereco(d),
          onIr: () => _iniciarNavegacao(d),
        ),
        if (d.photos.isNotEmpty) ...[
          const SizedBox(height: 14),
          _fotosHorizontal(d.photos),
        ],
        const SizedBox(height: 16),
        const Text('Rotas com este destino',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 10),
        if (_carregandoRotas)
          const Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(
                      color: Color(0xFFF1B81A))))
        else if (_rotasComDestino.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Nenhuma rota cadastrada com este destino ainda.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          )
        else
          ...(_rotasComDestino.map((rota) => RouteCard(
                id: rota['id'] ?? '',
                data: rota,
                currentUid: FirebaseAuth.instance.currentUser?.uid ?? '',
                // Ao tocar, muda o mapa para mostrar a rota (sem navegar)
                onTap: () => _abrirRotaNoMapa(rota),
              ))),
      ],
    );
  }

  // ── Painel: modo rota ─────────────────────────────────────────────────────
  Widget _buildPainelRota() {
    final destinos = _destinosRota;
    final sel = _destinoSelecionado;

    // Nenhum pin selecionado → info da rota
    if (sel == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão voltar ao destino (só quando veio do modo destino)
          if (_destinoOriginal != null && widget.mode == MapaMode.destino) ...[
            GestureDetector(
              onTap: _voltarParaDestino,
              child: Row(children: [
                const Icon(Icons.chevron_left,
                    color: Color(0xFFF1B81A), size: 18),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    'Voltar para ${_destinoOriginal!.name}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFF1B81A),
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 10),
          ],
          Text(_nomeRotaAtual,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '${destinos.length} destino${destinos.length != 1 ? 's' : ''}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          ...List.generate(destinos.length, (i) {
            final d = destinos[i];
            return Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFF1B81A),
                  radius: 14,
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                title: Text(d.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('${d.city} – ${d.state}',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                onTap: () {
                  setState(() => _indexSelecionado = i);
                  _mapController.move(LatLng(d.latitude, d.longitude), 15);
                },
              ),
            );
          }),
        ],
      );
    }

    // Pin selecionado → info do destino
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerComIr(
          nome: sel.name,
          endereco: _buildEndereco(sel),
          onIr: () => _iniciarNavegacao(sel),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() {
            _indexSelecionado = null;
            _rotaPontos = [];
            _distanciaTexto = '';
            _tempoTexto = '';
            _userLocation = null;
            _enquadrarTodos();
          }),
          child: Row(children: [
            const Icon(Icons.chevron_left,
                color: Color(0xFFF1B81A), size: 18),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                'Voltar para $_nomeRotaAtual',
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFF1B81A),
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ),
        if (sel.photos.isNotEmpty) ...[
          const SizedBox(height: 14),
          _fotosHorizontal(sel.photos),
        ],
      ],
    );
  }

  // ── Helpers compartilhados ────────────────────────────────────────────────

  Widget _headerComIr({
    required String nome,
    required String endereco,
    required VoidCallback onIr,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nome,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: Colors.grey),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(endereco,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
              if (_distanciaTexto.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('$_tempoTexto · $_distanciaTexto',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF1B81A),
                        fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _carregandoNav ? null : onIr,
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF1B81A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: const Color(0xFFF1B81A).withOpacity(0.4),
                  blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: _carregandoNav
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.navigation,
                          color: Colors.white, size: 22),
                      Text('Ir',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _fotosHorizontal(List<String> fotos) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: fotos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) =>
                PhotoViewer(fotos: fotos, indiceInicial: i),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          )),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              fotos[i], width: 130, height: 90, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 130, height: 90,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildEndereco(DestinationModel d) {
    return [
      if (d.street.isNotEmpty) d.street,
      if (d.number.isNotEmpty) d.number,
      if (d.neighborhood.isNotEmpty) d.neighborhood,
      if (d.city.isNotEmpty) d.city,
      if (d.state.isNotEmpty) d.state,
    ].join(', ');
  }
}