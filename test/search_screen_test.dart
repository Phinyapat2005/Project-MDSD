import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfitcheck/screens/search_screen.dart';

void main() {
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
    });

    testWidgets('แสดง AI Stylist Scenario และประวัติค้นหาเมื่อแตะช่องค้นหา',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pump();

      // Focus ช่องค้นหา
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('ให้ AI แนะนำตามสถานการณ์'), findsOneWidget);
      expect(find.text('☕ ชุดไปคาเฟ่'), findsOneWidget);
    });
  });
}
