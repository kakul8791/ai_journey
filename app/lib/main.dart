import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const GhumFirApp());

class GhumFirApp extends StatelessWidget {
  const GhumFirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GhumFir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC0392B),
        ),
        scaffoldBackgroundColor: const Color(0xFFFDF6EE),
        fontFamily: 'Nunito',
      ),
      home: const HomeScreen(),
    );
  }
}