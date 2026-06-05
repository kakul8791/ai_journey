// import 'package:flutter/material.dart';
// import 'api_service.dart';
// cd app
// flutter pub add http
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
//     });
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
import 'api_service.dart';

import 'result_screen.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> with TickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  Map<String, dynamic>? _tripParams;

  final List<String> _quickReplies = [
    'Couple trip 💑',
    'Family vacation 👨‍👩‍👧',
    'Friends gang 🎉',
    'Budget ₹15,000',
    '3 days trip',
    'Within 300 km',
  ];

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Namaste! 🙏 I'm your AI Journey Planner.\n\nTell me about your dream trip! You can say something like:\n\n\"Planning a couple trip from Delhi, 4 days, budget ₹20,000, within 400 km\" 🗺️",
    );
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'role': 'assistant', 'content': text, 'time': _timeNow()});
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({'role': 'user', 'content': text, 'time': _timeNow()});
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _inputCtrl.clear();
    _addUserMessage(text);

    setState(() => _isLoading = true);

    try {
      final response = await _api.chat(
        message: text,
        history: _history,
      );

      _history.add({'role': 'user', 'content': text});

      if (response['type'] == 'ready') {
        _tripParams = response['trip_params'];
        _addBotMessage(response['message']);
        _history.add({'role': 'assistant', 'content': response['message']});
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          _navigateToResults();
        }
      } else {
        final botMsg = response['message'] ?? 'Can you tell me more?';
        _addBotMessage(botMsg);
        _history.add({'role': 'assistant', 'content': botMsg});

        if (response['extracted_so_far'] != null) {
          _history.last['extracted_so_far'] = response['extracted_so_far'];
        }
      }
    } catch (e) {
      _addBotMessage('Oops! Network error. Make sure the backend server is running on port 8000. 🔧');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(tripParams: _tripParams!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F17),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_isLoading) _buildTypingIndicator(),
          _buildQuickReplies(),
          _buildInputBar(),
        ],
      ),
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
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Planner',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text(
                'Online • Ready to plan',
                style: TextStyle(color: Color(0xFF0DBC72), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white70),
          onPressed: () {
            setState(() {
              _messages.clear();
              _history.clear();
              _tripParams = null;
            });
            _addBotMessage("Fresh start! 🆕 Tell me about your next trip!");
          },
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['role'] == 'user';
        return _buildMessageBubble(msg['content'], isUser, msg['time']);
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
                          )
                        : null,
                    color: isUser ? null : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _dot(0),
                const SizedBox(width: 4),
                _dot(150),
                const SizedBox(width: 4),
                _dot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delayMs),
      builder: (_, v, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0DBC72).withOpacity(0.4 + v * 0.6),
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _quickReplies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => _sendMessage(_quickReplies[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFF1A6B4A).withOpacity(0.5)),
              ),
              child: Text(
                _quickReplies[i],
                style: const TextStyle(
                  color: Color(0xFF0DBC72),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F17),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _inputCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Type your trip details...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_inputCtrl.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A6B4A), Color(0xFF0DBC72)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A6B4A).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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