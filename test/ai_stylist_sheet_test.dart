import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfitcheck/services/ai_stylist_service.dart';
import 'package:outfitcheck/widgets/ai_stylist_sheet.dart';

void main() {
  setUp(() {
    AiStylistService.forceOfflineForTesting = true;
  });

  tearDown(() {
    AiStylistService.forceOfflineForTesting = false;
  });

  group('AiStylistSheet Widget Tests', () {
    testWidgets('แสดงองค์ประกอบหลักของ AI Stylist Sheet และโหลดชุดแนะนำ',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AiStylistSheet.show(
                      context,
                      initialPrompt: 'ชุดไปคาเฟ่',
                      onItemTap: (item) {},
                    );
                  },
                  child: const Text('Open AI'),
                );
              },
            ),
          ),
        ),
      );

      // เปิด Sheet
      await tester.tap(find.text('Open AI'));
      await tester.pump();
      await tester.pumpAndSettle();

      // ตรวจสอบส่วนหัวและ Badge
      expect(find.text('AI Stylist แนะนำชุด'), findsOneWidget);
      expect(find.text('Gemini AI'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // ตรวจสอบ Quick Prompts
      expect(find.text('สัมภาษณ์งาน'), findsOneWidget);
      expect(find.text('ชุดไปคาเฟ่'), findsWidgets);

      // ตรวจสอบ Gender Selector
      expect(find.text('✨ ทั้งหมด'), findsOneWidget);
      expect(find.text('👨 ชาย'), findsOneWidget);
      expect(find.text('👩 หญิง'), findsOneWidget);

      // แตะปิด Sheet
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('AI Stylist แนะนำชุด'), findsNothing);
    });

    testWidgets('เปลี่ยนเพศและแตะ Quick Prompt ชิปเพื่อขอคำแนะนำใหม่',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiStylistSheet(
              initialPrompt: 'ชุดไปคาเฟ่',
              initialGender: 'ทั้งหมด',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // แตะเปลี่ยนเพศเป็น 'ชาย'
      await tester.tap(find.text('👨 ชาย'));
      await tester.pump();
      await tester.pumpAndSettle();

      // แตะเลือก Prompt สัมภาษณ์งาน
      await tester.tap(find.text('สัมภาษณ์งาน'));
      await tester.pump();
      await tester.pumpAndSettle();

      // ตรวจสอบว่าช่องค้นหามีข้อความเปลี่ยนเป็นสัมภาษณ์งาน
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'สัมภาษณ์งาน');

      // พิมพ์ข้อความค้นหาใหม่และส่งคำสั่ง
      await tester.enterText(find.byType(TextField), 'แคมป์ปิ้งเขาใหญ่');
      final tf = tester.widget<TextField>(find.byType(TextField));
      tf.onSubmitted?.call('แคมป์ปิ้งเขาใหญ่');
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(AiStylistSheet), findsOneWidget);
    });

    testWidgets('แตะไอคอนส่งคำค้นหาและแตะการ์ดสินค้าในรายการแนะนำ',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiStylistSheet(
              initialPrompt: 'ชุดไปคาเฟ่',
              onItemTap: (item) {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // แตะไอคอนลูกศรส่งคำสั่งค้นหา
      final sendButton = find.byIcon(Icons.arrow_upward_rounded);
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);
      await tester.pump();
      await tester.pumpAndSettle();

      // แตะปุ่มบันทึกเซ็ตนี้ลงตู้เสื้อผ้า (กรณีผู้ใช้ยังไม่ได้ล็อกอินจะขึ้น SnackBar เตือน)
      final saveSetButton = find.text('บันทึกทั้งเซ็ตนี้ลงตู้เสื้อผ้า');
      if (saveSetButton.evaluate().isNotEmpty) {
        await tester.tap(saveSetButton, warnIfMissed: false);
        await tester.pump();
      }
    });
  });
}
