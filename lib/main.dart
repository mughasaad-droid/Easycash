import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/started.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EasyCashApp());
}

class EasyCashApp extends StatelessWidget {
  const EasyCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyCash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const StartedScreen(),
    );
  }
}
