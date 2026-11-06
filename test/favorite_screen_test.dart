import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:outfitcheck/screens/favorite.dart';
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
  group('FavoriteScreen Widget Tests', () {
    testWidgets('แสดงข้อความกรุณาเข้าสู่ระบบเมื่อ userId เป็น null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoriteScreen(userId: null),
        ),
      );

      expect(find.text('กรุณาเข้าสู่ระบบก่อนใช้งาน'), findsOneWidget);
    });

    testWidgets('แสดงหน้าว่างเมื่อไม่มีชุดที่บันทึกไว้ในตู้เสื้อผ้า',
        (WidgetTester tester) async {
      final fakeDb = FakeFirebaseFirestore();

      await tester.pumpWidget(
        MaterialApp(
          home: FavoriteScreen(
            userId: 'user_test',
            firestore: fakeDb,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('OutfitCheck'), findsOneWidget);
      expect(find.text('ยังไม่มีเสื้อผ้าที่กดติดดาวไว้'), findsOneWidget);
    });

    testWidgets('แสดงการ์ดชุดแต่งกายและสามารถกดเปิดดูรายละเอียดลุคได้',
        (WidgetTester tester) async {
      final fakeDb = FakeFirebaseFirestore();

      // เพิ่มชุดตัวอย่างใน Firestore
      await fakeDb
          .collection('users')
          .doc('user_test')
          .collection('outfits')
          .doc('outfit_1')
          .set({
        'title': 'Minimal Style',
        'image': '',
        'tags': ['Casual', 'Summer'],
        'items': [
          {'text': 'เสื้อยืดสีขาว'},
        ],
      });

      await tester.pumpWidget(
        MaterialApp(
          home: FavoriteScreen(
            userId: 'user_test',
            firestore: fakeDb,
          ),
        ),
      );

      await tester.pump();

      // ตรวจสอบว่ามีชื่อชุดและการ์ดแสดง
      expect(find.text('Minimal Style'), findsOneWidget);
      expect(find.text('เสื้อยืดสีขาว'), findsOneWidget);
      expect(find.text('SQLite แคช'), findsOneWidget);

      // แตะที่การ์ดเพื่อเปิด BottomSheet รายละเอียด
      await tester.tap(find.text('Minimal Style'));
      await tester.pumpAndSettle();

      // ตรวจสอบว่า Modal Bottom Sheet เปิดขึ้นมา
      expect(find.text('รายการเสื้อผ้าในลุคนี้'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // แตะปุ่มปิด Modal
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('รายการเสื้อผ้าในลุคนี้'), findsNothing);
    });

    testWidgets('ข้อความรายการเสื้อผ้ายาวมากๆ สามารถแสดงผลได้โดยไม่เกิด Overflow',
        (WidgetTester tester) async {
      final fakeDb = FakeFirebaseFirestore();

      await fakeDb
          .collection('users')
          .doc('user_test')
          .collection('outfits')
          .doc('outfit_long')
          .set({
        'title': 'Tropical Coastal / Summer Vacation Long Name',
        'image': '',
        'tags': ['Tropical', 'Summer'],
        'items': [
          {'text': 'เสื้อ: เสื้อเชิ้ตฮาวาย ลายทรอปิคอล (฿690)'},
          {'text': 'กางเกง: กางเกงขาสั้นผ้าลินิน สีเบจ (฿590)'},
          {'text': 'รองเท้า: รองเท้าแตะหนัง Birks สีน้ำตาล (฿1,290)'},
          {'text': 'กระเป๋า: กระเป๋าผ้า Tote Bag ลินินมินิมอล (฿490)'},
        ],
      });

      await tester.pumpWidget(
        MaterialApp(
          home: FavoriteScreen(
            userId: 'user_test',
            firestore: fakeDb,
          ),
        ),
      );

      await tester.pump();

      // ต้องแสดงผลรายการครบทั้ง 4 ชิ้นโดยไม่มี Exception / Overflow
      expect(find.text('เสื้อ: เสื้อเชิ้ตฮาวาย ลายทรอปิคอล (฿690)'), findsOneWidget);
      expect(find.text('กางเกง: กางเกงขาสั้นผ้าลินิน สีเบจ (฿590)'), findsOneWidget);
      expect(find.text('รองเท้า: รองเท้าแตะหนัง Birks สีน้ำตาล (฿1,290)'), findsOneWidget);
      expect(find.text('กระเป๋า: กระเป๋าผ้า Tote Bag ลินินมินิมอล (฿490)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('กดปุ่มติดดาวเพื่อลบชุดออกจากรายการโปรด',
        (WidgetTester tester) async {
      final fakeDb = FakeFirebaseFirestore();

      await fakeDb
          .collection('users')
          .doc('user_test')
          .collection('outfits')
          .doc('outfit_to_remove')
          .set({
        'title': 'Korean Street Style',
        'image': '',
        'tags': ['Korean'],
        'items': [
          {'text': 'เสื้อฮู้ดดี้สีดำ'},
        ],
      });

      await tester.pumpWidget(
        MaterialApp(
          home: FavoriteScreen(
            userId: 'user_test',
            firestore: fakeDb,
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Korean Street Style'), findsOneWidget);

      final starBtn = find.byIcon(Icons.star);
      expect(starBtn, findsOneWidget);

      await tester.tap(starBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final doc = await fakeDb
          .collection('users')
          .doc('user_test')
          .collection('outfits')
          .doc('outfit_to_remove')
          .get();
      expect(doc.exists, isFalse);

      // รอ timer 10 วินาทีของ sqflite คืน lock
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('กดสลับแถบเมนูใน BottomNavigationBar',
        (WidgetTester tester) async {
      final fakeDb = FakeFirebaseFirestore();

      await tester.pumpWidget(
        MaterialApp(
          home: FavoriteScreen(
            userId: 'user_test',
            firestore: fakeDb,
          ),
        ),
      );

      await tester.pump();

      // ตรวจสอบเมนูนำทางด้านล่าง
      expect(find.text('หน้าแรก'), findsOneWidget);
      expect(find.text('ค้นหา'), findsOneWidget);
      expect(find.text('ตู้เสื้อผ้า'), findsOneWidget);
      expect(find.text('โปรไฟล์'), findsOneWidget);

      // ลองแตะเมนูค้นหา
      await tester.tap(find.text('ค้นหา'));
      await tester.pump();
    });

    test('Outfit model serialization fromCachedMap and toCachedMap', () {
      final outfit = Outfit.fromCachedMap({
        'id': 'cached_1',
        'title': 'ชุดทำงานออฟฟิศ',
        'image': 'assets/test.jpg',
        'tags': ['Office', 'Formal'],
        'isFavorite': true,
        'items': [
          {'text': 'เสื้อเชิ้ต', 'itemImage': ''},
          'กางเกงสแล็ค',
        ],
      });

      expect(outfit.id, 'cached_1');
      expect(outfit.title, 'ชุดทำงานออฟฟิศ');
      expect(outfit.tags.length, 2);
      expect(outfit.items.length, 2);

      final map = outfit.toCachedMap();
      expect(map['id'], 'cached_1');
      expect(map['title'], 'ชุดทำงานออฟฟิศ');
      expect((map['items'] as List).length, 2);
    });

    testWidgets('สลับแท็บหน้าแรกและโปรไฟล์ใน FavoriteScreen',
        (WidgetTester tester) async {
      final fakeDb = FakeFirebaseFirestore();

      await tester.pumpWidget(
        MaterialApp(
          home: FavoriteScreen(
            userId: 'user_test',
            firestore: fakeDb,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('หน้าแรก'));
      await tester.pumpAndSettle();
    });
  });
}
