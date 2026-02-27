import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymCoach',
      theme: AppTheme.dark,
      home: const Scaffold(
        body: Center(
          child: Text(
            'GymCoach 💪',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}