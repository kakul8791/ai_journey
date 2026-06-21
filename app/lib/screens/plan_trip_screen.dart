// import 'package:flutter/material.dart';
// import 'api_service.dart';

// import 'result_screen.dart';

// class PlanTripScreen extends StatefulWidget {
//   const PlanTripScreen({super.key});

//   @override
//   State<PlanTripScreen> createState() => _PlanTripScreenState();
// }

// class _PlanTripScreenState extends State<PlanTripScreen> with TickerProviderStateMixin {
//   final TextEditingController _inputCtrl = TextEditingController();
//   final ScrollController _scrollCtrl = ScrollController();
//   final ApiService _api = ApiService();

//   List<Map<String, dynamic>> _messages = [];
//   List<Map<String, dynamic>> _history = [];
//   bool _isLoading = false;
//   Map<String, dynamic>? _tripParams;

//   final List<String> _quickReplies = [
//     'Couple trip 💑',
//     'Family vacation 👨‍👩‍👧',
//     'Friends gang 🎉',
//     'Budget ₹15,000',
//     '3 days trip',
//     'Within 300 km',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _addBotMessage(
//       "Namaste! 🙏 I'm your AI Journey Planner.\n\nTell me about your dream trip! You can say something like:\n\n\"Planning a couple trip from Delhi, 4 days, budget ₹20,000, within 400 km\" 🗺️",
//     );
//   }

//   void _addBotMessage(String text) {
//     setState(() {
//       _messages.add({'role': 'assistant', 'content': text, 'time': _timeNow()});
//     });
//     _scrollToBottom();
//   }

//   void _addUserMessage(String text) {
//     setState(() {
//       _messages.add({'role': 'user', 'content': text, 'time': _timeNow()});
//     });
//     _scrollToBottom();
//   }

//   String _timeNow() {
//     final now = DateTime.now();
//     return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
//   }

//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 200), () {
//       if (_scrollCtrl.hasClients) {
//         _scrollCtrl.animateTo(
//           _scrollCtrl.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     
//   }

//   Future<void> _sendMessage(String text) async {
//     if (text.trim().isEmpty) return;
//     _inputCtrl.clear();
//     _addUserMessage(text);

//     setState(() => _isLoading = true);

//     try {
//       final response = await _api.chat(
//         message: text,
//         history: _history,
//       );

//       _history.add({'role': 'user', 'content': text});

//       if (response['type'] == 'ready') {
//         _tripParams = response['trip_params'];
//         _addBotMessage(response['message']);
//         _history.add({'role': 'assistant', 'content': response['message']});
//         await Future.delayed(const Duration(milliseconds: 800));
//         if (mounted) {
//           _navigateToResults();
//         }
//       } else {
//         final botMsg = response['message'] ?? 'Can you tell me more?';
//         _addBotMessage(botMsg);
//         _history.add({'role': 'assistant', 'content': botMsg});

