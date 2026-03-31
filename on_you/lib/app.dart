import 'package:flutter/material.dart';
import 'screens/main_shell.dart';

class OneYouApp extends StatelessWidget {
  const OneYouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'One-you',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF85C13D),
        ),
      ),
      home: const MainShell(),
    );
  }
}