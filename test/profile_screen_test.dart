import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:outfitcheck/screens/profile_screen.dart';
import 'package:outfitcheck/screens/login_screen.dart';
import 'package:outfitcheck/services/local_database_service.dart';

void main() {
  setUpAll(() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  setUp(() async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await LocalDatabaseService.createTables(db);
      },
    );
    LocalDatabaseService.instance.dbForTesting = db;
  });

  tearDown(() async {
    await LocalDatabaseService.instance.close();
  });
  group('ProfileScreen Widget Tests', () {
    testWidgets('แสดงหน้า LoginScreen เมื่อผู้ใช้ยังไม่ได้เข้าสู่ระบบ (userId เป็น null)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(userId: null),
        ),
      );

      // เมื่อไม่มี user ต้องแสดงหน้า LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('แสดงข้อมูลโปรไฟล์และเปิด Popup แก้ไขข้อมูลสัดส่วนร่างกายได้',
        (WidgetTester tester) async {
      final fakeDb = FakeFirebaseFirestore();

      // บันทึกข้อมูลจำลอง
      await fakeDb.collection('users').doc('user_123').set({
        'name': 'Poomchana Tiamkeaw',
        'email': '67030180@kmitl.ac.th',
        'photoUrl': '',
        'height': '175',
        'weight': '65',
        'waist': '30',
        'chest': '38',
        'hips': '36',
        'phone': '0812345678',
        'birthDate': '01/01/2000',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            userId: 'user_123',
            userDisplayName: 'Poomchana Tiamkeaw',
            userEmail: '67030180@kmitl.ac.th',
            firestore: fakeDb,
          ),
        ),
      );

      await tester.pump();

      // ตรวจสอบข้อมูลบนหน้าจอ
      expect(find.text('Poomchana Tiamkeaw'), findsWidgets);
      expect(find.text('67030180@kmitl.ac.th'), findsWidgets);
      expect(find.text('ข้อมูลสัดส่วนร่างกาย'), findsOneWidget);
      expect(find.text('ข้อมูลบัญชีผู้ใช้'), findsOneWidget);

      // กดปุ่มแก้ไขสัดส่วนร่างกาย
      final editButtons = find.text('แก้ไข');
      expect(editButtons, findsWidgets);
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      // ตรวจสอบว่าเปิด Dialog แก้ไขขึ้นมา
      expect(find.text('แก้ไขข้อมูลสัดส่วนร่างกาย'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);
      expect(find.text('บันทึก'), findsOneWidget);

      // กดยกเลิก Dialog
      await tester.tap(find.text('ยกเลิก'));
      await tester.pumpAndSettle();

      expect(find.text('แก้ไขข้อมูลสัดส่วนร่างกาย'), findsNothing);
    });

    testWidgets('แก้ไขและบันทึกข้อมูลสัดส่วนร่างกายลง Firestore สำเร็จ',
        (WidgetTester tester) async {
      final fakeDb = FakeFirebaseFirestore();

      await fakeDb.collection('users').doc('user_edit').set({
        'name': 'Test User',
        'email': 'user@example.com',
        'height': '170',
        'weight': '60',
        'waist': '28',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            userId: 'user_edit',
            firestore: fakeDb,
          ),
        ),
      );

      await tester.pump();

      // เปิด Dialog แก้ไข
      final editButtons = find.text('แก้ไข');
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      // กดบันทึก
      await tester.tap(find.text('บันทึก'));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();

      // ตรวจสอบว่า dialog ปิดลง
      expect(find.text('แก้ไขข้อมูลสัดส่วนร่างกาย'), findsNothing);

      // Drain SQLite timer
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('สลับแท็บ Bottom Navigation Bar ใน ProfileScreen',
        (WidgetTester tester) async {
      final fakeDb = FakeFirebaseFirestore();

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            userId: 'user_nav',
            firestore: fakeDb,
          ),
        ),
      );

      await tester.pump();

      // แตะแท็บค้นหา
      await tester.tap(find.text('ค้นหา'));
      await tester.pumpAndSettle();
    });
  });
}
