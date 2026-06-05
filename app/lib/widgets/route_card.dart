import 'package:flutter/material.dart';
import '../models/route_option.dart';

class RouteCard extends StatelessWidget {
  final RouteOption route;

  const RouteCard({super.key, required this.route});

  static const _green = Color(0xFF2E7D32);
  static const _red = Color(0xFFC0392B);
  static const _gold = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    final borderColor = route.isBestValue
        ? _red
        : route.isSelfDrive
            ? _gold
            : _green;

    final badgeBg = route.isBestValue
        ? const Color(0xFFFDE8E8)
        : route.isSelfDrive
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFE8F5E9);

    final badgeText = route.isBestValue
        ? _red
        : route.isSelfDrive
            ? const Color(0xFFE65100)
            : _green;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${route.icon} ${route.name}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(route.badge,
                    style: TextStyle(
                        color: badgeText,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('💸 ₹${route.costPerPerson}/person',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(width: 12),
              Text('⏱ ${route.duration}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(width: 12),
              Text(route.comfort,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),
          ...route.steps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: borderColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(s,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700]))),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(route.tip,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}