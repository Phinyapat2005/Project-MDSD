import 'package:flutter_test/flutter_test.dart';
import 'package:outfitcheck/services/ai_stylist_service.dart';

void main() {
  group('AiStylistService Tests', () {
    test('recommendOutfit ใช้งานได้เมื่อ forceOfflineForTesting เป็น true', () async {
      AiStylistService.forceOfflineForTesting = true;
      final result = await AiStylistService.recommendOutfit(
        'ชุดไปเที่ยวญี่ปุ่น',
        gender: 'ทั้งหมด',
      );
      expect(result.scenario, 'ชุดไปเที่ยวญี่ปุ่น');
      expect(result.recommendedItems, isNotEmpty);
      AiStylistService.forceOfflineForTesting = false;
    });

    test('hasActiveKey คืนค่า true เมื่อมี API Key', () {
      AiStylistService.forceOfflineForTesting = false;
      expect(AiStylistService.hasActiveKey, isTrue);
      AiStylistService.forceOfflineForTesting = true;
      expect(AiStylistService.hasActiveKey, isFalse);
      AiStylistService.forceOfflineForTesting = false;
    });

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

    test('แนะนำชุดสำหรับไปเดทวันเสาร์', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปเดทวันเสาร์ ดินเนอร์',
        gender: 'ชาย',
      );
      expect(result.styleVibe.contains('Romance') || result.styleVibe.contains('Romantic') || result.styleVibe.contains('Date'), true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับไปเรียนมหาวิทยาลัย', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปเรียน มหาลัย',
        gender: 'หญิง',
      );
      expect(result.styleVibe.contains('Campus') || result.styleVibe.contains('Student'), true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับเที่ยวทะเล ชายหาด', () async {
      final result = await AiStylistService.recommendOffline(
        'เที่ยวทะเล พักผ่อนหัวหิน',
        gender: 'ชาย',
      );
      expect(result.styleVibe.contains('Coastal') || result.styleVibe.contains('Beach') || result.styleVibe.contains('Resort'), true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับงานแต่งงาน สุภาพหรูหรา', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปงานแต่งงาน เพื่อนสนิท',
        gender: 'หญิง',
      );
      expect(result.styleVibe.contains('Wedding') || result.styleVibe.contains('Elegant'), true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับฟิตเนส ออกกำลังกาย', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปฟิตเนส วิ่งออกกำลังกาย',
        gender: 'ชาย',
      );
      expect(result.styleVibe.contains('Sport') || result.styleVibe.contains('Athleisure'), true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับสนามบิน เดินทางไกล', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปสนามบิน บินต่างประเทศ',
        gender: 'หญิง',
      );
      expect(result.styleVibe.contains('Airport') || result.styleVibe.contains('Travel'), true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับกินชาบู หมูกระทะ', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปกินชาบู หมูกระทะกับเพื่อน',
        gender: 'ทั้งหมด',
      );
      expect(result.styleVibe.contains('Foodie') || result.styleVibe.contains('บุฟเฟต์') || result.styleVibe.contains('Shabu'), true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับเดินสยาม ห้างสรรพสินค้า', () async {
      final result = await AiStylistService.recommendOffline(
        'เดินสยาม เซ็นทรัลเวิลด์',
        gender: 'หญิง',
      );
      expect(result.styleVibe.isNotEmpty, true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับสไตล์สตรีทแฟชั่น', () async {
      final result = await AiStylistService.recommendOffline(
        'สตรีทเท่ๆ โอเวอร์ไซส์',
        gender: 'ชาย',
      );
      expect(result.styleVibe.isNotEmpty, true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับไปห้องสมุด อ่านหนังสือเงียบๆ', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปห้องสมุด ร้านหนังสือ',
        gender: 'หญิง',
      );
      expect(result.styleVibe.isNotEmpty, true);
      expect(result.recommendedItems.isNotEmpty, true);
    });

    test('แนะนำชุดสำหรับไปเดินตลาดนัดกลางคืน จตุจักร', () async {
      final result = await AiStylistService.recommendOffline(
        'ไปตลาดนัดกลางคืน จตุจักร',
        gender: 'ชาย',
      );
      expect(result.styleVibe.isNotEmpty, true);
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
