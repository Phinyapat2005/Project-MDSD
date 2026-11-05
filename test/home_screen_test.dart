import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:outfitcheck/screens/home_screen.dart';
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
  group('HomeScreen Widget Tests', () {
    testWidgets('แสดงองค์ประกอบหลักในหน้าแรกครบถ้วน (Greeting, ชุดแนะนำ, สถานที่, สัดส่วน)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // รัน pump เพื่อให้ StreamBuilder แสดงผล
      await tester.pump();

      // ตรวจสอบหัวข้อหลัก
      expect(find.text('แนะนำชุดวันนี้'), findsOneWidget);
      expect(find.text('รวม'), findsOneWidget);
      expect(find.text('ชิ้นส่วน'), findsOneWidget);
      expect(find.text('สถานที่แนะนำวันนี้'), findsOneWidget);
      expect(find.text('สัดส่วนของคุณ'), findsOneWidget);
      expect(find.text('ค้นหาเสื้อผ้า & สไตล์'), findsOneWidget);

      // ตรวจสอบชิ้นเสื้อผ้าในชุดแนะนำ
      expect(find.text('เสื้อคลุมยีนส์/แจ็คเก็ต'), findsOneWidget);
      expect(find.text('Chinos สีกากี'), findsOneWidget);
      expect(find.text('รองเท้า Loafer'), findsOneWidget);

      // ทดสอบสลับโหมดเป็น 'ชิ้นส่วน'
      await tester.tap(find.text('ชิ้นส่วน'));
      await tester.pump();

      expect(find.text('เสื้อคลุมยีนส์ Oversized'), findsOneWidget);
      expect(find.text('฿1,290'), findsOneWidget);
      expect(find.text('Chinos สีกากี Slim Fit'), findsOneWidget);
      expect(find.text('฿990'), findsOneWidget);

      // สลับกลับเป็น 'รวม'
      await tester.tap(find.text('รวม'));
      await tester.pump();
      expect(find.text('เสื้อคลุมยีนส์/แจ็คเก็ต'), findsOneWidget);
    });

    testWidgets('เปิดหน้าต่างแก้ไขสัดส่วนและสามารถกดยกเลิกได้',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(userId: 'test_user'),
        ),
      );
      await tester.pump();

      // เลื่อนหน้าจอลงมาที่ส่วนสัดส่วน
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -450),
      );
      await tester.pumpAndSettle();

      // หาปุ่มแก้ไขสัดส่วน
      final editBtn = find.text('แก้ไข');
      expect(editBtn, findsOneWidget);

      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(find.text('แก้ไขสัดส่วนร่างกาย'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);
      expect(find.text('บันทึก'), findsOneWidget);

      // กดยกเลิก
      await tester.tap(find.text('ยกเลิก'));
      await tester.pumpAndSettle();

      expect(find.text('แก้ไขสัดส่วนร่างกาย'), findsNothing);
    });

    testWidgets('สามารถแตะชิปหมวดหมู่สไตล์สำรวจคอลเลกชันได้',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      // เลื่อนหน้าจอลงมาที่ส่วนสำรวจคอลเลกชัน
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      final exploreChip = find.text('สำรวจคอลเลกชัน');
      expect(exploreChip, findsOneWidget);

      await tester.tap(exploreChip);
      await tester.pumpAndSettle();
    });

    testWidgets('โหลดข้อมูลผู้ใช้จาก Firestore StreamBuilder และแสดงผลสัดส่วน',
        (WidgetTester tester) async {
      final fakeDb = FakeFirebaseFirestore();
      await fakeDb.collection('users').doc('user_stream').set({
        'name': 'น้องน้ำใส ใจดี',
        'height': '165',
        'weight': '48',
        'waist': '24',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            userId: 'user_stream',
            firestore: fakeDb,
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.textContaining('น้องน้ำใส ใจดี'), findsOneWidget);
    });

    testWidgets('แก้ไขและบันทึกสัดส่วนร่างกายลง Firestore และ SQLite',
        (WidgetTester tester) async {
      final fakeDb = FakeFirebaseFirestore();
      await fakeDb.collection('users').doc('user_measure').set({
        'name': 'สมชาย',
        'height': '175',
        'weight': '70',
        'waist': '32',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            userId: 'user_measure',
            firestore: fakeDb,
          ),
        ),
      );
      await tester.pump();

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -450),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('แก้ไข'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('บันทึก'));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      expect(find.text('แก้ไขสัดส่วนร่างกาย'), findsNothing);
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('สลับแท็บ Bottom Navigation Bar ใน HomeScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      // แตะแท็บค้นหา
      await tester.tap(find.text('ค้นหา'));
      await tester.pumpAndSettle();
    });
  });
}
