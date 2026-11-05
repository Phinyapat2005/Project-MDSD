import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
      if (e.code == 'user-not-found') {
        message = 'ไม่พบบัญชีผู้ใช้นี้ในระบบ';
      } else if (e.code == 'wrong-password') {
        message = 'รหัสผ่านไม่ถูกต้อง';
      } else if (e.code == 'invalid-email') {
        message = 'รูปแบบอีเมลไม่ถูกต้อง';
      }
      _showSnackBar(message, Colors.red);
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e', Colors.red);
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
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        // ดึงชื่อนำหน้าจากอีเมล เช่น test@gmail.com -> test
        final defaultName = email.split('@').first;

        // บันทึกข้อมูลเริ่มต้นลง Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': defaultName,
          'email': email,
          'photoUrl': '',
          'phone': 'ยังไม่ระบุ',
          'birthDate': 'ยังไม่ระบุ',
          'height': '-',
          'weight': '-',
          'waist': '-',
          'chest': '-',
          'hips': '-',
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'การสมัครสมาชิกล้มเหลว';
      if (e.code == 'email-already-in-use') {
        message = 'อีเมลนี้ถูกใช้งานในระบบแล้ว';
      } else if (e.code == 'weak-password') {
        message = 'รหัสผ่านง่ายเกินไป';
      }
      _showSnackBar(message, Colors.red);
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ------------------ 3. เข้าสู่ระบบด้วย Google ------------------
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'name': user.displayName ?? 'ไม่ระบุชื่อ',
            'email': user.email ?? '',
            'photoUrl': user.photoURL ?? '',
            'phone': 'ยังไม่ระบุ',
            'birthDate': 'ยังไม่ระบุ',
            'height': '-',
            'weight': '-',
            'waist': '-',
            'chest': '-',
            'hips': '-',
          });
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาดในการเข้าสู่ระบบ Google: $e', Colors.red);
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
                const SizedBox(height: 24),

                // เส้นกั้นคำว่า หรือ
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('หรือ', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // ปุ่ม เข้าสู่ระบบด้วย Google
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 30,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'เข้าสู่ระบบด้วย Google',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _signInWithGoogle,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
