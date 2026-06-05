import 'package:flutter/material.dart';
import '../models/trip_plan.dart';
import '../models/route_option.dart';
import '../utils/season_helper.dart';

class ResultScreen extends StatelessWidget {
  final TripPlan plan;
  const ResultScreen({super.key, required this.plan});

  static const _green = Color(0xFF2E7D32);
  static const _red = Color(0xFFC0392B);
  static const _gold = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    final routes = RouteOption.getRoutes(plan);
    final season = SeasonHelper.getSeason(plan.to, plan.travelDate.month - 1);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSeasonCard(season),
                  const SizedBox(height: 10),
                  ...routes.map((r) => _buildRouteCard(r)),
                  _buildProTip(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _green,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('${plan.from} → ${plan.to}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatPill('₹${plan.budgetPerPerson}/person'),
              const SizedBox(width: 8),
              _buildStatPill('${plan.persons} log'),
              const SizedBox(width: 8),
              _buildStatPill(plan.travelMode.toUpperCase()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildSeasonCard(Map<String, String> season) {
    final isGood = season['cls'] == 'good';
    final isOk = season['cls'] == 'ok';
    final bgColor = isGood
        ? const Color(0xFFE8F5E9)
        : isOk
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFFDE8E8);
    final textColor = isGood
        ? _green
        : isOk
            ? const Color(0xFFE65100)
            : _red;

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
          Text('${plan.to} — Mausam Ka Haal',
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

  Widget _buildRouteCard(RouteOption route) {
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
              _buildDetail('💸 ₹${route.costPerPerson}/person'),
              const SizedBox(width: 12),
              _buildDetail('⏱ ${route.duration}'),
              const SizedBox(width: 12),
              _buildDetail(route.comfort),
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

  Widget _buildDetail(String text) {
    return Text(text,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]));
  }

  Widget _buildProTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '💡 Pro Tip: ${plan.from} se ${plan.to} ke liye — group me jao toh self drive sabse sasta pad sakta hai!',
        style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF795548),
            fontWeight: FontWeight.w600),
      ),
    );
  }
}2