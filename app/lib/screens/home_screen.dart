import 'package:flutter/material.dart';
import 'plan_trip_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _red = Color(0xFFC0392B);
  static const _green = Color(0xFF2E7D32);
  static const _cream = Color(0xFFFDF6EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(),
                    _buildSearchBar(context),
                    _buildTripTypeGrid(context),
                    _buildPopularDestinations(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GhumFir',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _red)),
              Text('Budget Travel Planner',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
          CircleAvatar(
            backgroundColor: _green,
            child: const Text('RK',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _red,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SMART TRAVEL',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('BEST TRIPS\nBEST BUDGET',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.1)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Season • Route • Budget',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const Text('✈️', style: TextStyle(fontSize: 48)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const PlanTripScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: _red, size: 20),
            const SizedBox(width: 10),
            Text('Kahan jaana hai? Budget kitna hai?',
                style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeGrid(BuildContext context) {
    final items = [
      {'emoji': '🚌', 'title': 'Bus Route', 'sub': 'Sabse sasta', 'bg': 0xFFE8F5E9},
      {'emoji': '🚆', 'title': 'Train Route', 'sub': 'Fast & cheap', 'bg': 0xFFFDE8E8},
      {'emoji': '🚗', 'title': 'Self Drive', 'sub': 'Aapki marzi', 'bg': 0xFFFFF8E1},
      {'emoji': '🗺️', 'title': 'Best Season', 'sub': 'Sahi time', 'bg': 0xFFFFFFFF},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plan Your Trip',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: items
                .map((item) => GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PlanTripScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(item['bg'] as int),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item['emoji'] as String,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(item['title'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                            Text(item['sub'] as String,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDestinations(BuildContext context) {
    final dests = [
      {'emoji': '🏔️', 'name': 'Manali', 'from': '₹2,500'},
      {'emoji': '🏖️', 'name': 'Goa', 'from': '₹3,000'},
      {'emoji': '🏯', 'name': 'Jaipur', 'from': '₹1,200'},
      {'emoji': '🌴', 'name': 'Kerala', 'from': '₹4,000'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Popular Destinations',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dests.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) => PlanTripScreen(
                            destHint: dests[i]['name']))),
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dests[i]['emoji']!,
                          style: const TextStyle(fontSize: 24)),
                      Text(dests[i]['name']!,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      Text(dests[i]['from']!,
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: _red,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Plan Trip'),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border), label: 'Saved'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
      onTap: (i) {
        if (i == 1) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PlanTripScreen()));
        }
      },
    );
  }
}