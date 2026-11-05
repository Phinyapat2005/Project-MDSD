import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfitcheck/screens/home_screen.dart';

void main() {
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
    });
  });
}
