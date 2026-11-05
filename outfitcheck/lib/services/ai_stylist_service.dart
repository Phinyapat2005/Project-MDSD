import '../data/mock_outfits.dart';
import '../models/outfit_item.dart';

class AiStylistResult {
  final String scenario;
  final String styleVibe;
  final String advice;
  final List<String> tags;
  final List<OutfitItem> recommendedItems;

  const AiStylistResult({
    required this.scenario,
    required this.styleVibe,
    required this.advice,
    required this.tags,
    required this.recommendedItems,
  });
}

class AiStylistService {
  /// จำลองการประมวลผลของ Gemini AI ในการวิเคราะห์สถานการณ์และแนะนำชุด
  static Future<AiStylistResult> recommendOutfit(String scenario) async {
    // จำลองเวลาคิดของ AI (Thinking delay) เล็กน้อยเพื่อให้ UX ดูสมจริง
    await Future.delayed(const Duration(milliseconds: 900));

    final query = scenario.toLowerCase().trim();

    // 1. ไปคาเฟ่ / ถ่ายรูป / ชิลๆ
    if (query.contains('คาเฟ่') ||
        query.contains('cafe') ||
        query.contains('กาแฟ') ||
        query.contains('ถ่ายรูป')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Warm Minimalist / Cafe Hopping',
        advice:
            'สำหรับไปคาเฟ่ แนะนำลุคโทนเอิร์ธโทนสีครีม-น้ำตาลที่ถ่ายรูปขึ้นกล้องมากครับ '
            'เลือกเสื้อผ้าลินินสีครีมระบายอากาศได้ดี แมตช์กับกางเกงชิโน่สีกากี '
            'และคอมพลีทลุคด้วยรองเท้า Loafer หนัง ให้ความรู้สึกสบายแต่ดูมีเทสต์',
        tags: ['#CafeLook', '#EarthTone', '#ถ่ายรูปสวย', '#Minimal'],
        recommendedItems: _findItemsByIds(['4', '2', '3', '5']),
      );
    }

