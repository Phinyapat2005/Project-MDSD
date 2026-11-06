import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const LoginScreen({
    super.key,
    this.auth,
    this.firestore,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  FirebaseAuth get _auth {
    if (widget.auth != null) return widget.auth!;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return FirebaseAuth.instance;
    }
  }

  FirebaseFirestore get _firestore {
    if (widget.firestore != null) return widget.firestore!;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return FirebaseFirestore.instance;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginLocally(String email) {
    final defaultName = email.split('@').first;
    _showSnackBar('เข้าสู่ระบบสำเร็จ (โหมดจำลองออฟไลน์)', Colors.brown);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userId: email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_'),
            userName: defaultName,
          ),
        ),
      );
    }
  }

  // ------------------ 1. เข้าสู่ระบบด้วย Email/Password ------------------
  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('กรุณากรอกอีเมลและรหัสผ่านให้ครบถ้วน', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return;
      }
    } on FirebaseAuthException catch (e) {
      // 1. ถ้าไม่พบบัญชีในระบบ ให้สร้างบัญชีให้อัตโนมัติทันที
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          final registerCred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          final regUser = registerCred.user;
          if (regUser != null && mounted) {
            final defaultName = email.split('@').first;
            try {
              await _firestore.collection('users').doc(regUser.uid).set({
                'name': defaultName,
                'email': email,
                'photoUrl': '',
                'phone': 'ยังไม่ระบุ',
                'birthDate': 'ยังไม่ระบุ',
                'height': '175',
                'weight': '68',
                'waist': '32',
                'chest': '-',
                'hips': '-',
              });
            } catch (_) {}

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
            return;
          }
        } on FirebaseAuthException catch (regErr) {
          if (regErr.code == 'email-already-in-use') {
            _showSnackBar('รหัสผ่านไม่ถูกต้อง กรุณาตรวจสอบรหัสผ่านอีกครั้ง', Colors.red);
            return;
          } else if (regErr.code == 'weak-password') {
            _showSnackBar('รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร', Colors.orange);
            return;
          }
        } catch (_) {}
      }

      // 2. ถ้า Firebase ปิด Email/Password หรือเชื่อมต่อเน็ตไม่ได้ ให้ใช้ Local Session สำรอง
      if (e.code == 'operation-not-allowed' ||
          e.code == 'network-request-failed' ||
          e.code == 'channel-error') {
        _loginLocally(email);
        return;
      }

      String message = 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
      if (e.code == 'wrong-password') {
        message = 'รหัสผ่านไม่ถูกต้อง';
      } else if (e.code == 'invalid-email') {
        message = 'รูปแบบอีเมลไม่ถูกต้อง';
      } else if (e.code == 'too-many-requests') {
        message = 'พยายามเข้าสู่ระบบถี่เกินไป กรุณารอสักครู่แล้วลองใหม่';
      } else {
        message = 'เข้าสู่ระบบไม่สำเร็จ (${e.code})';
      }
      _showSnackBar(message, Colors.red);
    } catch (e) {
      // กรณี Firebase เกิดปัญหาเรื่อง Configuration / no-app
      _loginLocally(email);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ------------------ 2. สมัครสมาชิกใหม่ด้วย Email/Password ------------------
  Future<void> _registerWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('กรุณากรอกอีเมลและรหัสผ่านเพื่อสมัครสมาชิก', Colors.orange);
      return;
    }

    if (password.length < 6) {
      _showSnackBar('รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        final defaultName = email.split('@').first;

        try {
          await _firestore.collection('users').doc(user.uid).set({
            'name': defaultName,
            'email': email,
            'photoUrl': '',
            'phone': 'ยังไม่ระบุ',
            'birthDate': 'ยังไม่ระบุ',
            'height': '175',
            'weight': '68',
            'waist': '32',
            'chest': '-',
            'hips': '-',
          });
        } catch (_) {}

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          final loginCred = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (loginCred.user != null && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
            return;
          }
        } catch (_) {}
        _showSnackBar('อีเมลนี้ถูกใช้งานแล้ว หากเป็นบัญชีของคุณ กรุณากดเข้าสู่ระบบ', Colors.red);
      } else if (e.code == 'weak-password') {
        _showSnackBar('รหัสผ่านง่ายเกินไป (ต้องมีความยาวอย่างน้อย 6 ตัวอักษร)', Colors.orange);
      } else if (e.code == 'invalid-email') {
        _showSnackBar('รูปแบบอีเมลไม่ถูกต้อง', Colors.red);
      } else if (e.code == 'operation-not-allowed' || e.code == 'network-request-failed') {
        _loginLocally(email);
      } else {
        _showSnackBar('การสมัครสมาชิกล้มเหลว (${e.code})', Colors.red);
      }
    } catch (e) {
      _loginLocally(email);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: bgColor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EE),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ไอคอนแอปพลิเคชัน
              const Icon(
                Icons.account_circle,
                size: 90,
                color: Color(0xFF3C261A),
              ),
              const SizedBox(height: 16),
              const Text(
                'ยินดีต้อนรับเข้าสู่ระบบ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C261A),
                ),
              ),
              const SizedBox(height: 28),

              // ช่องกรอก Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'อีเมล (Email)',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF3C261A),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ช่องกรอก Password
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน (Password)',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF3C261A),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                // ปุ่ม เข้าสู่ระบบด้วย Email
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3C261A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _signInWithEmail,
                  child: const Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                // ปุ่ม สมัครสมาชิก
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3C261A),
                    minimumSize: const Size(double.infinity, 45),
                    side: const BorderSide(color: Color(0xFF3C261A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _registerWithEmail,
                  child: const Text('ยังไม่มีบัญชี? สมัครสมาชิก'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
