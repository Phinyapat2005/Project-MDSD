import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:outfitcheck/screens/favorite.dart';

void main() {
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
  });
}

