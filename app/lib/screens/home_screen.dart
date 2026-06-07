// import 'package:flutter/material.dart';
// import 'plan_trip_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   late AnimationController _fadeCtrl;
//   late AnimationController _floatCtrl;
//   late Animation<double> _fadeAnim;
//   late Animation<double> _floatAnim;

//   // final List<Map<String, String>> _highlights = [
//   //   {'icon': '🏔️', 'label': 'Hills & Treks'},
//   //   {'icon': '🏖️', 'label': 'Beach Getaway'},
//   //   {'icon': '🦁', 'label': 'Wildlife Safari'},
//   //   {'icon': '🏯', 'label': 'Heritage Tours'},
//   //   {'icon': '🧘', 'label': 'Wellness Retreat'},
//   //   {'icon': '🎉', 'label': 'Friends Trips'},
//   // ];
// final List<Map<String, String>> _highlights = [
//   {'icon': '🏔️', 'label': 'Adventure Trails'},
//   {'icon': '🏝️', 'label': 'Luxury Beaches'},
//   {'icon': '🌲', 'label': 'Nature Escapes'},
//   {'icon': '🏛️', 'label': 'Historic Wonders'},
//   {'icon': '✨', 'label': 'Curated Experiences'},
//   {'icon': '🎉', 'label': 'Social Getaways'},
// ];

//   @override
//   void initState() {
//     super.initState();
//     _fadeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..forward();
//     _floatCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     )..repeat(reverse: true);

//     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
//     _floatAnim = Tween<double>(begin: -8, end: 8).animate(
//       CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _fadeCtrl.dispose();
//     _floatCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF0D1F17),
//               Color(0xFF0A2E20),
//               Color(0xFF061A12),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: FadeTransition(
//             opacity: _fadeAnim,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildTopBar(),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(horizontal: 24),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 32),
//                         _buildHeroSection(),
//                         const SizedBox(height: 40),
//                         _buildCategoryChips(),
//                         const SizedBox(height: 40),
//                         _buildStartButton(context),
//                         const SizedBox(height: 32),
//                         _buildStatsRow(),
//                         const SizedBox(height: 40),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTopBar() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1A6B4A),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(Icons.explore, color: Colors.white, size: 20),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'AI Journey',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
//               onPressed: () {},
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeroSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AnimatedBuilder(
//           animation: _floatAnim,
//           builder: (context, child) => Transform.translate(
//             offset: Offset(0, _floatAnim.value),
//             child: child,
//           ),
//           child: Container(
//             width: double.infinity,
//             height: 200,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(24),
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF1A6B4A), Color(0xFF0D9960)],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 // Background decorative circles
//                 Positioned(
//                   right: -30,
//                   top: -30,
//                   child: Container(
//                     width: 180,
//                     height: 180,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.05),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   right: 20,
//                   bottom: -40,
//                   child: Container(
//                     width: 130,
//                     height: 130,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.05),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         '✈️  Plan Your Perfect',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Trip with AI',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 36,
//                           fontWeight: FontWeight.w800,
//                           height: 1.1,
//                           letterSpacing: -1,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       const Text(
//                         'Budget. Days. Group. Done. 🎯',
//                         style: TextStyle(
//                           color: Colors.white60,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 28),
//         const Text(
//           'Where do you want to go?',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           'Tell our AI your budget, group & days — we handle the rest',
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.5),
//             fontSize: 13,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryChips() {
//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children: _highlights.map((h) {
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.07),
//             borderRadius: BorderRadius.circular(50),
//             border: Border.all(color: Colors.white.withOpacity(0.1)),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(h['icon']!, style: const TextStyle(fontSize: 16)),
//               const SizedBox(width: 6),
//               Text(
//                 h['label']!,
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildStartButton(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const PlanTripScreen()),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         height: 60,
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
//           ),
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFF1A6B4A).withOpacity(0.5),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.auto_awesome, color: Colors.white, size: 20),
//             SizedBox(width: 10),
//             Text(
//               'Start Planning with AI 🚀',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.3,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsRow() {
//     return Row(
//       children: [
//         _statCard('6+', 'Destinations'),
//         const SizedBox(width: 12),
//         _statCard('ML', 'Powered Reco'),
//         const SizedBox(width: 12),
//         _statCard('₹', 'Fuel Optimized'),
//       ],
//     );
//   }

