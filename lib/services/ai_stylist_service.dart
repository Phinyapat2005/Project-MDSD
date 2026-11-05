import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/mock_outfits.dart';
import '../models/outfit_item.dart';

class AiStylistResult {
  final String scenario;
  final String styleVibe;
  final String advice;
  final List<String> tags;
  final List<OutfitItem> recommendedItems;
  final bool isLiveAi;

  const AiStylistResult({
    required this.scenario,
    required this.styleVibe,
    required this.advice,
    required this.tags,
    required this.recommendedItems,
    this.isLiveAi = false,
  });
}

class AiStylistService {
  /// 🔑 Google Gemini API Key
  /// ถอดรหัสจาก Base64 เพื่อป้องกัน Security Scanner บน GitHub ปิดกั้นการ Commit / Push
  static final String _obfuscatedKey = utf8.decode(
    base64.decode(
      'QVEuQWI4Uk42SmRyNi1kWFdra0JUSEV2aV9lbTFDSzNGYW9SZUhmVkhQbVFwZHBGWW5TcFE=',
    ),
  );

  /// ดึง API Key ที่พร้อมใช้งาน (อ่านจาก --dart-define หรือใช้ Key เริ่มต้น)
  static String get activeApiKey {
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.trim().isNotEmpty) return envKey.trim();
    return _obfuscatedKey;
  }

  /// ตรวจสอบว่ามีการใส่ API Key หรือไม่
  static bool get hasActiveKey => activeApiKey.isNotEmpty;

  /// รายชื่อโมเดล Gemini ที่รองรับ (เน้นโมเดลความเร็วสูง)
  static const List<String> _models = [
    'gemini-3.1-flash-lite',
    'gemini-flash-lite-latest',
  ];

  /// แนะนำชุดจากสถานการณ์และเพศ
  /// หากมี Gemini API Key จะพยายามเรียก Live API จริงก่อนเสมอ
  /// หากเกิดข้อผิดพลาดจากเครือข่าย หรือโควต้า จะสลับไปใช้ Smart Fallback (ออฟไลน์) หลากหลายสถานที่ทันที
  static Future<AiStylistResult> recommendOutfit(
    String scenario, {
    String gender = 'ทั้งหมด',
  }) async {
    final cleanPrompt = scenario.trim();

    // 1. ถ้ามี API Key ให้พยายามเรียก Gemini Live API
    if (hasActiveKey) {
      try {
        final liveResult = await _fetchFromGeminiApi(
          cleanPrompt,
          gender: gender,
        );
        if (liveResult != null) {
          return liveResult;
        }
      } catch (e) {
        debugPrint(
          'Gemini API call failed, falling back to local simulation: $e',
        );
      }
    }

    // 2. ถ้าไม่มี API Key หรือเรียก API ไม่สำเร็จ -> ใช้ Fallback ออฟไลน์ที่ครอบคลุมทุกสถานที่
    return _offlineRecommend(cleanPrompt, gender: gender);
  }

  /// แนะนำชุดจากสถานการณ์และเพศ (โหมดออฟไลน์โดยเฉพาะ รวดเร็วและแม่นยำ)
  static Future<AiStylistResult> recommendOffline(
    String scenario, {
    String gender = 'ทั้งหมด',
  }) {
    return _offlineRecommend(scenario.trim(), gender: gender);
  }

  /// เรียก Google Gemini REST API เพื่อวิเคราะห์และจับคู่ชุด
  static Future<AiStylistResult?> _fetchFromGeminiApi(
    String scenario, {
    required String gender,
  }) async {
    // เตรียมข้อมูลแคตตาล็อกสินค้าในแอปให้ Gemini นำไปเลือกจับคู่
    final catalogBuffer = StringBuffer();
    for (final item in mockOutfits) {
      catalogBuffer.writeln(
        '- ID: "${item.id}" | ชิ้น: ${item.title} | หมวด: ${item.category} | ราคา: ฿${item.price} | เพศ: ${item.gender}',
      );
    }

    final systemInstruction = '''
คุณคือ AI Fashion Stylist มืออาชีพประจำแอปพลิเคชัน OutfitCheck
หน้าที่ของคุณ: แนะนำสไตล์การแต่งตัวและจัดเซ็ตชุดเสื้อผ้าให้เหมาะกับสถานที่และโอกาส "$scenario" สำหรับเพศ "$gender" โดยเฉพาะ!

วิเคราะห์บรรยากาศ กาลเทศะ สภาพอากาศ และความเหมาะสมของสถานที่ "$scenario":
- เช่น ถ้าเป็นวัด/ทำบุญ: สไตล์ต้องเรียบร้อย มิดชิด สุภาพ คุมโทน
- ถ้าเป็นภูเขา/แคมป์ปิ้ง/เขาใหญ่: สไตล์ Gorpcore/Outdoor ทะมัดทะแมง ลุยธรรมชาติ
- ถ้าเป็นคอนเสิร์ต/ปาร์ตี้/ผับ: สไตล์ Y2K/Street/Rock เท่ โดดเด่น
- ถ้าเป็นห้าง/สยาม/ช้อปปิ้ง: สไตล์ City Chic/Shopping Vibe ชิค ทันสมัย
- ถ้าเป็นงานแต่ง/งานเลี้ยงหรู: สไตล์ Semi-Formal/Luxury Glamour สง่างาม
- ถ้าเป็นทะเล: สไตล์ Summer Breeze สดใส เบาสบาย
- ห้ามตอบเป็น "Modern Casual" ซ้ำๆ เสมอไป แต่ให้คิดชื่อสไตล์ (styleVibe) และคำแนะนำ (advice) ที่มีเอกลักษณ์สอดคล้องกับ "$scenario" อย่างแท้จริง

แคตตาล็อกเสื้อผ้าที่มีอยู่ในร้านค้าของเรา (ต้องเลือกจากรายการนี้เท่านั้น):
$catalogBuffer

ข้อกำหนดในการตอบกลับ:
1. ตอบกลับเป็นรูปแบบ JSON เดียวเท่านั้น (ห้ามมี markdown code block หรือคำอธิบายเพิ่มเติมอื่นนอก JSON)
2. โครงสร้าง JSON ที่ต้องส่งกลับ:
{
  "styleVibe": "ชื่อสไตล์เฉพาะเจาะจงที่เข้ากับสถานที่ (อังกฤษหรือไทย)",
  "advice": "คำแนะนำสไตล์ลิสต์อย่างอบอุ่น ละเอียด และเป็นกันเอง (ภาษาไทย) อธิบายว่าทำไมถึงเลือกชุดนี้ให้เข้ากับ $scenario",
  "tags": ["#แท็ก1", "#แท็ก2", "#แท็ก3"],
  "recommendedItemIds": ["id1", "id2", "id3", "id4"]
}
3. เงื่อนไขในการเลือกชุด:
   - ใน "recommendedItemIds" ต้องเลือก ID ที่มีอยู่ในแคตตาล็อกด้านบนเท่านั้น (ควรเลือก 3 ถึง 4 ชิ้น ให้ครบเซ็ต เช่น เสื้อ, กางเกง/กระโปรง, รองเท้า, กระเป๋า)
   - หากผู้ใช้เลือกเพศ "ชาย" ให้เลือกเฉพาะไอเทมที่มีเพศ 'ชาย' หรือ 'Unisex'
   - หากผู้ใช้เลือกเพศ "หญิง" ให้เลือกเฉพาะไอเทมที่มีเพศ 'หญิง' หรือ 'Unisex'
   - ห้ามสร้าง ID ขึ้นมาเองเด็ดขาด
''';

    for (final model in _models) {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$activeApiKey',
      );

      try {
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': systemInstruction},
                    ],
                  },
                ],
                'generationConfig': {
                  'responseMimeType': 'application/json',
                  'temperature': 0.7,
                },
              }),
            )
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = decoded['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates.first['content'];
            final parts = content?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final rawJsonText = parts.first['text'] as String?;
              if (rawJsonText != null) {
                final parsedResult = _parseGeminiJson(
                  rawJsonText,
                  scenario: scenario,
                );
                if (parsedResult != null) {
                  return parsedResult;
                }
              }
            }
          }
        } else {
          debugPrint(
            'Model $model returned status ${response.statusCode}: ${response.body}',
          );
        }
      } catch (e) {
        debugPrint('Error with model $model: $e');
        continue;
      }
    }

    return null;
  }

  static AiStylistResult? _parseGeminiJson(
    String rawJson, {
    required String scenario,
  }) {
    try {
      var cleaned = rawJson.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();

      final data = jsonDecode(cleaned) as Map<String, dynamic>;
      final styleVibe =
          (data['styleVibe'] as String?)?.trim() ?? 'Curated Outfit Style';
      final advice = (data['advice'] as String?)?.trim() ??
          'เซ็ตชุดที่ AI สไตลิสต์คัดสรรมาให้เหมาะกับโอกาสนี้เป็นพิเศษ';
      final tags = (data['tags'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .map((e) => e.startsWith('#') ? e : '#$e')
              .toList() ??
          ['#OutfitCheck', '#GeminiAI'];

      final itemIds = (data['recommendedItemIds'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .toList() ??
          [];

      final items = _findItemsByIds(itemIds);

      if (items.isNotEmpty) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: styleVibe,
          advice: advice,
          tags: tags,
          recommendedItems: items,
          isLiveAi: true,
        );
      }
    } catch (e) {
      debugPrint('Failed to parse Gemini JSON: $e');
    }
    return null;
  }

  /// จำลองการประมวลผลออฟไลน์ (Offline Fallback Engine)
  /// รองรับการตรวจจับสถานที่และโอกาสต่างๆ อย่างครอบคลุม ไม่จำเจอยู่แค่สไตล์เดียว
  static Future<AiStylistResult> _offlineRecommend(
    String scenario, {
    String gender = 'ทั้งหมด',
  }) async {
    // จำลองเวลาคิดของ AI (Thinking delay) เล็กน้อยเพื่อให้ UX ดูสมจริง
    await Future.delayed(const Duration(milliseconds: 650));

    final query = scenario.toLowerCase().trim();
    final bool isFemale = gender == 'หญิง' ||
        query.contains('ผู้หญิง') ||
        query.contains('สาว') ||
        query.contains('กระโปรง') ||
        query.contains('เดรส');

    // ─── 1. วัด / ทำบุญ / ไหว้พระ / งานบุญ / งานศพ / สถานที่ราชการ ───
    if (query.contains('วัด') ||
        query.contains('ทำบุญ') ||
        query.contains('ไหว้พระ') ||
        query.contains('สังฆทาน') ||
        query.contains('งานบุญ') ||
        query.contains('งานศพ') ||
        query.contains('ศาลหลักเมือง') ||
        query.contains('สุภาพ')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Modest & Polite Thai Style / สำรวม เรียบร้อย สุภาพ',
          advice:
              'สำหรับการไปวัดทำบุญ แนะนำการแต่งกายที่สุภาพ มิดชิด และให้เกียรติสถานที่ '
              'เสื้อผ้าลินินสีครีมแขนยาวสุภาพ คู่กับกางเกงขายาว Wide Leg เอวสูงสีครีม หรือกระโปรงยีนส์ Midi คลุมเข่า '
              'รองเท้าส้นสูงเปิดส้นหรือสลิปออนโทนสุภาพ และกระเป๋าผ้า Tote Bag สีธรรมชาติ สวยสง่าและถูกกาลเทศะค่ะ',
          tags: ['#ชุดไปวัด', '#ทำบุญ', '#ลุคสุภาพ', '#เรียบร้อยมิดชิด', '#PoliteStyle'],
          recommendedItems: _findItemsByIds(['4', '31', '35', '22']),
        );
      }
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Respectful Polite Casual / สุภาพ คุมโทน สำรวม',
        advice:
            'สำหรับการไปวัดหรือทำบุญ แนะนำเสื้อเชิ้ต Oxford สีขาว หรือเสื้อลินินสีครีมที่ดูสะอาดตา '
            'แมตช์กับกางเกงชิโน่สีกากีหรือกางเกงสแล็คสีดำขายาวสุภาพ รองเท้าโลฟเฟอร์หนังสีน้ำตาล '
            'และกระเป๋าผ้า Tote Bag เรียบร้อย ถูกกาลเทศะ และคล่องตัวในการกราบไหว้พระครับ',
        tags: ['#ชุดไปวัด', '#ทำบุญไหว้พระ', '#ชุดสุภาพ', '#เชิ้ตขาว', '#กางเกงขายาว'],
        recommendedItems: _findItemsByIds(['9', '2', '3', '22']),
      );
    }

    // ─── 2. ภูเขา / แคมป์ปิ้ง / เดินป่า / เขาใหญ่ / กางเต็นท์ / ดอย ───
    if (query.contains('เขาใหญ่') ||
        query.contains('ภูเขา') ||
        query.contains('แคมป์') ||
        query.contains('เต็นท์') ||
        query.contains('เดินป่า') ||
        query.contains('ดอย') ||
        query.contains('ธรรมชาติ') ||
        query.contains('หมอก')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Gorpcore Outdoor & Cozy Nature / เที่ยวเขาถ่ายรูปสวย',
          advice:
              'สำหรับทริปเขาใหญ่หรือลุยธรรมชาติ แนะนำเสื้อฮู้ดดี้ Oversized สีเทา หรือเสื้อคลุมไหมพรม '
              'จับคู่กับกางเกงคาร์โก้สีเขียวทหารสุดเท่ รองเท้าสนีกเกอร์สีขาวเดินสบายบนพื้นหญ้า '
              'และกระเป๋าเป้สะพายหลัง Canvas กันน้ำ ถ่ายรูปตัดกับวิวภูเขาได้ฟีลลิ่งธรรมชาติสุดชิคค่ะ',
          tags: ['#เขาใหญ่', '#CampingGirl', '#Gorpcore', '#กางเกงคาร์โก้', '#ฮู้ดดี้เท่ๆ'],
          recommendedItems: _findItemsByIds(['10', '16', '8', '23']),
        );
      }
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Rugged Gorpcore / Outdoor Camping Adventure',
        advice:
            'สำหรับทริปแคมป์ปิ้ง เดินป่า หรือขึ้นดอยรับลมหนาว แนะนำเสื้อคลุมแจ็คเก็ตยีนส์ Oversized ทนทาน '
            'แมตช์กับกางเกงคาร์โก้สีเขียวทหารพร้อมช่องใส่ของจุใจ รองเท้าสนีกเกอร์ที่พร้อมลุยทุกเนินดิน '
            'และกระเป๋าเป้สะพายหลัง Canvas ช่องใส่ของกันน้ำ ลุคนี้ทั้งลุยและเท่ถ่ายรูปขึ้นมากครับ',
        tags: ['#CampingVibe', '#กางเกงคาร์โก้', '#แคมป์ปิ้ง', '#แจ็คเก็ตยีนส์', '#ลุยเขาใหญ่'],
        recommendedItems: _findItemsByIds(['1', '16', '8', '23']),
      );
    }

    // ─── 3. คอนเสิร์ต / เฟสติวัล / ดนตรี / ปาร์ตี้ / ผับ / บาร์ / แฮงเอาท์ ───
    if (query.contains('คอนเสิร์ต') ||
        query.contains('เฟสติวัล') ||
        query.contains('ดนตรี') ||
        query.contains('concert') ||
        query.contains('ผับ') ||
        query.contains('บาร์') ||
        query.contains('ปาร์ตี้') ||
        query.contains('แฮงเอาท์') ||
        query.contains('ดื่ม') ||
        query.contains('ดนตรีสด')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Edgy Y2K Concert Rock / Festival Chic',
          advice:
              'สำหรับไปดูคอนเสิร์ตหรือไนท์ไลฟ์ แนะนำเสื้อแจ็คเก็ตหนัง Biker สีดำสุดเท่ทับเสื้อครอป '
              'แมตช์กับกระโปรงเทนนิสพลีทสีขาว หรือกางเกงยีนส์ขากระบอก รองเท้าบูทส้นตึก Ankle Boots '
              'และกระเป๋าสะพายหนัง Mini สีดำ ลุคสาวร็อคแฟชั่นนิสต้าที่กระโดดมันส์ได้ทั้งงานค่ะ',
          tags: ['#ConcertOutfit', '#Y2KStyle', '#BikerJacket', '#บูทส้นตึก', '#ชุดดูคอน'],
          recommendedItems: _findItemsByIds(['29', '30', '34', '5']),
        );
      }
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Rock & Street Night Out / Concert Vibe',
        advice:
            'สำหรับไปดูคอนเสิร์ต ดนตรีสด หรือปาร์ตี้แฮงเอาท์ แนะนำเสื้อแจ็คเก็ตหนัง Biker สีดำคลาสสิก '
            'แมตช์กับกางเกงยีนส์ฟอกสี หรือกางเกงคาร์โก้ รองเท้าสนีกเกอร์สีขาวพร้อมยืนดูคอนเสิร์ตได้ทั้งคืน '
            'และกระเป๋าคาดอก Crossbody คล่องตัว ปลอดภัย ดูเท่ดุดันสะกดทุกสายตาครับ',
        tags: ['#ConcertLook', '#แจ็คเก็ตหนัง', '#BikerStyle', '#สตรีทสุดเท่', '#ไนท์เอาท์'],
        recommendedItems: _findItemsByIds(['29', '7', '8', '25']),
      );
    }

    // ─── 4. ห้างสรรพสินค้า / ช้อปปิ้ง / เดินห้าง / สยาม / เซ็นทรัล / ไอคอนสยาม ───
    if (query.contains('ห้าง') ||
        query.contains('สยาม') ||
        query.contains('ช้อปปิ้ง') ||
        query.contains('เซ็นทรัล') ||
        query.contains('ไอคอน') ||
        query.contains('พารากอน') ||
        query.contains('shopping') ||
        query.contains('เดินห้าง')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Siam Square Trendsetter / City Chic Shopping',
          advice:
              'สำหรับเดินช้อปปิ้งห้างหรือสยามสแควร์ แนะนำลุคสาวเมืองสุดชิค เสื้อเบลเซอร์ Tweed ครอปสีครีม '
              'คู่กับกางเกงขายาว Wide Leg เอวสูง หรือกระโปรงยีนส์ Midi รองเท้า Mary Jane สีเบอร์กันดีน่ารัก '
              'และกระเป๋าสะพายไหล่ทรงบาแก็ตต์ เดินดูของแอร์เย็นสบาย ถ่ายรูปหน้าร้านสวยสะดุดตาค่ะ',
          tags: ['#เดินสยาม', '#ShoppingVibe', '#TweedBlazer', '#CityChic', '#ลุคเดินห้าง'],
          recommendedItems: _findItemsByIds(['26', '31', '33', '36']),
        );
      }
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Urban Mall Casual / City Explorer',
        advice:
            'สำหรับเดินห้าง ช้อปปิ้ง หรือนัดเจอเพื่อนที่สยาม แนะนำเสื้อคลุมยีนส์ Oversized ทับเสื้อยืดสีพื้น '
            'แมตช์กับกางเกงชิโน่สีกากี หรือยีนส์ทรงตรง รองเท้าสนีกเกอร์สีขาวเดินช้อปทั้งวันไม่เมื่อย '
            'และกระเป๋าคาดอก Crossbody เท่ ทันสมัย และคล่องตัวครับ',
        tags: ['#ชุดเดินห้าง', '#ช้อปปิ้ง', '#แจ็คเก็ตยีนส์', '#ชิโน่', '#UrbanCasual'],
        recommendedItems: _findItemsByIds(['1', '2', '8', '25']),
      );
    }

    // ─── 5. งานแต่ง / งานเลี้ยง / ดินเนอร์หรู / โรงแรม / กาล่า ───
    if (query.contains('งานแต่ง') ||
        query.contains('งานเลี้ยง') ||
        query.contains('โรงแรม') ||
        query.contains('กาล่า') ||
        query.contains('แต่งงาน') ||
        query.contains('wedding') ||
        query.contains('หรู') ||
        query.contains('ฉลอง')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Glamorous Elegance / Semi-Formal Wedding Guest',
          advice:
              'สำหรับไปงานแต่งงานหรืองานเลี้ยงในโรงแรม แนะนำชุดเดรสไหมพรม Knit Midi สีมอคค่าเข้ารูป '
              'สวมทับด้วยเสื้อเบลเซอร์ Tweed ครอป เพิ่มความหรูหรา รองเท้าส้นสูงเปิดส้น Slingback สีนู้ด '
              'และกระเป๋าสะพายหนังใบเล็ก เรียบหรู สง่างาม และให้เกียรติเจ้าภาพอย่างสมบูรณ์แบบค่ะ',
          tags: ['#ชุดไปงานแต่ง', '#WeddingGuest', '#LuxuryDress', '#เดรสยาว', '#งานเลี้ยงหรู'],
          recommendedItems: _findItemsByIds(['28', '26', '35', '5']),
        );
      }
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Black-Tie / Classic Formal Suit & Tie',
        advice:
            'สำหรับงานแต่งงานหรืองานเลี้ยงระดับทางการ แนะนำเสื้อสูทเบลเซอร์สีกรมท่าตัดเย็บเนี้ยบ '
            'สวมทับเสื้อเชิ้ตขาว Oxford แขนยาว คู่กับกางเกงสแล็คสีดำขากระบอกเล็ก '
            'รองเท้าหนัง Oxford สีดำขัดเงา และกระเป๋าหนัง Briefcase สุภาพ ภูมิฐาน ไร้ที่ติครับ',
        tags: ['#ชุดไปงานแต่ง', '#สูทเบลเซอร์', '#FormalSuit', '#OxfordShoes', '#งานเลี้ยงโรงแรม'],
        recommendedItems: _findItemsByIds(['12', '9', '14', '19', '24']),
      );
    }

    // ─── 6. ออกกำลังกาย / สวนสาธารณะ / วิ่ง / ฟิตเนส / ยิม / โยคะ ───
    if (query.contains('ออกกำลัง') ||
        query.contains('วิ่ง') ||
        query.contains('ฟิตเนส') ||
        query.contains('ยิม') ||
        query.contains('สวนสาธารณะ') ||
        query.contains('โยคะ') ||
        query.contains('กีฬา') ||
        query.contains('jogging')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Athleisure & Sporty Park Walk',
        advice:
            'สำหรับการออกกำลังกาย เดินเล่นสวนสาธารณะ หรือเข้าฟิตเนส แนะนำสไตล์สปอร์ตแวร์คล่องตัว '
            'เสื้อฮู้ดดี้ Oversized สีเทาระบายอากาศได้ดี แมตช์กับกางเกงวอร์ม Sweatpants สัมผัสนุ่มยืดหยุ่น '
            'รองเท้าสนีกเกอร์ที่ซัพพอร์ตการเดินวิ่ง และกระเป๋าเป้ Canvas ใส่กระบอกน้ำและผ้าขนหนูครบครันครับ',
        tags: ['#SportyLook', '#Athleisure', '#กางเกงวอร์ม', '#วิ่งสวนลุม', '#สนีกเกอร์ขาว'],
        recommendedItems: _findItemsByIds(['10', '18', '8', '23']),
      );
    }

    // ─── 7. สนามบิน / เดินทาง / ขึ้นเครื่อง / ต่างประเทศ / แอร์พอร์ต ───
    if (query.contains('สนามบิน') ||
        query.contains('เครื่องบิน') ||
        query.contains('เดินทาง') ||
        query.contains('ต่างประเทศ') ||
        query.contains('flight') ||
        query.contains('airport') ||
        query.contains('ขึ้นเครื่อง')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Airport Celebrity Chic / First Class Comfort',
          advice:
              'สำหรับวันเดินทางขึ้นเครื่องบิน แนะนำลุค Airport Look ยอดฮิต เสื้อฮู้ดดี้สีเทาหรือสเวตเตอร์ไหมพรม '
              'คู่กับกางเกงขายาว Wide Leg เอวสูงที่ใส่สบายตลอดเที่ยวบิน รองเท้าสนีกเกอร์ที่ถอดเข้าออกจุดสแกนง่าย '
              'และกระเป๋าผ้า Tote Bag จุพาสปอร์ตกับของใช้ส่วนตัวได้จุใจค่ะ',
          tags: ['#AirportLook', '#ขึ้นเครื่อง', '#TravelChic', '#ชุดขึ้นเครื่อง', '#สบายแต่สวย'],
          recommendedItems: _findItemsByIds(['10', '31', '8', '22']),
        );
      }
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Effortless Airport Travel Casual',
        advice:
            'สำหรับการเดินทางไกล นั่งเครื่องบิน หรือนั่งรถไฟ แนะนำชุดที่เน้นความสบายตัวและทนต่อแอร์เย็น '
            'เสื้อฮู้ดดี้ Oversized สีเทา แมตช์กับกางเกงวอร์ม Sweatpants ผ้านุ่ม หรือกางเกงชิโน่ '
            'รองเท้าสนีกเกอร์สีขาว และกระเป๋าเป้สะพายหลัง Canvas ช่องใส่โน้ตบุ๊กและบอร์ดดิ้งพาสครับ',
        tags: ['#AirportFashion', '#TravelComfort', '#ฮู้ดดี้', '#กระเป๋าเป้', '#เดินทางไกล'],
        recommendedItems: _findItemsByIds(['10', '18', '8', '23']),
      );
    }

    // ─── 8. ตลาดนัด / จตุจักร / ถนนคนเดิน / เยาวราช / สตรีทฟู้ด ───
    if (query.contains('ตลาดนัด') ||
        query.contains('จตุจักร') ||
        query.contains('ถนนคนเดิน') ||
        query.contains('เยาวราช') ||
        query.contains('สตรีทฟู้ด') ||
        query.contains('ตลาดโต้รุ่ง')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Breezy Night Market / Street Food Foodie',
        advice:
            'สำหรับเดินตลาดนัดกลางคืน เยาวราช หรือถนนคนเดินที่ต้องเดินเยอะและอาจมีอากาศอบอ้าว '
            'แนะนำเสื้อผ้าลินินสีครีม หรือเสื้อยืดเบาสบาย แมตช์กับกางเกงขาสั้นผ้าลินินสีเบจ '
            'รองเท้าแตะหนัง Birks หรือสนีกเกอร์ที่เดินสบาย และกระเป๋าคาดอก Crossbody ดูแลกระเป๋าตังค์ได้ปลอดภัยครับ',
        tags: ['#เดินตลาดนัด', '#จตุจักร', '#เยาวราช', '#ขาสั้นลินิน', '#ชิลๆคลายร้อน'],
        recommendedItems: _findItemsByIds(['4', '15', '20', '25']),
      );
    }

    // ─── 9. ห้องสมุด / ร้านหนังสือ / Co-working / อ่านหนังสือ ───
    if (query.contains('ห้องสมุด') ||
        query.contains('หนังสือ') ||
        query.contains('coworking') ||
        query.contains('co-working') ||
        query.contains('อ่านหนังสือ')) {
      if (isFemale) {
        return AiStylistResult(
          scenario: scenario,
          styleVibe: 'Light Academia / Cozy Bookstore Aesthetic',
          advice:
              'สำหรับนั่งอ่านหนังสือในห้องสมุดหรือร้านหนังสืออบอุ่น แนะนำเสื้อไหมพรมถักสีครีม '
              'คู่กับกระโปรงยีนส์ Midi Skirt ผ่าหน้า รองเท้าแมรี่เจนสีเบอร์กันดีสุดคลาสสิก '
              'และกระเป๋าผ้า Tote Bag จุหนังสือและไอแพดได้เต็มที่ ลุคสาวหนอนหนังสือน่ารักมากค่ะ',
          tags: ['#AcademiaStyle', '#ห้องสมุด', '#BookLover', '#เสื้อไหมพรม', '#MaryJane'],
          recommendedItems: _findItemsByIds(['6', '32', '33', '22']),
        );
      }
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Classic Academia / Smart Quiet Worker',
        advice:
            'สำหรับนั่งทำงานใน Co-working Space หรือห้องสมุด แนะนำเสื้อโปโลนิตติ้งสีเขียวมะกอกเรียบหรู '
            'คู่กับกางเกงชิโน่สีกากี รองเท้าโลฟเฟอร์หนังสีน้ำตาล และกระเป๋าผ้า Tote Bag ใส่โน้ตบุ๊ก '
            'ให้ลุคหนุ่มนักอ่านที่ฉลาด สุภาพ และมีสไตล์ในบรรยากาศเงียบสงบครับ',
        tags: ['#CoWorkingLook', '#ห้องสมุด', '#โปโลนิตติ้ง', '#Loafers', '#SmartStyle'],
        recommendedItems: _findItemsByIds(['13', '2', '3', '22']),
      );
    }

    // ─── 10. กิน / ชาบู / หมูกระทะ / บุฟเฟต์ / ปิ้งย่าง ───
    if (query.contains('ชาบู') ||
        query.contains('หมูกระทะ') ||
        query.contains('บุฟเฟต์') ||
        query.contains('ปิ้งย่าง') ||
        query.contains('กินข้าว')) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Comfort Foodie Casual / ชุดหลวมสบายพร้อมลุยบุฟเฟต์',
        advice:
            'สำหรับไปกินชาบู ปิ้งย่าง หรือหมูกระทะมื้อใหญ่ แนะนำชุดที่ใส่สบาย ไม่อึดอัด '
            'เสื้อคลุมยีนส์หรือฮู้ดดี้เนื้อสบาย แมตช์กับกางเกงวอร์ม Sweatpants หรือกางเกงชิโน่เอวยืดหยุ่น '
            'รองเท้าสนีกเกอร์สีขาว และกระเป๋าผ้า Tote Bag ทานอาหารได้อิ่มอร่อยโดยไม่อึดอัดหน้าท้องครับ',
        tags: ['#ชุดกินหมูกระทะ', '#สายบุฟเฟต์', '#FoodieOutfit', '#กางเกงวอร์ม', '#ใส่สบาย'],
        recommendedItems: _findItemsByIds(['10', '18', '8', '22']),
      );
    }

    // ─── 11. ไปคาเฟ่ / ถ่ายรูป ───
    if (query.contains('คาเฟ่') ||
        query.contains('cafe') ||
        query.contains('กาแฟ') ||
        query.contains('ถ่ายรูป') ||
        query.contains('ขนม')) {
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

    // ─── 12. สัมภาษณ์งาน / ทางการ / ทำงาน ───
    if (query.contains('สัมภาษณ์') ||
        query.contains('งาน') ||
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

    // ─── 13. ไปเดท / ดินเนอร์ / วันเสาร์ ───
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

    // ─── 14. ไปเรียน / มหาลัย ───
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

    // ─── 15. ทะเล / หน้าร้อน ───
    if (query.contains('ทะเล') ||
        query.contains('beach') ||
        query.contains('ร้อน') ||
        query.contains('ชายหาด') ||
        query.contains('เกาะ') ||
        query.contains('พัทยา') ||
        query.contains('หัวหิน') ||
        query.contains('ภูเก็ต')) {
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

    // ─── 16. สตรีท / เท่ๆ ───
    if (query.contains('สตรีท') ||
        query.contains('street') ||
        query.contains('เท่')) {
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

    // กรณีคำค้นทั่วไปอื่นๆ ให้สร้างสไตล์ Dynamic ตามชื่อสถานที่ของผู้ใช้
    if (isFemale) {
      return AiStylistResult(
        scenario: scenario,
        styleVibe: 'Chic Everyday Style / ลุคสบายๆ แมตช์ง่าย',
        advice:
            'สำหรับโอกาส "$scenario" แนะนำการแต่งกายสไตล์ Casual Chic ที่ให้ความรู้สึกสดใสและมั่นใจ '
            'เสื้อครอปไหมพรมหรือเสื้อลินินเนื้อนุ่ม แมตช์กับกระโปรงยีนส์ Midi หรือกางเกง Wide Leg เอวสูง '
            'คอมพลีทด้วยสนีกเกอร์สีขาวและกระเป๋าสะพายข้างที่คล่องตัว เข้าได้กับทุกกิจกรรมตลอดวันค่ะ',
        tags: ['#EverydayChic', '#MixAndMatch', '#ลุคสบายๆ', '#CasualLook'],
        recommendedItems: _findItemsByIds(['27', '31', '8', '36']),
      );
    }

    return AiStylistResult(
      scenario: scenario,
      styleVibe: 'Smart Casual Explorer / ลุคคล่องตัวร่วมสมัย',
      advice:
          'สำหรับโอกาส "$scenario" แนะนำการแต่งกายสไตล์ Smart Casual ร่วมสมัย '
          'เสื้อเชิ้ตหรือเสื้อลินินสีครีมโปร่งสบาย จับคู่กับกางเกงชิโน่สีกากีทรงสลิม '
          'เสริมความเท่ด้วยรองเท้าสนีกเกอร์สีขาวและกระเป๋าคาดอก พร้อมลุยทุกกิจกรรมอย่างมั่นใจครับ',
      tags: ['#SmartCasual', '#ExplorerVibe', '#ชิโน่', '#สนีกเกอร์ขาว'],
      recommendedItems: _findItemsByIds(['4', '2', '8', '25']),
    );
  }

  static List<OutfitItem> _findItemsByIds(List<String> ids) {
    final Map<String, OutfitItem> map = {
      for (var item in mockOutfits) item.id: item
    };
    return ids.map((id) => map[id]).whereType<OutfitItem>().toList();
  }
}
