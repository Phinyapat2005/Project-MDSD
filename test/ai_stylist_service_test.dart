import 'package:flutter_test/flutter_test.dart';
import 'package:outfitcheck/services/ai_stylist_service.dart';

void main() {
  group('AiStylistService Tests', () {
    test('แนะนำชุดสำหรับสถานการณ์ไปคาเฟ่ (โหมดออฟไลน์)', () async {
      final result = await AiStylistService.recommendOutfit(
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
      final result = await AiStylistService.recommendOutfit(
        'ไปทำงาน สัมภาษณ์งาน',
        gender: 'ชาย',
      );

      expect(result.scenario.contains('ทำงาน'), true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('fallback ค้นหาชุดทั่วไปเมื่อไม่พบคำสำคัญเฉพาะ', () async {
      final result = await AiStylistService.recommendOutfit(
        'เดินเล่นสบายๆ แถวบ้าน',
        gender: 'ทั้งหมด',
      );

      expect(result.recommendedItems.isNotEmpty, true);
    });
  });
}
