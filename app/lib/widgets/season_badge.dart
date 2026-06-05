import 'package:flutter/material.dart';

class SeasonBadge extends StatelessWidget {
  final Map<String, String> season;
  final String destination;

  const SeasonBadge({
    super.key,
    required this.season,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final isGood = season['cls'] == 'good';
    final isOk = season['cls'] == 'ok';

    final bgColor = isGood
        ? const Color(0xFFE8F5E9)
        : isOk
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFFDE8E8);

    final textColor = isGood
        ? const Color(0xFF2E7D32)
        : isOk
            ? const Color(0xFFE65100)
            : const Color(0xFFC0392B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$destination — Mausam Ka Haal',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(season['label']!,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
          const SizedBox(height: 6),
          Text(season['tip']!,
              style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}