    // 2. สัมภาษณ์งาน / ทำงาน / ทางการ
    if (query.contains('สัมภาษณ์') ||
        query.contains('งาน') ||
        query.contains('ทางการ') ||
        query.contains('ประชุม') ||
        query.contains('นำเสนอ')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Smart Casual / Professional',
        advice:
            'สำหรับการสัมภาษณ์งานหรือการทำงานที่ต้องการความน่าเชื่อถือ '
            'แนะนำสไตล์ Smart Casual ที่สุภาพแต่ดูทันสมัย กางเกงชิโน่สีกากีทรงสลิมฟิต '
            'คู่กับรองเท้าหนัง Loafer ช่วยเสริมบุคลิกภาพให้ดูเป็นมืออาชีพและมั่นใจครับ',
        tags: ['#SmartCasual', '#สัมภาษณ์งาน', '#ลุคสุภาพ', '#Professional'],
        recommendedItems: _findItemsByIds(['2', '3', '4']),
      );
    }

    // 3. ไปเดท / ดินเนอร์ / ดูหนัง
    if (query.contains('เดท') ||
        query.contains('date') ||
        query.contains('ดินเนอร์') ||
        query.contains('แฟน') ||
        query.contains('ดูหนัง')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Romantic & Charming Casual',
        advice:
            'สำหรับวันเดทพิเศษ แนะนำลุคที่ดูอบอุ่นและน่าประทับใจ '
            'เสื้อไหมพรมถักสีครีมหรือเสื้อลินินให้ความรู้สึกนุ่มนวลและเข้าถึงง่าย '
            'แมตช์กับกางเกงชิโน่และรองเท้า Loafer หนัง พร้อมกระเป๋าสะพายใบเล็กสุดคลาสสิกครับ',
        tags: ['#DateNight', '#ลุคอบอุ่น', '#Romantic', '#CleanFit'],
        recommendedItems: _findItemsByIds(['6', '2', '3', '5']),
      );
    }

    // 4. ไปเรียน / มหาลัย / ท่องเที่ยว
    if (query.contains('เรียน') ||
        query.contains('มหาลัย') ||
        query.contains('มรสุม') ||
        query.contains('เพื่อน') ||
        query.contains('เดินห้าง')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Campus Casual / Everyday Look',
        advice:
            'สำหรับวันไปเรียนหรือเดินเที่ยวกับเพื่อน แนะนำลุคทะมัดทะแมงที่ใส่สบายตลอดวัน '
            'เสื้อคลุมยีนส์ Oversized แมตช์กับกางเกงยีนส์ฟอกสี และรองเท้าสนีกเกอร์สีขาว '
            'ที่ทั้งเท่และคล่องตัว พร้อมสำหรับทุกกิจกรรมครับ',
        tags: ['#CampusLook', '#EverydayStyle', '#ชุดไปเรียน', '#Comfy'],
        recommendedItems: _findItemsByIds(['1', '7', '8']),
      );
    }

    // 5. ทะเล / หน้าร้อน / ชายหาด
    if (query.contains('ทะเล') ||
        query.contains('beach') ||
        query.contains('ร้อน') ||
        query.contains('วันหยุด')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Summer Breeze / Coastal Chic',
        advice:
            'สำหรับทริปทะเลหรือวันอากาศร้อน แนะนำผ้าลินินสีครีมที่ระบายอากาศได้ดีที่สุด '
            'จับคู่กับกางเกงผ้าเบาสบายโทนสว่าง และสนีกเกอร์สีขาว '
            'ให้ฟีลผ่อนคลาย สดชื่น เหมาะกับบรรยากาศรับลมทะเลครับ',
        tags: ['#SummerVibe', '#ชุดไปทะเล', '#LinenStyle', '#Relaxed'],
        recommendedItems: _findItemsByIds(['4', '2', '8']),
      );
    }

    // 6. สตรีท / เท่ๆ / ปาร์ตี้
    if (query.contains('สตรีท') ||
        query.contains('street') ||
        query.contains('เท่') ||
        query.contains('ปาร์ตี้') ||
        query.contains('y2k')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Urban Streetwear / Denim on Denim',
        advice:
            'สำหรับลุคสตรีทสุดเท่ แนะนำการแมตช์ Double Denim ด้วยเสื้อคลุมยีนส์ทรง Oversized '
            'จับคู่กับกางเกงยีนส์สกินนี่ฟอกสี และสนีกเกอร์สีขาวมินิมอล '
            'ช่วยให้ลุคดูมีมิติและโดดเด่นท่ามกลางผู้คนครับ',
        tags: ['#Streetwear', '#DenimVibe', '#สตรีทแฟชั่น', '#UrbanLook'],
        recommendedItems: _findItemsByIds(['1', '7', '8', '5']),
      );
    }

    // กรณีทั่วไป (Default fallback)
    return AiStylistResult(
      scenario: scenario,
      styleVibe: 'Modern Versatile Casual',
      advice:
          'สำหรับโอกาส "$scenario" แนะนำการแต่งกายสไตล์ Modern Casual ที่ยืดหยุ่น '
          'เน้นการคุมโทนสีธรรมชาติ (Neutral Tone) และเลือกไอเทมชิ้นหลักที่สวมใส่สบาย '
          'แมตช์ง่าย และปรับเปลี่ยนให้เข้ากับสภาพแวดล้อมได้ตลอดทั้งวันครับ',
      tags: ['#ModernCasual', '#EasyMatch', '#Versatile', '#StyleCheck'],
      recommendedItems: _findItemsByIds(['4', '2', '8']),
    );
  }

  static List<OutfitItem> _findItemsByIds(List<String> ids) {
    return mockOutfits.where((item) => ids.contains(item.id)).toList();
  }
}
