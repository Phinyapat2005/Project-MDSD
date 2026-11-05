import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'favorite.dart';
import 'screens/search_screen.dart';

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
      title: 'OutfitCheck',
      theme: ThemeData(
        fontFamily: 'Sukhumvit Set',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D2C24)),
      ),
      // กำหนด Routes สำหรับใช้เปลี่ยนหน้า
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/favorite': (context) =>
            const FavoriteScreen(), // เรียกใช้คลาส FavoriteScreen
        '/search': (context) => const SearchScreen(),
      },
      // ตรวจสอบสถานะการ Login
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const ProfileScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
