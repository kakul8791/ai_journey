import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const JourneyPlannerApp());
}

class JourneyPlannerApp extends StatelessWidget {
  const JourneyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journey Planner AI',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),

      home: const ChatScreen(),
    );
  }
}