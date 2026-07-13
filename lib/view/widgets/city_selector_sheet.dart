import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/location_service.dart';

// Bottom sheet de seleção de cidade, compartilhado entre a Home e o Editar
// Perfil: como ambos leem/escrevem no mesmo LocationService singleton, a
// cidade escolhida em um lugar aparece automaticamente no outro.
Stream<List<String>> _streamCidadesDoFirestore() {
  return FirebaseFirestore.instance.collection('routes').snapshots().map(
    (snapshot) {
      final cidades = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return (data['city'] as String? ?? '').trim();
          })
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      return cidades;
    },
  );
}

Future<void> showCitySelectorSheet(BuildContext context) {
  final locationService = LocationService();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Selecionar cidade',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
              'Escolha uma cidade para ver as rotas disponíveis.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),

            if (locationService.cidadeDetectada != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location,
                      color: Colors.orangeAccent, size: 20),
                ),
                title: Text(
                  'Usar minha localização (${locationService.cidadeDetectada})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Detectada automaticamente'),
                trailing: locationService.cidadeManual == null
                    ? const Icon(Icons.check_circle,
                        color: Colors.orangeAccent)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  locationService.usarMinhaLocalizacao();
                },
              ),

            if (locationService.cidadeDetectada != null)
              const Divider(height: 8),

            const SizedBox(height: 4),
            const Text('Cidades disponíveis',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<List<String>>(
                stream: _streamCidadesDoFirestore(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Colors.orangeAccent),
                    );
                  }
                  if (!snap.hasData || snap.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma cidade encontrada.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final cidades = snap.data!;
                  return ListView.separated(
                    controller: scrollController,
                    itemCount: cidades.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final cidade = cidades[i];
                      final selecionada =
                          locationService.cidadeAtiva == cidade;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selecionada
                                ? Colors.orangeAccent.withOpacity(0.15)
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.location_city,
                              color: selecionada
                                  ? Colors.orangeAccent
                                  : Colors.grey,
                              size: 20),
                        ),
                        title: Text(cidade,
                            style: TextStyle(
                              fontWeight: selecionada
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selecionada
                                  ? Colors.orangeAccent
                                  : Colors.black87,
                            )),
                        trailing: selecionada
                            ? const Icon(Icons.check_circle,
                                color: Colors.orangeAccent)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          locationService.selecionarCidadeManual(cidade);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
