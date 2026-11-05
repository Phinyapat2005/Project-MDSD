import 'package:flutter_test/flutter_test.dart';
import 'package:outfitcheck/services/ai_stylist_service.dart';

void main() {
  group('AiStylistService Tests', () {
    test('แนะนำชุดสำหรับสถานการณ์ไปคาเฟ่ (โหมดออฟไลน์)', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปคาเฟ่',
        gender: 'หญิง',
      );

      expect(result.scenario, 'ไปคาเฟ่');
      expect(result.styleVibe.isNotEmpty, true);
      expect(result.advice.isNotEmpty, true);
      expect(result.tags.isNotEmpty, true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับสถานการณ์ไปทำงาน (โหมดออฟไลน์)', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปทำงาน สัมภาษณ์งาน',
        gender: 'ชาย',
      );

      expect(result.scenario.contains('ทำงาน'), true);
      expect(result.styleVibe.isNotEmpty, true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับไปวัดทำบุญ สุภาพ เรียบร้อย', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปวัดทำบุญ',
        gender: 'หญิง',
      );

      expect(result.styleVibe.contains('Polite') || result.styleVibe.contains('สุภาพ'), true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับแคมป์ปิ้งเขาใหญ่ ลุยธรรมชาติ', () async {
      final result = await AiStylistService.recommendOffline(
        'แคมป์ปิ้งเขาใหญ่',
        gender: 'ชาย',
      );

      expect(result.styleVibe.contains('Gorpcore') || result.styleVibe.contains('Camping'), true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับไปดูคอนเสิร์ตร็อคและสตรีท', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปดูคอนเสิร์ต',
        gender: 'หญิง',
      );

      expect(result.styleVibe.contains('Concert') || result.styleVibe.contains('Rock') || result.styleVibe.contains('Festival'), true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('fallback ค้นหาชุดทั่วไปเมื่อไม่พบคำสำคัญเฉพาะ', () async {
      final result = await AiStylistService.recommendOffline(
        'เดินเล่นสบายๆ แถวบ้าน',
        gender: 'ทั้งหมด',
      );

      expect(result.styleVibe.isNotEmpty, true);
      expect(result.recommendedItems.isNotEmpty, true);
    });
  });
}
