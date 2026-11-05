import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OutfitCheck App',
      theme: ThemeData(fontFamily: 'Sukhumvit Set'),
      home: const Scaffold(
        body: Center(
          child: Text(
            'OutfitCheck App - Firestore Backend Ready',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
