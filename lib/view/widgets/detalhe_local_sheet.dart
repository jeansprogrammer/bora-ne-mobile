import 'package:flutter/material.dart';

class DetalheLocalSheet extends StatelessWidget {
  final String titulo;
  final String img;
  final int nota;

  const DetalheLocalSheet({
    super.key,
    required this.titulo,
    required this.img,
    required this.nota,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            children: [
              // Indicador
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Imagem
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  img,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 16),

              // Título + ações
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Adicionado aos favoritos'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Nota
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    color: i < nota ? Colors.orange : Colors.grey[300],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Descrição
              const Text(
                "Este local é um importante ponto turístico e religioso da cidade. "
                "Oferece uma experiência cultural, histórica e espiritual, sendo "
                "muito visitado por moradores e turistas.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
