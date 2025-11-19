import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final double rating;
  final String category;
  final String distance;
  final String time;
  final String deliveryPrice;

  const CategoryWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.rating,
    required this.category,
    required this.distance,
    required this.time,
    required this.deliveryPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            imagePath,
            width: 55,
            height: 55,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  const Text("·", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    category,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  const Text("·", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    distance,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    deliveryPrice,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