//         if (response['extracted_so_far'] != null) {
//           _history.last['extracted_so_far'] = response['extracted_so_far'];
//         }
//       }
//     } catch (e) {
//       _addBotMessage('Oops! Network error. Make sure the backend server is running on port 8000. 🔧');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _navigateToResults() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ResultScreen(tripParams: _tripParams!),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1F17),
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           Expanded(child: _buildMessageList()),
//           if (_isLoading) _buildTypingIndicator(),
//           _buildQuickReplies(),
//           _buildInputBar(),
//         ],
//       ),
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
//       title: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
//           ),
//           const SizedBox(width: 10),
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'AI Planner',
//                 style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
//               ),
//               Text(
//                 'Online • Ready to plan',
//                 style: TextStyle(color: Color(0xFF0DBC72), fontSize: 11),
//               ),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.refresh, color: Colors.white70),
//           onPressed: () {
//             setState(() {
//               _messages.clear();
//               _history.clear();
//               _tripParams = null;
//             });
//             _addBotMessage("Fresh start! 🆕 Tell me about your next trip!");
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildMessageList() {
//     return ListView.builder(
//       controller: _scrollCtrl,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       itemCount: _messages.length,
//       itemBuilder: (context, index) {
//         final msg = _messages[index];
//         final isUser = msg['role'] == 'user';
//         return _buildMessageBubble(msg['content'], isUser, msg['time']);
//       },
//     );
//   }

//   Widget _buildMessageBubble(String text, bool isUser, String time) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isUser) ...[
//             Container(
//               width: 30,
//               height: 30,
//               margin: const EdgeInsets.only(right: 8),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
//             ),
//           ],
//           Flexible(
//             child: Column(
//               crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width * 0.72,
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   decoration: BoxDecoration(
//                     gradient: isUser
//                         ? const LinearGradient(
//                             colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
//                           )
//                         : null,
//                     color: isUser ? null : Colors.white.withOpacity(0.08),
//                     borderRadius: BorderRadius.only(
//                       topLeft: const Radius.circular(18),
//                       topRight: const Radius.circular(18),
//                       bottomLeft: Radius.circular(isUser ? 18 : 4),
//                       bottomRight: Radius.circular(isUser ? 4 : 18),
//                     ),
//                     border: isUser
//                         ? null
//                         : Border.all(color: Colors.white.withOpacity(0.1)),
//                   ),
//                   child: Text(
//                     text,
//                     style: TextStyle(
//                       color: isUser ? Colors.white : Colors.white.withOpacity(0.9),
//                       fontSize: 14,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
//                   child: Text(
//                     time,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.3),
//                       fontSize: 10,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isUser) const SizedBox(width: 8),
//         ],
//       ),
//     );
//   }

//   Widget _buildTypingIndicator() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
//       child: Row(
//         children: [
//           Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
//           ),
//           const SizedBox(width: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: Row(
//               children: [
//                 _dot(0),
//                 const SizedBox(width: 4),
//                 _dot(150),
//                 const SizedBox(width: 4),
//                 _dot(300),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _dot(int delayMs) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: 1),
//       duration: Duration(milliseconds: 600 + delayMs),
//       builder: (_, v, __) => AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         width: 6,
//         height: 6,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: const Color(0xFF0DBC72).withOpacity(0.4 + v * 0.6),
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickReplies() {
//     return SizedBox(
//       height: 44,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         itemCount: _quickReplies.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 8),
//         itemBuilder: (context, i) {
//           return GestureDetector(
//             onTap: () => _sendMessage(_quickReplies[i]),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.07),
//                 borderRadius: BorderRadius.circular(50),
//                 border: Border.all(color: const Color(0xFF1A6B4A).withOpacity(0.5)),
//               ),
//               child: Text(
//                 _quickReplies[i],
//                 style: const TextStyle(
//                   color: Color(0xFF0DBC72),
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInputBar() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//       decoration: BoxDecoration(
//         color: const Color(0xFF0D1F17),
//         border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.07),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.white.withOpacity(0.1)),
//               ),
//               child: TextField(
//                 controller: _inputCtrl,
//                 style: const TextStyle(color: Colors.white, fontSize: 14),
//                 maxLines: null,
//                 decoration: InputDecoration(
//                   hintText: 'Type your trip details...',
//                   hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 ),
//                 onSubmitted: _sendMessage,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           GestureDetector(
//             onTap: () => _sendMessage(_inputCtrl.text),
//             child: Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
//                 ),
//                 borderRadius: BorderRadius.circular(14),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF1A6B4A).withOpacity(0.4),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';
import 'result_screen.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ApiService _api = ApiService();
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  bool _isFocused = false;
  Map<String, dynamic>? _tripParams;

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const _primaryGreen = Color(0xFF00E676);
  static const _deepGreen = Color(0xFF00C853);
  static const _darkBg = Color(0xFF080F0C);
  static const _cardBg = Color(0xFF0F1F16);
  static const _surfaceBg = Color(0xFF152219);
  static const _borderColor = Color(0xFF1E3528);

  final List<Map<String, String>> _quickReplies = [
    {'label': '💑 Couple', 'value': 'Couple trip'},
    {'label': '👨‍👩‍👧 Family', 'value': 'Family vacation'},
    {'label': '🎉 Friends', 'value': 'Friends gang trip'},
    {'label': '₹15K Budget', 'value': 'Budget ₹15,000'},
    {'label': '3 Days', 'value': '3 days trip'},
    {'label': '300 km', 'value': 'Within 300 km'},
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });

     Future.delayed(const Duration(milliseconds: 400), () {
    //   _addBotMessage(
    //     "Namaste! 🙏 I'm your AI Journey Planner.\n\nTell me about your dream trip!\n\n\"Planning a couple trip from Delhi, 4 days, budget ₹20,000, within 400 km\" 🗺️",
    //   );
    // });
    _addBotMessage(
  "Welcome to AI Journey Plannerr ✨\n\nShare your destination, budget, duration, and travel preferences, and I'll create personalized recommendations for your's next adventure.\n\nExample: Couple trip from Delhi • 6 days • Budget ₹10,000 • Within 300 km",
);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _focusNode.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': text,
        'time': _timeNow(),
        'key': UniqueKey().toString(),
      });
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({
        'role': 'user',
        'content': text,
        'time': _timeNow(),
        'key': UniqueKey().toString(),
      });
    });
    _scrollToBottom();
  }

  String _timeNow() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    _inputCtrl.clear();
    _addUserMessage(text);
    setState(() => _isLoading = true);

    try {
      final response = await _api.chat(message: text, history: _history);
      _history.add({'role': 'user', 'content': text});

      if (response['type'] == 'ready') {
        _tripParams = response['trip_params'];
        _addBotMessage(response['message']);
        _history.add({'role': 'assistant', 'content': response['message']});
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) _navigateToResults();
      } else {
        final botMsg = response['message'] ?? 'Can you tell me more?';
        _addBotMessage(botMsg);
        _history.add({'role': 'assistant', 'content': botMsg});
        if (response['extracted_so_far'] != null) {
          _history.last['extracted_so_far'] = response['extracted_so_far'];
        }
      }
    } catch (e) {
      _addBotMessage('Oops! Network error. Make sure the backend is running on port 8000. 🔧');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToResults() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => ResultScreen(tripParams: _tripParams!),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _darkBg,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            if (_isLoading) _buildTypingIndicator(),
            _buildQuickReplies(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _darkBg.withOpacity(0.95),
      elevation: 0,
      toolbarHeight: 64,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _borderColor, width: 0.5),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _surfaceBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderColor),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 40,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF004D2C), Color(0xFF00C853)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.explore_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Journey Planner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Ready to plan your trip',
                    style: TextStyle(color: Color(0xFF4CAF7D), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _surfaceBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _borderColor),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 18),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() {
                _messages.clear();
                _history.clear();
                _tripParams = null;
              });
              _addBotMessage("Fresh start! 🆕 Tell me about your next adventure!");
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['role'] == 'user';
        return _AnimatedMessageBubble(
          key: ValueKey(msg['key']),
          text: msg['content'],
          isUser: isUser,
          time: msg['time'],
          index: index,
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004D2C), Color(0xFF00C853)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.explore_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BouncingDot(delay: 0),
                const SizedBox(width: 5),
                _BouncingDot(delay: 200),
                const SizedBox(width: 5),
                _BouncingDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        itemCount: _quickReplies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _sendMessage(_quickReplies[i]['value']!);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _surfaceBg,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: _borderColor, width: 0.8),
              ),
              child: Text(
                _quickReplies[i]['label']!,
                style: const TextStyle(
                  color: Color(0xFF4CAF7D),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      decoration: BoxDecoration(
        color: _darkBg,
        border: Border(
          top: BorderSide(color: _borderColor, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isFocused ? _deepGreen.withOpacity(0.5) : _borderColor,
                  width: _isFocused ? 1.5 : 0.8,
                ),
                boxShadow: _isFocused
                    ? [BoxShadow(color: _primaryGreen.withOpacity(0.08), blurRadius: 12)]
                    : [],
              ),
              child: TextField(
                controller: _inputCtrl,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Describe your dream trip...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_inputCtrl.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF005C33), Color(0xFF00C853)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGreen.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Message Bubble ──────────────────────────────────────────────────

class _AnimatedMessageBubble extends StatefulWidget {
  final String text;
  final bool isUser;
  final String time;
  final int index;

  const _AnimatedMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.time,
    required this.index,
  });

  @override
  State<_AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<_AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  static const _primaryGreen = Color(0xFF00E676);
  static const _cardBg = Color(0xFF0F1F16);
  static const _borderColor = Color(0xFF1E3528);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(widget.isUser ? 0.08 : -0.08, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 30), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            mainAxisAlignment:
                widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8, bottom: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF004D2C), Color(0xFF00C853)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryGreen.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.explore_rounded, color: Colors.white, size: 16),
                ),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: widget.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: widget.isUser
                            ? const LinearGradient(
                                colors: [Color(0xFF005C33), Color(0xFF00C853)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: widget.isUser ? null : _cardBg,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(widget.isUser ? 18 : 4),
                          bottomRight: Radius.circular(widget.isUser ? 4 : 18),
                        ),
                        border: widget.isUser
                            ? null
                            : Border.all(color: _borderColor, width: 0.8),
                        boxShadow: widget.isUser
                            ? [
                                BoxShadow(
                                  color: _primaryGreen.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.isUser
                              ? Colors.white
                              : Colors.white.withOpacity(0.88),
                          fontSize: 14,
                          height: 1.6,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 4, right: 4),
                      child: Text(
                        widget.time,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isUser) const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bouncing Dot ─────────────────────────────────────────────────────────────

class _BouncingDot extends StatefulWidget {
  final int delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF00C853),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}