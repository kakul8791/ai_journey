import 'package:flutter/material.dart';

class TripCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
            Text(subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}