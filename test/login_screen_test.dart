import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfitcheck/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('แสดงฟอร์มเข้าสู่ระบบและปุ่มต่างๆ ครบถ้วน',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.text('ยินดีต้อนรับเข้าสู่ระบบ'), findsOneWidget);
      expect(find.text('อีเมล (Email)'), findsOneWidget);
      expect(find.text('รหัสผ่าน (Password)'), findsOneWidget);
      expect(find.text('เข้าสู่ระบบ'), findsOneWidget);
      expect(find.text('ยังไม่มีบัญชี? สมัครสมาชิก'), findsOneWidget);
      expect(find.text('เข้าสู่ระบบด้วย Google'), findsOneWidget);
    });

    testWidgets('สลับการมองเห็นรหัสผ่าน (Obscure Text) เมื่อกดไอคอนลูกตา',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // เริ่มต้น _isObscure เป็น true -> ไอคอน visibility_off
      final toggleIcon = find.byIcon(Icons.visibility_off);
      expect(toggleIcon, findsOneWidget);

      await tester.tap(toggleIcon);
      await tester.pump();

      // หลังกด -> ไอคอนเปลี่ยนเป็น visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('แจ้งเตือนเมื่อกดยืนยันโดยไม่กรอกอีเมลและรหัสผ่าน',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // กดปุ่มเข้าสู่ระบบโดยไม่ได้กรอกข้อมูล
      await tester.tap(find.text('เข้าสู่ระบบ'));
      await tester.pump();

      expect(find.text('กรุณากรอกอีเมลและรหัสผ่านให้ครบถ้วน'), findsOneWidget);
    });

    testWidgets('แจ้งเตือนเมื่อกดสมัครสมาชิกโดยไม่กรอกข้อมูล',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // กดปุ่มสมัครสมาชิก
      await tester.tap(find.text('ยังไม่มีบัญชี? สมัครสมาชิก'));
      await tester.pump();

      expect(find.text('กรุณากรอกอีเมลและรหัสผ่านเพื่อสมัครสมาชิก'), findsOneWidget);
    });
    testWidgets('แจ้งเตือนเมื่อรหัสผ่านสั้นกว่า 6 ตัวอักษรตอนสมัครสมาชิก',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final emailField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123');
      await tester.pump();

      await tester.tap(find.text('ยังไม่มีบัญชี? สมัครสมาชิก'));
      await tester.pump();

      expect(find.text('รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร'), findsOneWidget);
    });

    testWidgets('พยายามเข้าสู่ระบบด้วยอีเมลและรหัสผ่านเมื่อกรอกครบ',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final emailField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123456');
      await tester.pump();

      await tester.tap(find.text('เข้าสู่ระบบ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // ตรวจสอบว่าพยายามเข้าสู่ระบบและแสดง SnackBar ผลลัพธ์หรือข้อผิดพลาด
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('พยายามสมัครสมาชิกด้วยอีเมลและรหัสผ่านเมื่อกรอกครบถ้วน',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final emailField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'newuser@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      await tester.tap(find.text('ยังไม่มีบัญชี? สมัครสมาชิก'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('กดปุ่มเข้าสู่ระบบด้วย Google',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.tap(find.text('เข้าสู่ระบบด้วย Google'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('กดปุ่มทดลองใช้งานโดยไม่เข้าสู่ระบบ (Guest Mode)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final guestBtn = find.text('ทดลองใช้งานโดยไม่เข้าสู่ระบบ (Guest Mode)');
      expect(guestBtn, findsOneWidget);
      await tester.tap(guestBtn);
      await tester.pumpAndSettle();

      expect(find.text('แนะนำชุดวันนี้'), findsOneWidget);
    });
  });
}