//   Widget _statCard(String value, String label) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.white.withOpacity(0.08)),
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: const TextStyle(
//                 color: Color(0xFF0DBC72),
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.5),
//                 fontSize: 11,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'plan_trip_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _masterCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _floatAnim;
  late Animation<double> _shimmerAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _scaleAnim;

  int _selectedChip = -1;

  final List<Map<String, dynamic>> _highlights = [
    {'icon': '🏔️', 'label': 'Adventure', 'color': const Color(0xFF1A6B4A)},
    {'icon': '🏝️', 'label': 'Beaches', 'color': const Color(0xFF0D7A8A)},
    {'icon': '🌲', 'label': 'Nature', 'color': const Color(0xFF2D6A2F)},
    {'icon': '🏛️', 'label': 'Heritage', 'color': const Color(0xFF7A4D1A)},
    {'icon': '✨', 'label': 'Curated', 'color': const Color(0xFF5C2D8A)},
    {'icon': '🎉', 'label': 'Social', 'color': const Color(0xFF8A1A3D)},
  ];

  final List<Map<String, dynamic>> _stats = [
    {'value': '50+', 'label': 'Destinations', 'icon': Icons.location_on_outlined},
    {'value': 'AI', 'label': 'Smart Match', 'icon': Icons.auto_awesome_outlined},
    {'value': '₹', 'label': 'Fuel Saver', 'icon': Icons.local_gas_station_outlined},
  ];

  @override
  void initState() {
    super.initState();

    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
    _shimmerAnim = CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _masterCtrl.forward();
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _floatCtrl.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF071510),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF071510),
                Color(0xFF0A1E16),
                Color(0xFF061210),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              _buildBackgroundOrbs(),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Column(
                        children: [
                          _buildTopBar(),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  _buildGreetingRow(),
                                  const SizedBox(height: 20),
                                  _buildHeroCard(),
                                  const SizedBox(height: 28),
                                  _buildSectionLabel('Explore by Category'),
                                  const SizedBox(height: 14),
                                  _buildCategoryGrid(),
                                  const SizedBox(height: 28),
                                  _buildPlanButton(context),
                                  const SizedBox(height: 28),
                                  _buildStatsRow(),
                                  const SizedBox(height: 28),
                                  _buildTripTipCard(),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs() {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, _) {
        return Stack(
          children: [
            Positioned(
              top: -60 + _floatAnim.value * 0.5,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1A6B4A).withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 200 - _floatAnim.value * 0.3,
              left: -100,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0D9960).withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0DBC72).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.explore_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Journey',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _iconBtn(Icons.search_rounded, () {}),
              const SizedBox(width: 8),
              _iconBtn(Icons.notifications_none_rounded, () {}, badge: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool badge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          if (badge)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF0DBC72),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGreetingRow() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final emoji = hour < 12 ? '🌅' : hour < 17 ? '☀️' : '🌙';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting $emoji',
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Where next?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value * 0.6),
        child: child,
      ),
      child: Container(
        width: double.infinity,
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A6B4A), Color(0xFF0A4A32), Color(0xFF0D9960)],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A6B4A).withOpacity(0.45),
              blurRadius: 30,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: CustomPaint(painter: _ArcPainter()),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: CustomPaint(painter: _GridPainter()),
              ),
            ),
            AnimatedBuilder(
              animation: _shimmerAnim,
              builder: (context, _) {
                return Positioned(
                  left: -200 + _shimmerAnim.value * (MediaQuery.of(context).size.width + 400),
                  top: 0,
                  bottom: 0,
                  width: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 11),
                        SizedBox(width: 5),
                        Text(
                          'AI Powered Planning',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plan Your Perfect\nTrip with AI ✈️',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _heroPill('💰 Budget'),
                          const SizedBox(width: 6),
                          _heroPill('📅 Days'),
                          const SizedBox(width: 6),
                          _heroPill('👥 Group'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          'See all →',
          style: TextStyle(
            color: const Color(0xFF0DBC72).withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: _highlights.length,
      itemBuilder: (context, i) {
        final h = _highlights[i];
        final isSelected = _selectedChip == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedChip = isSelected ? -1 : i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected
                  ? (h['color'] as Color).withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? (h['color'] as Color).withOpacity(0.6)
                    : Colors.white.withOpacity(0.08),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (h['color'] as Color).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(h['icon'] as String, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(
                  h['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, anim, __) => const PlanTripScreen(),
                transitionsBuilder: (_, anim, __, child) {
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0DBC72).withOpacity(0.35 * _pulseAnim.value),
                  blurRadius: 24,
                  spreadRadius: -2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedBuilder(
                      animation: _shimmerAnim,
                      builder: (_, __) => Align(
                        alignment: Alignment(-1.5 + _shimmerAnim.value * 3, 0),
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.12),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Start Planning with AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('🚀', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: List.generate(_stats.length, (i) {
        final s = _stats[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < _stats.length - 1 ? 10 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(
                children: [
                  Icon(s['icon'] as IconData, color: const Color(0xFF0DBC72), size: 20),
                  const SizedBox(height: 8),
                  Text(
                    s['value'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s['label'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTripTipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0DBC72).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0DBC72).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0DBC72).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Text('💡', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pro Tip',
                  style: TextStyle(
                    color: Color(0xFF0DBC72),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tell our AI your full trip in one message for the fastest results!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width + 20, size.height + 20), radius: size.width * 0.85),
      math.pi,
      math.pi * 0.7,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width - 20, -30), radius: size.width * 0.55),
      math.pi * 0.3,
      math.pi * 0.8,
      false,
      paint..color = Colors.white.withOpacity(0.06),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.5;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}