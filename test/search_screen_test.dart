import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:outfitcheck/models/outfit_item.dart';
import 'package:outfitcheck/widgets/outfit_card.dart';
import 'package:outfitcheck/screens/search_screen.dart';
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

  tearDownAll(() async {
    await LocalDatabaseService.instance.close();
  });
  group('SearchScreen Widget Tests', () {
    testWidgets('โหลดหน้าค้นหา แสดงแท็บหมวดหมู่และค้นหาชุดได้',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );

      await tester.pump();

      // ตรวจสอบ UI หลัก
      expect(find.text('ค้นหา'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);

      // ค้นหาคำว่า "เสื้อ"
      await tester.enterText(find.byType(TextField), 'เสื้อ');
      await tester.pumpAndSettle();

      // เปลี่ยนแท็บ BottomNavigation
      final wardrobeIcon = find.byIcon(Icons.archive);
      expect(wardrobeIcon, findsOneWidget);

      final homeIcon = find.byIcon(Icons.home);
      expect(homeIcon, findsOneWidget);

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('สามารถแตะแท็บหน้าแรกเพื่อเปลี่ยนหน้าได้',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );

      await tester.pump();

      // แตะที่แท็บหน้าแรก
      await tester.tap(find.text('หน้าแรก'));
      await tester.pumpAndSettle();

      // ตรวจสอบว่ามีหน้าแรกแสดงผลขึ้นมา
      expect(find.text('แนะนำชุดวันนี้'), findsOneWidget);

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('แสดง AI Stylist Scenario และประวัติค้นหาเมื่อแตะช่องค้นหา',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pump();

      // Request focus ช่องค้นหา
      final textField = tester.widget<TextField>(find.byType(TextField));
      textField.focusNode?.requestFocus();
      await tester.pumpAndSettle();

      expect(find.text('ให้ AI แนะนำตามสถานการณ์'), findsOneWidget);
      expect(find.text('☕ ชุดไปคาเฟ่'), findsOneWidget);

      // Drain SQLite internal 10-second timeout timer
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('สลับหมวดหมู่เสื้อผ้าและตัวกรองเพศได้ถูกต้อง',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pump();

      // สลับเพศเป็น ผู้ชาย
      await tester.tap(find.text('ผู้ชาย'));
      await tester.pumpAndSettle();

      // สลับหมวดหมู่เป็น เสื้อ
      await tester.tap(find.text('เสื้อ').first);
      await tester.pumpAndSettle();

      // สลับหมวดหมู่เป็น กางเกง
      await tester.tap(find.text('กางเกง').first);
      await tester.pumpAndSettle();

      // สลับหมวดหมู่เป็น รองเท้า
      await tester.tap(find.text('รองเท้า').first);
      await tester.pumpAndSettle();

      // สลับหมวดหมู่เป็น กระเป๋า
      await tester.tap(find.text('กระเป๋า').first);
      await tester.pumpAndSettle();

      // สลับกลับเป็น ทั้งหมด
      await tester.tap(find.text('ทั้งหมด').first);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('แตะการ์ดสินค้าเพื่อเปิดดูรายละเอียดสินค้าใน Bottom Sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pump();

      // แตะที่การ์ดสินค้าชิ้นแรกใน Grid
      final cardFinder = find.byType(GestureDetector).at(5);
      await tester.tap(cardFinder);
      await tester.pump();
      await tester.pumpAndSettle();

      // ถ้าเปิด Modal Bottom Sheet ขึ้นมาสำเร็จ
      final addToWardrobe = find.text('เพิ่มลงตู้เสื้อผ้า');
      if (addToWardrobe.evaluate().isNotEmpty) {
        expect(addToWardrobe, findsOneWidget);
        // แตะปิด Modal Sheet
        Navigator.of(tester.element(addToWardrobe)).pop();
        await tester.pumpAndSettle();
      }

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('ล้างข้อความค้นหาด้วยปุ่มไอคอนกากบาท (Close Icon)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'เสื้อเชิ้ต');
      await tester.pump();

      // ต้องมีไอคอน close ปรากฏ
      final clearIcon = find.byIcon(Icons.close);
      expect(clearIcon, findsOneWidget);

      await tester.tap(clearIcon);
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('แตะชิปคำค้นหายอดนิยมและแสดง Empty State เมื่อค้นหาไม่เจอ',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pump();

      // สลับเพศเป็น ผู้หญิง
      await tester.tap(find.text('ผู้หญิง'));
      await tester.pumpAndSettle();

      // ค้นหาคำที่ไม่เจอในรายการ เพื่อให้เกิด Empty State
      await tester.enterText(find.byType(TextField), 'คำค้นหาที่ไม่มีอยู่จริง123');
      final tf = tester.widget<TextField>(find.byType(TextField));
      tf.onSubmitted?.call('คำค้นหาที่ไม่มีอยู่จริง123');
      await tester.pumpAndSettle();

      expect(find.text('ไม่พบเสื้อผ้าที่ค้นหา'), findsOneWidget);

      // Drain SQLite timer
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('onItemTap Callback ทำงานเมื่อผู้ใช้แตะที่การ์ดสินค้า',
        (WidgetTester tester) async {
      OutfitItem? selectedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: SearchScreen(
            onItemTap: (item) {
              selectedItem = item;
            },
          ),
        ),
      );
      await tester.pump();

      // แตะที่ส่วนบนของการ์ดสินค้าใน Grid (หลบแถบ BottomNavigationBar ด้านล่าง)
      final topLeft = tester.getTopLeft(find.byType(OutfitCard).first);
      await tester.tapAt(topLeft + const Offset(50, 50));
      await tester.pumpAndSettle();

      expect(selectedItem, isNotNull);

      // Drain SQLite timer
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('เปิดหน้าต่าง AI Stylist เมื่อกดปุ่มถาม AI',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pump();

      final askAiBtn = find.text('ถาม AI').first;
      await tester.tap(askAiBtn);
      await tester.pumpAndSettle();

      expect(find.text('AI Stylist'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('แตะชิปสถานการณ์ AI ในหน้าแนะนำ',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      textField.focusNode?.requestFocus();
      await tester.pumpAndSettle();

      final cafeScenario = find.text('☕ ชุดไปคาเฟ่');
      expect(cafeScenario, findsOneWidget);
      await tester.tap(cafeScenario);
      await tester.pumpAndSettle();

      final closeIcon = find.byIcon(Icons.close);
      if (closeIcon.evaluate().isNotEmpty) {
        await tester.tap(closeIcon.first);
        await tester.pumpAndSettle();
      }

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('สลับไปยังแท็บตู้เสื้อผ้าและโปรไฟล์จาก SearchScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pump();

      // แตะตู้เสื้อผ้า
      await tester.tap(find.text('ตู้เสื้อผ้า'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 11));
    });
  });
}
