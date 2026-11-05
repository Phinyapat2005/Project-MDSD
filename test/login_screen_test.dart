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
  });
}
