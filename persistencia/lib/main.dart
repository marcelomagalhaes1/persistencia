import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magalu Anúncios',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0086FF),
          primary: const Color(0xFF0086FF),
          secondary: const Color(0xFFFFB800),
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}