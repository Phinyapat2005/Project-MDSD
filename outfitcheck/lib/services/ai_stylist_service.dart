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
  /// จำลองการประมวลผลของ Gemini AI ในการวิเคราะห์สถานการณ์และแนะนำชุดตามสถานที่อย่างเหมาะสม
  static Future<AiStylistResult> recommendOutfit(String scenario) async {
    // จำลองเวลาคิดของ AI (Thinking delay) เล็กน้อยเพื่อให้ UX ดูสมจริง
    await Future.delayed(const Duration(milliseconds: 800));

    final query = scenario.toLowerCase().trim();

    // 1. ไปคาเฟ่ / ถ่ายรูป / นั่งชิล
    if (query.contains('คาเฟ่') ||
        query.contains('cafe') ||
        query.contains('กาแฟ') ||
        query.contains('ถ่ายรูป')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Warm Minimalist / Cafe Hopping',
        advice:
            'สำหรับไปคาเฟ่ แนะนำลุคโทนเอิร์ธโทน ครีม-กากี-น้ำตาล เสื้อลินินสีครีมเบาสบาย '
            'แมตช์กับกางเกงชิโน่สีกากี รองเท้าโลฟเฟอร์หนังสีน้ำตาล และกระเป๋าผ้า Tote Bag '
            'ให้ฟีลลิ่งมินิมอลอบอุ่น ถ่ายรูปกับแสงธรรมชาติและมุมคาเฟ่ได้สวยสะดุดตาครับ',
        tags: ['#CafeLook', '#EarthTone', '#ถ่ายรูปสวย', '#Minimalist', '#LinenStyle'],
        recommendedItems: _findItemsByIds(['4', '2', '3', '22']),
      );
    }

    // 2. สัมภาษณ์งาน / ทางการ / ทำงาน / ประชุมผู้ใหญ่
    if (query.contains('สัมภาษณ์') ||
        query.contains('งาน') ||
        query.contains('ทางการ') ||
        query.contains('ประชุม') ||
        query.contains('นำเสนอ') ||
        query.contains('สัมภาษณ์งาน')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Executive Professional / Smart Business',
        advice:
            'สำหรับการสัมภาษณ์งานหรือการทำงานที่ต้องการความน่าเชื่อถือระดับมืออาชีพ '
            'แนะนำชุดสูทเบลเซอร์สีกรมท่าทับเสื้อเชิ้ต Oxford สีขาว จับคู่กับกางเกงสแล็คสีดำ '
            'รองเท้าหนัง Oxford ขัดเงา และกระเป๋าเอกสารทรงบรีฟเคส '
            'ให้ลุคภูมิฐาน มั่นใจ และสร้างความประทับใจแรกพบได้อย่างยอดเยี่ยมครับ',
        tags: ['#SmartCasual', '#สัมภาษณ์งาน', '#FormalLook', '#Professional', '#สูทเบลเซอร์'],
        recommendedItems: _findItemsByIds(['12', '9', '14', '19', '24']),
      );
    }

    // 3. ทะเล / หน้าร้อน / ชายหาด / ภูเก็ต / เกาะ
    if (query.contains('ทะเล') ||
        query.contains('beach') ||
        query.contains('ร้อน') ||
        query.contains('ชายหาด') ||
        query.contains('เกาะ') ||
        query.contains('ว่ายน้ำ') ||
        query.contains('ซัมเมอร์')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Tropical Coastal / Summer Vacation',
        advice:
            'สำหรับทริปทะเลหรือวันพักผ่อนริมชายหาด แนะนำเสื้อเชิ้ตฮาวายลายใบไม้ทรอปิคอลสุดสดใส '
            'แมตช์กับกางเกงขาสั้นผ้าลินินสีเบจระบายความร้อนได้ดี รองเท้าแตะหนัง Birks เดินสบายบนผืนทราย '
            'และกระเป๋าผ้า Tote Bag จุแว่นกันแดดและครีมกันแดดได้อย่างลงตัวครับ',
        tags: ['#SummerVibe', '#ชุดไปทะเล', '#เชิ้ตฮาวาย', '#BeachVacation', '#ขาสั้นลินิน'],
        recommendedItems: _findItemsByIds(['11', '15', '20', '22']),
      );
    }

    // 4. ไปเดท / ดินเนอร์ / วันเสาร์ / แฟน / ดูหนัง
    if (query.contains('เดท') ||
        query.contains('date') ||
        query.contains('ดินเนอร์') ||
        query.contains('แฟน') ||
        query.contains('ดูหนัง') ||
        query.contains('วันเสาร์') ||
        query.contains('โรแมนติก')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Charming Romance / Warm Evening',
        advice:
            'สำหรับวันเดทพิเศษหรือดินเนอร์ยามค่ำคืน แนะนำลุคที่ดูอบอุ่นและมีเสน่ห์ดึงดูด '
            'เสื้อไหมพรมถักสีครีมสัมผัสนุ่มละมุน แมตช์กับกางเกงยีนส์สียีนส์เข้มมิดไนท์บลูทรงกระบอกตรง '
            'คอมพลีทด้วยรองเท้าบูท Chelsea หนังกลับสีน้ำตาล และกระเป๋าสะพายหนังใบเล็ก '
            'ให้ลุคอบอุ่น น่าประทับใจ และดูใส่ใจในรายละเอียดครับ',
        tags: ['#DateNight', '#ลุคอบอุ่น', '#RomanticLook', '#ChelseaBoots', '#MidnightJeans'],
        recommendedItems: _findItemsByIds(['6', '17', '21', '5']),
      );
    }

    // 5. ไปเรียน / มหาลัย / คลาสเรียน / ห้องสมุด
    if (query.contains('เรียน') ||
        query.contains('มหาลัย') ||
        query.contains('สอบ') ||
        query.contains('หอพัก') ||
        query.contains('คลาส') ||
        query.contains('ห้องสมุด')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Campus Casual / College Life',
        advice:
            'สำหรับวันไปเรียนหรือใช้ชีวิตในมหาวิทยาลัย แนะนำลุคคล่องตัว สวมใส่สบายตลอดทั้งวัน '
            'เสื้อฮู้ดดี้ Oversized สีเทาสุดชิค แมตช์กับกางเกงยีนส์ฟอกสี รองเท้าสนีกเกอร์สีขาวที่เดินเรียนได้ไม่เมื่อย '
            'และกระเป๋าเป้ Canvas ช่องใส่โน้ตบุ๊กกันน้ำ พร้อมลุยทุกคลาสเรียนครับ',
        tags: ['#CampusLook', '#ชุดไปเรียน', '#EverydayStyle', '#สนีกเกอร์ขาว', '#ฮู้ดดี้'],
        recommendedItems: _findItemsByIds(['10', '7', '8', '23']),
      );
    }

    // 6. สตรีท / เท่ๆ / ปาร์ตี้ / คอนเสิร์ต / night out
    if (query.contains('สตรีท') ||
        query.contains('street') ||
        query.contains('เท่') ||
        query.contains('ปาร์ตี้') ||
        query.contains('คอนเสิร์ต') ||
        query.contains('y2k') ||
        query.contains('เที่ยวกลางคืน')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Raw Denim & Cargo / Urban Street',
        advice:
            'สำหรับสายสตรีทและปาร์ตี้คอนเสิร์ต แนะนำเสื้อแจ็คเก็ตยีนส์ Oversized ตัวเก่ง '
            'แมตช์กับกางเกงคาร์โก้สตรีทสีเขียวทหาร รองเท้าสนีกเกอร์ขาว และกระเป๋าคาดอก Crossbody สีดำ '
            'เพิ่มความดิบเท่และโดดเด่นไม่ซ้ำใครครับ',
        tags: ['#Streetwear', '#กางเกงคาร์โก้', '#เสื้อคลุมยีนส์', '#UrbanVibe', '#กระเป๋าคาดอก'],
        recommendedItems: _findItemsByIds(['1', '16', '8', '25']),
      );
    }

    // 7. พักผ่อน / วันสบายๆ / สบายๆ / อยู่บ้าน / เดินห้าง
    if (query.contains('พักผ่อน') ||
        query.contains('สบาย') ||
        query.contains('เดินห้าง') ||
        query.contains('กินข้าว')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Cozy Weekend / Relaxed Fit',
        advice:
            'สำหรับวันพักผ่อนเดินห้างหรือกินข้าวชิลๆ แนะนำเสื้อโปโลนิตติ้งสีเขียวมะกอกสุดสมาร์ท '
            'จับคู่กับกางเกงวอร์ม Sweatpants สตรีทสีเทา หรือชิโน่สีกากี พร้อมรองเท้าสนีกเกอร์สีขาว '
            'ให้ความสบายสูงสุดแต่ยังดูดีมีสไตล์ครับ',
        tags: ['#CozyWeekend', '#วันสบายๆ', '#RelaxedFit', '#SmartCasual'],
        recommendedItems: _findItemsByIds(['13', '18', '8', '5']),
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
      recommendedItems: _findItemsByIds(['4', '2', '8', '5']),
    );
  }

  static List<OutfitItem> _findItemsByIds(List<String> ids) {
    final Map<String, OutfitItem> map = {
      for (var item in mockOutfits) item.id: item
    };
    return ids.map((id) => map[id]).whereType<OutfitItem>().toList();
  }
}
