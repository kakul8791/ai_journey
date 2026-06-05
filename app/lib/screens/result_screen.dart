// import 'package:flutter/material.dart';
// //import '../services/api_service.dart';
// import 'api_service.dart';
// //import 'itinerary_screen.dart';

// class ResultScreen extends StatefulWidget {
//   final Map<String, dynamic> tripParams;
//   const ResultScreen({super.key, required this.tripParams});

//   @override
//   State<ResultScreen> createState() => _ResultScreenState();
// }

// class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
//   final ApiService _api = ApiService();
//   List<dynamic> _recommendations = [];
//   bool _isLoading = true;
//   String? _error;

//   String _selectedTransport = 'car';
//   late AnimationController _staggerCtrl;

//   final List<Map<String, dynamic>> _transports = [
//     {'id': 'car', 'icon': '🚗', 'label': 'Car'},
//     {'id': 'bike', 'icon': '🏍️', 'label': 'Bike'},
//     {'id': 'bus', 'icon': '🚌', 'label': 'Bus'},
//     {'id': 'train', 'icon': '🚂', 'label': 'Train'},
//     {'id': 'flight', 'icon': '✈️', 'label': 'Flight'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _staggerCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _fetchRecommendations();
//   }

//   @override
//   void dispose() {
//     _staggerCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchRecommendations() async {
//     try {
//       final results = await _api.recommend(widget.tripParams);
//       setState(() {
//         _recommendations = results;
//         _isLoading = false;
//       });
//       _staggerCtrl.forward();
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   void _selectPlace(Map<String, dynamic> place) {
//     final params = {
//       'place_id': place['place_id'],
//       'origin': widget.tripParams['origin'],
//       'transport': _selectedTransport,
//       'num_people': widget.tripParams['num_people'],
//       'budget': widget.tripParams['budget'],
//       'days': widget.tripParams['days'],
//       'group_type': widget.tripParams['group_type'],
//     };

//     // Navigator.push(
//     //   context,
//     //   MaterialPageRoute(
//     //     builder: (_) => ItineraryScreen(
//     //       params: params,
//     //       placeName: place['name'],
//     //       placeState: place['state'] ?? '',
//     //     ),
//     //   ),
//     // );
//     print(place['name']);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1F17),
//       appBar: _buildAppBar(),
//       body: _isLoading
//           ? _buildLoadingState()
//           : _error != null
//               ? _buildErrorState()
//               : _buildContent(),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: const Color(0xFF0D1F17),
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
//         onPressed: () => Navigator.pop(context),
//       ),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Best Matches 🎯',
//             style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
//           ),
//           Text(
//             '${widget.tripParams['days']} days • ${widget.tripParams['group_type']} • ₹${(widget.tripParams['budget'] as num).toInt()}',
//             style: const TextStyle(color: Color(0xFF0DBC72), fontSize: 11),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
//               ),
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'AI is finding your\nbest destinations...',
//             style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           const CircularProgressIndicator(color: Color(0xFF0DBC72)),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text('❌', style: TextStyle(fontSize: 60)),
//           const SizedBox(height: 16),
//           Text(
//             'Backend not reachable',
//             style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Run: uvicorn main:app --reload\non port 8000',
//             style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () {
//               setState(() { _isLoading = true; _error = null; });
//               _fetchRecommendations();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A6B4A)),
//             child: const Text('Retry', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return Column(
//       children: [
//         _buildTransportSelector(),
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: _recommendations.length,
//             itemBuilder: (context, index) {
//               final delay = Duration(milliseconds: index * 100);
//               return FutureBuilder(
//                 future: Future.delayed(delay),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState != ConnectionState.done) {
//                     return const SizedBox.shrink();
//                   }
//                   return _buildPlaceCard(_recommendations[index], index);
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTransportSelector() {
//     return Container(
//       height: 70,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.04),
//         border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
//       ),
//       child: Row(
//         children: [
//           Text(
//             'Transport:',
//             style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: _transports.map((t) {
//                 final isSelected = _selectedTransport == t['id'];
//                 return GestureDetector(
//                   onTap: () => setState(() => _selectedTransport = t['id']),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     margin: const EdgeInsets.only(right: 8),
//                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//                     decoration: BoxDecoration(
//                       gradient: isSelected
//                           ? const LinearGradient(
//                               colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
//                             )
//                           : null,
//                       color: isSelected ? null : Colors.white.withOpacity(0.07),
//                       borderRadius: BorderRadius.circular(50),
//                       border: isSelected
//                           ? null
//                           : Border.all(color: Colors.white.withOpacity(0.1)),
//                     ),
//                     child: Row(
//                       children: [
//                         Text(t['icon']!, style: const TextStyle(fontSize: 14)),
//                         const SizedBox(width: 6),
//                         Text(
//                           t['label']!,
//                           style: TextStyle(
//                             color: isSelected ? Colors.white : Colors.white54,
//                             fontSize: 12,
//                             fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlaceCard(Map<String, dynamic> place, int index) {
//     final confidence = ((place['confidence_score'] ?? 0.5) * 100).round();
//     final tags = (place['tags'] as List?)?.cast<String>() ?? [];

//     return GestureDetector(
//       onTap: () => _selectPlace(place),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.06),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with rank badge
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: index == 0
//                       ? [const Color(0xFF1A6B4A), const Color(0xFF0DBC72)]
//                       : [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
//                 ),
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 32,
//                     height: 32,
//                     decoration: BoxDecoration(
//                       color: index == 0 ? Colors.white.withOpacity(0.2) : const Color(0xFF1A6B4A).withOpacity(0.4),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Center(
//                       child: Text(
//                         '#${index + 1}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           place['name'] ?? 'Unknown',
//                           style: TextStyle(
//                             color: index == 0 ? Colors.white : Colors.white.withOpacity(0.9),
//                             fontSize: 18,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                         Text(
//                           '${place['state']} • ${place['distance_km']} km away',
//                           style: TextStyle(
//                             color: index == 0 ? Colors.white70 : Colors.white38,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Column(
//                     children: [
//                       Text(
//                         '$confidence%',
//                         style: const TextStyle(
//                           color: Color(0xFF0DBC72),
//                           fontSize: 20,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       Text(
//                         'match',
//                         style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     place['description'] ?? '',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.7),
//                       fontSize: 13,
//                       height: 1.5,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 12),

//                   // Cost estimate
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1A6B4A).withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: const Color(0xFF1A6B4A).withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       children: [
//                         const Text('💰', style: TextStyle(fontSize: 18)),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Estimated Cost',
//                                 style: TextStyle(color: Colors.white54, fontSize: 11),
//                               ),
//                               Text(
//                                 '₹${place['min_spend_inr']} – ₹${place['max_spend_inr']}',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Column(
//                           children: [
//                             const Text('🌡️', style: TextStyle(fontSize: 14)),
//                             Text(
//                               '${place['avg_temp_c']}°C',
//                               style: const TextStyle(color: Colors.white60, fontSize: 11),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   // Why recommended
//                   if (place['why_recommended'] != null)
//                     Text(
//                       '✨ ${place['why_recommended']}',
//                       style: const TextStyle(
//                         color: Color(0xFF0DBC72),
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),

//                   const SizedBox(height: 12),

//                   // Tags
//                   Wrap(
//                     spacing: 6,
//                     runSpacing: 6,
//                     children: tags.take(4).map((tag) {
//                       return Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.07),
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                         child: Text(
//                           '#$tag',
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.6),
//                             fontSize: 11,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),

//                   const SizedBox(height: 16),

//                   // CTA button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () => _selectPlace(place),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF1A6B4A),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         elevation: 0,
//                       ),
//                       child: const Text(
//                         'Build Itinerary →',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
//import '../services/api_service.dart';
import 'api_service.dart';
//import 'itinerary_screen.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> tripParams;
  const ResultScreen({super.key, required this.tripParams});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<dynamic> _recommendations = [];
  bool _isLoading = true;
  String? _error;

  String _selectedTransport = 'car';
  late AnimationController _staggerCtrl;

  final List<Map<String, dynamic>> _transports = [
    {'id': 'car', 'icon': '🚗', 'label': 'Car'},
    {'id': 'bike', 'icon': '🏍️', 'label': 'Bike'},
    {'id': 'bus', 'icon': '🚌', 'label': 'Bus'},
    {'id': 'train', 'icon': '🚂', 'label': 'Train'},
    {'id': 'flight', 'icon': '✈️', 'label': 'Flight'},
  ];

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchRecommendations();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchRecommendations() async {
    try {
      final results = await _api.recommend(widget.tripParams);
      setState(() {
        _recommendations = results;
        _isLoading = false;
      });
      _staggerCtrl.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectPlace(Map<String, dynamic> place) {
    final params = {
      'place_id': place['place_id'],
      'origin': widget.tripParams['origin'],
      'transport': _selectedTransport,
      'num_people': widget.tripParams['num_people'],
      'budget': widget.tripParams['budget'],
      'days': widget.tripParams['days'],
      'group_type': widget.tripParams['group_type'],
    };

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => ItineraryScreen(
    //       params: params,
    //       placeName: place['name'],
    //       placeState: place['state'] ?? '',
    //     ),
    //   ),
    // );
    print(place['name']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F17),
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0D1F17),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best Matches 🎯',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            '${widget.tripParams['days']} days • ${widget.tripParams['group_type']} • ₹${(widget.tripParams['budget'] as num).toInt()}',
            style: const TextStyle(color: Color(0xFF0DBC72), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI is finding your\nbest destinations...',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(color: Color(0xFF0DBC72)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('❌', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'Backend not reachable',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Run: uvicorn main:app --reload\non port 8000',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() { _isLoading = true; _error = null; });
              _fetchRecommendations();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A6B4A)),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildTransportSelector(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final delay = Duration(milliseconds: index * 100);
              return FutureBuilder(
                future: Future.delayed(delay),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox.shrink();
                  }
                  return _buildPlaceCard(_recommendations[index], index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransportSelector() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Text(
            'Transport:',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _transports.map((t) {
                final isSelected = _selectedTransport == t['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedTransport = t['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
                            )
                          : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(50),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Text(t['icon']!, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          t['label']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place, int index) {
    final confidence = ((place['confidence_score'] ?? 0.5) * 100).round();
    final tags = (place['tags'] as List?)?.cast<String>() ?? [];

    return GestureDetector(
      onTap: () => _selectPlace(place),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with rank badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: index == 0
                      ? [const Color(0xFF1A6B4A), const Color(0xFF0DBC72)]
                      : [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: index == 0 ? Colors.white.withOpacity(0.2) : const Color(0xFF1A6B4A).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['name'] ?? 'Unknown',
                          style: TextStyle(
                            color: index == 0 ? Colors.white : Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${place['state']} • ${place['distance_km']} km away',
                          style: TextStyle(
                            color: index == 0 ? Colors.white70 : Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$confidence%',
                        style: const TextStyle(
                          color: Color(0xFF0DBC72),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'match',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place['description'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Cost estimate
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A6B4A).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1A6B4A).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estimated Cost',
                                style: TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                              Text(
                                '₹${place['min_spend_inr']} – ₹${place['max_spend_inr']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const Text('🌡️', style: TextStyle(fontSize: 14)),
                            Text(
                              '${place['avg_temp_c']}°C',
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Why recommended
                  if (place['why_recommended'] != null)
                    Text(
                      '✨ ${place['why_recommended']}',
                      style: const TextStyle(
                        color: Color(0xFF0DBC72),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags.take(4).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _selectPlace(place),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A6B4A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Build Itinerary →',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}