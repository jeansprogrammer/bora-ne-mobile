import 'package:boranemobile/view/pages/routes_page.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int selectedIndex = 0;

  final List<Map<String, String>> categories = [
    {
      "title": "Religioso",
      "image": "../../assets/images/bible.png",
    },
    {
      "title": "Gastronômico",
      "image": "../../assets/images/burger.png",
    },
    {
      "title": "Histórico",
      "image": "../../assets/images/hieroglyph.png",
    },
    {
      "title": "Aventuras",
      "image": "../../assets/images/tent.png",
    },
    {
      "title": "Outros",
      "image": "../../assets/images/searching.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final category = categories[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                          context,
                           MaterialPageRoute(builder: (_) => RoutesPage()),
                        );
              setState(() => selectedIndex = index);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedIndex == index
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        category["image"]!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category["title"]!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
