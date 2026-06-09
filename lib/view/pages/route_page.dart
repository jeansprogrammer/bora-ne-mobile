import 'package:flutter/material.dart';

class RoutePage extends StatelessWidget {
  const RoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    final destinos = [
      {
        "titulo": "Varanda Restaurante",
        "descricao":
            "Culinária sofisticada com pratos regionais e ambiente elegante.",
        "local": "Heliópolis, Garanhuns - PE",
        "imagem":
            "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4",
      },
      {
        "titulo": "O Relojoeiro Restaurante",
        "descricao":
            "Refinado com sabores regionais e clima aconchegante.",
        "local": "Heliópolis, Garanhuns - PE",
        "imagem":
            "https://images.unsplash.com/photo-1552566626-52f8b828add9",
      },
      {
        "titulo": "Pizzaria Modelo",
        "descricao":
            "Famosa pelas pizzas artesanais e ambiente descontraído.",
        "local": "Heliópolis, Garanhuns - PE",
        "imagem":
            "https://images.unsplash.com/photo-1513104890138-7c749659a591",
      },
      {
        "titulo": "Chocolate Sete Colinas",
        "descricao":
            "Chocolates artesanais, cafés e doces típicos da cidade.",
        "local": "Heliópolis, Garanhuns - PE",
        "imagem":
            "https://images.unsplash.com/photo-1511920170033-f8396924c348",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// TOPO
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                    ),

                    Expanded(
                      child: Center(
                        child: Image.asset(
                          "assets/images/logo.png",
                          height: 40,
                        ),
                      ),
                    ),

                    const SizedBox(width: 40),
                  ],
                ),
              ),

              /// BANNER
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://images.unsplash.com/photo-1504674900247-0877df9cc836",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// DESCRIÇÃO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Conheça igrejas históricas, tradições e a espiritualidade presente no coração do Nordeste.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// TITULO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Roteiro da experiência",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// LISTA DE DESTINOS
              ListView.builder(
                itemCount: destinos.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 30),
                itemBuilder: (context, index) {
                  final destino = destinos[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// TIMELINE
                        Column(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD6A84F),
                                shape: BoxShape.circle,
                              ),
                            ),

                            if (index != destinos.length - 1)
                              Container(
                                width: 3,
                                height: 120,
                                color: const Color(0xFFD6A84F),
                              ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        /// CARD
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [

                                /// IMAGEM
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    destino["imagem"]!,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                /// TEXTOS
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        destino["titulo"]!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        destino["descricao"]!,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        destino["local"]!,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
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
      ),

      /// BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFD6A84F),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Favoritos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: "Adicionar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: "Notificações",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}