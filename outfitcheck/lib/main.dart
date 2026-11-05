import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // เริ่มต้นระบบ Firebase
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
      home: const HomeScreen(),
    );
  }
}

// หน้าเริ่มต้นชั่วคราวบน main branch
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OutfitCheck'), centerTitle: true),
      body: const Center(
        child: Text('Welcome to OutfitCheck', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
