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
  /// จำลองการประมวลผลของ Gemini AI ในการวิเคราะห์สถานการณ์และเพศ เพื่อแนะนำชุดที่เหมาะสม
  static Future<AiStylistResult> recommendOutfit(
    String scenario, {
    String gender = 'ทั้งหมด',
  }) async {
    // จำลองเวลาคิดของ AI (Thinking delay) เล็กน้อยเพื่อให้ UX ดูสมจริง
    await Future.delayed(const Duration(milliseconds: 700));

    final query = scenario.toLowerCase().trim();
    final bool isFemale = gender == 'หญิง' ||
        query.contains('ผู้หญิง') ||
        query.contains('สาว') ||
        query.contains('กระโปรง') ||
        query.contains('เดรส');

    // ─── 1. ไปคาเฟ่ / ถ่ายรูป ───
    if (query.contains('คาเฟ่') ||
        query.contains('cafe') ||
        query.contains('กาแฟ') ||
        query.contains('ถ่ายรูป')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Chic Korean Cafe / Cozy Aesthetic',
          advice:
              'สำหรับสาวๆ ไปคาเฟ่ แนะนำลุคเกาหลีมินิมอล เสื้อครอปไหมพรมแขนยาวสีเบจ '
              'แมตช์กับกระโปรงยีนส์ Midi ผ่าหน้า รองเท้าแมรี่เจนสีเบอร์กันดีสุดคิ้วท์ '
              'และกระเป๋าสะพายไหล่ Baguette สีครีม ถ่ายรูปมุมไหนก็ขึ้นกล้อง ละมุนมากค่ะ',
          tags: ['#CafeGirl', '#KoreanStyle', '#MaryJane', '#MidiSkirt', '#มินิมอล'],
          recommendedItems: _findItemsByIds(['27', '32', '33', '36']),
        );
      }
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

    // ─── 2. สัมภาษณ์งาน / ทางการ / ทำงาน ───
    if (query.contains('สัมภาษณ์') ||
        query.contains('งาน') ||
        query.contains('ทางการ') ||
        query.contains('ประชุม') ||
        query.contains('นำเสนอ')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Classy Elegance / Professional Chic',
          advice:
              'สำหรับการสัมภาษณ์งานของผู้หญิง แนะนำลุค Modern Professional เสื้อเบลเซอร์ Tweed ทรงครอป '
              'คู่กับกางเกงขายาว Wide Leg เอวสูงสีครีม เสริมบุคลิกให้ดูสูงเพรียว สุภาพ สง่างาม '
              'และรองเท้าส้นสูง Slingback สีนู้ด สร้างความประทับใจระดับมืออาชีพค่ะ',
          tags: ['#WorkingWoman', '#สัมภาษณ์งาน', '#TweedBlazer', '#WideLeg', '#ลุคสุภาพ'],
          recommendedItems: _findItemsByIds(['26', '31', '35', '5']),
        );
      }
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

    // ─── 3. ไปเดท / ดินเนอร์ / วันเสาร์ ───
    if (query.contains('เดท') ||
        query.contains('date') ||
        query.contains('ดินเนอร์') ||
        query.contains('แฟน') ||
        query.contains('ดูหนัง')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Romantic Allure / Night Out Glow',
          advice:
              'สำหรับวันเดทพิเศษหรือดินเนอร์โรแมนติก แนะนำชุดเดรสไหมพรม Knit Midi สีมอคค่าเข้ารูป '
              'เสริมความชิคด้วยรองเท้าบูทส้นตึกสีดำ และกระเป๋าสะพายไหล่ Baguette สีครีม '
              'ให้ลุคเซ็กซี่อย่างมีระดับ อบอุ่น มีเสน่ห์สะกดสายตาค่ะ',
          tags: ['#DateNightDress', '#KnitMidi', '#AnkleBoots', '#RomanticChic'],
          recommendedItems: _findItemsByIds(['28', '34', '36']),
        );
      }
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Charming Romance / Warm Evening',
        advice:
            'สำหรับวันเดทพิเศษหรือดินเนอร์ยามค่ำคืน แนะนำลุคที่ดูอบอุ่นและมีเสน่ห์ดึงดูด '
            'เสื้อโปโลนิตติ้งสีเขียวมะกอกเรียบหรู แมตช์กับกางเกงยีนส์สียีนส์เข้มมิดไนท์บลูทรงกระบอกตรง '
            'คอมพลีทด้วยรองเท้าบูท Chelsea หนังกลับสีน้ำตาล และกระเป๋าสะพายหนังใบเล็กครับ',
        tags: ['#DateNight', '#ลุคอบอุ่น', '#RomanticLook', '#ChelseaBoots', '#MidnightJeans'],
        recommendedItems: _findItemsByIds(['13', '17', '21', '5']),
      );
    }

    // ─── 4. ไปเรียน / มหาลัย ───
    if (query.contains('เรียน') ||
        query.contains('มหาลัย') ||
        query.contains('สอบ') ||
        query.contains('คลาส')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Preppy Campus / Cute College',
          advice:
              'สำหรับวันไปเรียนชิลๆ แนะนำสไตล์พรีพพีเกาหลี เสื้อฮู้ดดี้ Oversized สีเทา '
              'จับคู่กับกระโปรงเทนนิสพลีทสีขาวน่ารักสดใส สนีกเกอร์สีขาว และกระเป๋าเป้ Canvas กันน้ำ '
              'คล่องตัว น่ารัก และเหมาะกับบรรยากาศในมหาลัยค่ะ',
          tags: ['#CampusGirl', '#TennisSkirt', '#WhiteSneakers', '#ชุดไปเรียนน่ารัก'],
          recommendedItems: _findItemsByIds(['10', '30', '8', '23']),
        );
      }
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

    // ─── 5. ทะเล / หน้าร้อน ───
    if (query.contains('ทะเล') ||
        query.contains('beach') ||
        query.contains('ร้อน') ||
        query.contains('ชายหาด')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Summer Breeze / Island Glow',
          advice:
              'สำหรับทริปทะเลรับลมร้อน แนะนำเสื้อครอปไหมพรมเนื้อบางสีเบจ แมตช์กับกางเกงขาสั้นผ้าลินิน '
              'รองเท้าแตะหนัง Birks เดินรับลมชายหาด และกระเป๋าผ้า Tote Bag จุไอเทมกันแดดครบครันค่ะ',
          tags: ['#SummerGirl', '#BeachChic', '#LinenShorts', '#BeachTote'],
          recommendedItems: _findItemsByIds(['27', '15', '20', '22']),
        );
      }
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

    // ─── 6. สตรีท / เท่ๆ / ปาร์ตี้ ───
    if (query.contains('สตรีท') ||
        query.contains('street') ||
        query.contains('เท่') ||
        query.contains('ปาร์ตี้')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Edgy Streetwear / Biker & Denim',
        advice:
            'สำหรับสายสตรีทสุดเท่ แนะนำแจ็คเก็ตหนัง Biker สีดำ หรือเสื้อคลุมยีนส์ Oversized '
            'แมตช์กับกางเกงคาร์โก้สีเขียวทหาร รองเท้าสนีกเกอร์สีขาว และกระเป๋าคาดอก Crossbody สีดำ '
            'เพิ่มความมั่นใจ ดุดัน และโดดเด่นไม่ซ้ำใครครับ',
        tags: ['#BikerJacket', '#Streetwear', '#กางเกงคาร์โก้', '#UrbanChic'],
        recommendedItems: _findItemsByIds(['29', '16', '8', '25']),
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
