import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/report_form_screen.dart';

class SemesterProjectApp extends StatelessWidget {
  const SemesterProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexus Net Cafe',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B5CE2),
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
      ),
      routes: {
        '/report': (_) => const ReportFormScreen(),
      },
      home: const HomeScreen(),
    );
  }
}
