// destination_detail.dart
import 'package:flutter/material.dart';

class DestinationDetail extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;

  const DestinationDetail({super.key, required this.id, required this.data});

  @override
  Widget build(BuildContext context) {
    final nome        = data['name']        ?? 'Sem título';
    final descricao   = data['description'] ?? '';
    final coverPhoto  = data['coverPhoto']  ?? '';
    final categories  = List<String>.from(data['categories'] ?? []);
    final neighborhood = data['neighborhood'] ?? '';
    final city        = data['city']        ?? '';
    final state       = data['state']       ?? '';
    final local = '${neighborhood.isNotEmpty ? '$neighborhood, ' : ''}$city – $state';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.orangeAccent,
            flexibleSpace: FlexibleSpaceBar(
              background: coverPhoto.isNotEmpty
                  ? Image.network(coverPhoto, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  if (categories.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: categories
                          .map((c) => Chip(
                                label: Text(c,
                                    style: const TextStyle(fontSize: 11)),
                                backgroundColor:
                                    Colors.orangeAccent.withOpacity(0.15),
                                side: BorderSide.none,
                                padding: EdgeInsets.zero,
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(local,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(descricao,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFFFF9E7),
        child: const Center(
          child: Icon(Icons.image_outlined,
              color: Colors.orangeAccent, size: 48),
        ),
      );
}