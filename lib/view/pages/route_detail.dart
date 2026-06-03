import 'package:flutter/material.dart';

class RouteDetailPage extends StatelessWidget {
  final Map<String, dynamic> rota;

  const RouteDetailPage({super.key, required this.rota});

  @override
  Widget build(BuildContext context) {
    // ── Extraindo as informações básicas da Rota Principal ─────────────────
    final String nomeRota = rota['name'] ?? 'Sem título';
    final String coverPhotoRota = rota['coverPhoto'] ?? '';
    final String descricaoRota = rota['description'] ?? 'Sem descrição disponível.';
    final List<String> categories = List<String>.from(rota['categories'] ?? []);

    // ── Lista de Destinos Internos da Rota ─────────────────────────────────
    final List<dynamic> destinosRaw = rota['destinations'] ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(nomeRota, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem de Capa da Rota Principal
            if (coverPhotoRota.isNotEmpty)
              Image.network(
                coverPhotoRota,
                width: double.infinity,
                height: 230,
                fit: BoxFit.cover,
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categorias da Rota
                  if (categories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        categories.join(', '),
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  
                  // Título da Rota
                  Text(
                    nomeRota,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Descrição da Rota Principal
                  const Text(
                    'Sobre a rota',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    descricaoRota,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // ── SEÇÃO DE DESTINOS ──────────────────────────────────────
                  Row(
                    children: [
                      const Icon(Icons.alt_route, color: Colors.orangeAccent, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Paradas desta rota (${destinosRaw.length})',
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (destinosRaw.isEmpty)
                    const Text(
                      'Nenhum ponto turístico adicionado a esta rota.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    )
                  else
                    // Lista de Itinerário com Detalhes Completos do Destino
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: destinosRaw.length,
                      itemBuilder: (context, index) {
                        final item = destinosRaw[index] as Map<String, dynamic>;
                        
                        // Extraindo dados específicos do Destino atual
                        final String nomeDestino = item['name'] ?? 'Destino sem nome';
                        final String cidadeDestino = item['city'] ?? 'Cidade não especificada';
                        final String descricaoDestino = item['description'] ?? 'Sem descrição.';
                        
                        // Fallback de imagem do destino: pega a 'coverPhoto' ou a primeira do array 'photos'
                        final List<dynamic> fotosDestino = item['photos'] ?? [];
                        final String imagemDestino = item['coverPhoto'] ?? 
                            (fotosDestino.isNotEmpty ? fotosDestino.first : '');

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Indicador visual da Linha do Tempo (Timeline)
                              Column(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (index != destinosRaw.length - 1)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: Colors.orangeAccent.withOpacity(0.3),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              
                              // Card Expandido contendo Imagem, Nome, Cidade e Descrição
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias, // Garante o border radius na imagem
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 1. Imagem do Destino
                                      if (imagemDestino.isNotEmpty)
                                        Image.network(
                                          imagemDestino,
                                          width: double.infinity,
                                          height: 140,
                                          fit: BoxFit.cover,
                                        ),
                                      
                                      // 2. Informações de texto do Destino
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Nome do ponto turístico
                                            Text(
                                              nomeDestino,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                             
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            
                                            // Localização (Cidade) com Ícone
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  cidadeDestino,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            
                                            // Descrição do Destino
                                            Text(
                                              descricaoDestino,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade800,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}