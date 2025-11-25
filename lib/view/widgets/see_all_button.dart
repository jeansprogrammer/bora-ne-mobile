import 'package:flutter/material.dart';

class SeeAllButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const SeeAllButton({
    super.key,
    this.label = "Ver todas",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap, // você controla a navegação depois
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_circle_right_sharp,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}
