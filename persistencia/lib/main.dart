import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicialização do Hive compatível com Chrome e Telemóvel
  await Hive.initFlutter();
  runApp(const MeuAppListas());
}

class MeuAppListas extends StatelessWidget {
  const MeuAppListas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magalu - App Anúncios',
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