import 'package:boranemobile/view/pages/categories_page.dart';
import 'package:boranemobile/view/widgets/route_carousel.dart';
import 'package:boranemobile/view/widgets/see_all_button.dart';
import 'package:flutter/material.dart';
import 'package:boranemobile/view/widgets/category_list.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 245, 1),

      bottomNavigationBar: const CustomBottomNav(),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cabeçalho
                Column(
                  children: [
                    Container(
                      alignment: AlignmentDirectional(-0.8, 0.1),
                      width: 465,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.grey.shade300,
                      ),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'O que você está procurando?',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),


                const RouteCarousel(),


                const SizedBox(height: 20),

                // Categorias
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categorias',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SeeAllButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CategoriesPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const SizedBox(height: 20),
                const CategoryList(),

                const SizedBox(height: 20),

                // Favoritos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Favoritos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Ver todas',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.arrow_circle_right_sharp,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Placeholder de favoritos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Nenhum local favorito ainda',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
