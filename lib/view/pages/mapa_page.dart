import 'dart:convert';

import 'package:boranemobile/models/destination_model.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class TelaMapa extends StatefulWidget {

  final DestinationModel destino;
  final LatLng userLocation; // Localização que você já pega via Geoapify

  const TelaMapa({
    super.key, 
    required this.destino, 
    required this.userLocation,
  });

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final TextEditingController searchController = TextEditingController();
  final mapController = MapController();

  final String apiKey = "aeccc7dd6dea4139a6cf6da8046a2f75";
  final mapStyleUrl =
      "https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=aeccc7dd6dea4139a6cf6da8046a2f75";

  List<LatLng> rotaPontos = [];
  String distanciaTexto = "Calculando...";
  String tempoTexto = "...";
  bool carregandoRota = true;

  @override
  void initState() {
    super.initState();
    // Inicia a busca da rota assim que a tela abre
    _buscarRotaGeoapify();
  }

  Future<void> _buscarRotaGeoapify() async {
    final LatLng origem = widget.userLocation;
    final LatLng destino = LatLng(widget.destino.latitude, widget.destino.longitude);

    // Endpoint de roteamento da Geoapify (modo de viagem: 'drive' para carro, ou 'walk')
    final url = Uri.parse(
      'https://api.geoapify.com/v1/routing?waypoints=${origem.latitude},${origem.longitude}|${destino.latitude},${destino.longitude}&mode=drive&apiKey=$apiKey'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['features'] != null && data['features'].isNotEmpty) {
          final feature = data['features'][0];
          
          // 1. Extrai distância (metros) e tempo (segundos)
          final double distanceMetros = feature['properties']['distance'].toDouble();
          final double timeSegundos = feature['properties']['time'].toDouble();

          // 2. Converte para formatos amigáveis
          final double distanceKm = distanceMetros / 1000;
          final int tempoMinutos = (timeSegundos / 60).round();

          // 3. Extrai as coordenadas da geometria para desenhar a linha
          final List geometry = feature['geometry']['coordinates'][0];
          List<LatLng> pontos = [];
          
          for (var coord in geometry) {
            // Nota: Geoapify retorna [longitude, latitude] na lista da geometria GeoJSON
            pontos.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
          }

          setState(() {
            rotaPontos = pontos;
            distanciaTexto = "${distanceKm.toStringAsFixed(1)} km";
            tempoTexto = "$tempoMinutos min";
            carregandoRota = false;
          });

          // Ajusta o zoom do mapa automaticamente para enquadrar a rota inteira
          _enquadrarMapa();
        }
      } else {
        setState(() {
          distanciaTexto = "Erro ao calcular";
          carregandoRota = false;
        });
      }
    } catch (e) {
      setState(() {
        distanciaTexto = "Erro de conexão";
        carregandoRota = false;
      });
    }
  }

  void _enquadrarMapa() {
    if (rotaPontos.isEmpty) return;
    
    // Calcula os limites (Bounds) para centralizar a câmera perfeitamente entre os dois locais
    final bounds = LatLngBounds.fromPoints(rotaPontos);
    mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50.0), // Margem de respiro nas bordas do mapa
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng destinoLatLng = LatLng(widget.destino.latitude, widget.destino.longitude);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomNav(),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: destinoLatLng, // Foca inicialmente no destino
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: mapStyleUrl,
                      userAgentPackageName: 'com.example.app',
                    ),
                    // DESENHA A LINHA DA ROTA (Estilo Uber/GoogleMaps)
                    if (rotaPontos.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: rotaPontos,
                            strokeWidth: 5.0,
                            color: Colors.blueAccent, // Cor da rota principal
                          ),
                        ],
                      ),
                    // MARCADORES (Origem e Destino)
                    MarkerLayer(
                      markers: [
                        // Marcador do Usuário (Origem)
                        Marker(
                          width: 40,
                          height: 40,
                          point: widget.userLocation,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        // Marcador do Destino
                        Marker(
                          width: 40,
                          height: 40,
                          point: destinoLatLng,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Barra de pesquisa flutuante
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "O que você está procurando?",
                            ),
                          ),
                        ),
                        const Icon(Icons.search, size: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // PAINEL INFERIOR DINÂMICO
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.destino.name, // Nome dinâmico vindo do Firebase
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Distância e Tempo calculados dinamicamente
                        Row(
                          children: [
                            if (carregandoRota)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              Text(
                                "$tempoTexto ($distanciaTexto)",
                                style: const TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${widget.destino.street}, ${widget.destino.number} - ${widget.destino.neighborhood}, ${widget.destino.city} - ${widget.destino.state}",
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    // Imagens dinâmicas vindas da sua lista 'photos' do Firebase
                    Row(
                      children: [
                        if (widget.destino.photos.isNotEmpty)
                          ...widget.destino.photos.take(2).map((url) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  url,
                                  height: 85,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 85,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                          ))
                        else ...[
                          Expanded(
                            child: Container(
                              height: 85,
                              color: Colors.grey[300],
                              child: const Center(child: Text("Sem fotos")),
                            ),
                          )
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}