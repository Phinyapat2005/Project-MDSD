import '../models/outfit_item.dart';

final List<OutfitItem> mockOutfits = [
  // ══════════════════════════════════════════
  // หมวดหมู่: เสื้อ (Tops & Outerwear)
  // ══════════════════════════════════════════
  const OutfitItem(
    id: '1',
    title: 'เสื้อคลุมยีนส์ Oversized',
    category: 'เสื้อ',
    price: 1290,
    imageUrl:
        'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?auto=format&fit=crop&w=600&q=80',
    description: 'เสื้อแจ็คเก็ตยีนส์ทรงโอเวอร์ไซส์ สไตล์สตรีท คลุมทับได้ทุกลุค',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '4',
    title: 'เสื้อ Linen ครีม',
    category: 'เสื้อ',
    price: 890,
    imageUrl:
        'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?auto=format&fit=crop&w=600&q=80',
    description: 'เสื้อผ้าลินินแท้ สีครีมธรรมชาติ นุ่มโปร่ง เหมาะกับวันไปคาเฟ่สบายๆ',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '6',
    title: 'เสื้อไหมพรมถัก ครีม',
    category: 'เสื้อ',
    price: 790,
    imageUrl:
        'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?auto=format&fit=crop&w=600&q=80',
    description: 'เสื้อสเวตเตอร์ไหมพรมถักเนื้อนุ่ม โทนสีละมุน เหมาะกับวันเดทสุดโรแมนติก',
    gender: 'หญิง',
  ),
  const OutfitItem(
    id: '9',
    title: 'เสื้อเชิ้ต Oxford สีขาว Slim Fit',
    category: 'เสื้อ',
    price: 1190,
    imageUrl:
        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=600&q=80',
    description: 'เสื้อเชิ้ตคอปกผ้าคอตตอน Oxford เนี้ยบ สุภาพ เหมาะกับการสัมภาษณ์งาน',
    gender: 'ชาย',
  ),
  const OutfitItem(
    id: '10',
    title: 'เสื้อฮู้ดดี้ Oversized สีเทา',
    category: 'เสื้อ',
    price: 990,
    imageUrl:
        'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?auto=format&fit=crop&w=600&q=80',
    description: 'เสื้อกันหนาวมีฮู้ดทรงหลวม ผ้าหนานุ่ม อบอุ่น คล่องตัวในวันไปเรียน',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '11',
    title: 'เสื้อเชิ้ตฮาวาย ลายทรอปิคอล',
    category: 'เสื้อ',
    price: 690,
    imageUrl:
        'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&w=600&q=80',
    description: 'เสื้อฮาวายลายใบไม้สดใส ผ้าเรยอนเบาสบาย รับลมทะเลได้ดีเยี่ยม',
    gender: 'ชาย',
  ),
  const OutfitItem(
    id: '12',
    title: 'สูทเบลเซอร์ สีกรมท่า Navy',
    category: 'เสื้อ',
    price: 2490,
    imageUrl:
        'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=600&q=80',
    description: 'เสื้อสูทเบลเซอร์ทางการ ตัดเย็บพรีเมียม เสริมบุคลิกภาพให้ดูน่าเชื่อถือ',
    gender: 'ชาย',
  ),
  const OutfitItem(
    id: '13',
    title: 'เสื้อโปโล นิตติ้งสีเขียวมะกอก',
    category: 'เสื้อ',
    price: 850,
    imageUrl:
        'https://images.unsplash.com/photo-1586363104862-3a5e2ab60d99?auto=format&fit=crop&w=600&q=80',
    description: 'เสื้อโปโลผ้านิตเรียบหรู สไตล์ Smart Casual ใส่ทำงานหรือไปเที่ยวก็ดูดี',
    gender: 'ชาย',
  ),
  const OutfitItem(
    id: '26',
    title: 'เสื้อเบลเซอร์ Tweed ครอป สีครีม',
    category: 'เสื้อ',
    price: 1890,
    imageUrl:
        'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=600&q=80',
    description: 'เสื้อแจ็คเก็ตผ้าทวีดทรงครอป กระดุมทองหรูหรา ลุคลูกคุณหนูสไตล์เกาหลี',
    gender: 'หญิง',
  ),
  const OutfitItem(
    id: '27',
    title: 'เสื้อครอปไหมพรม แขนยาวสีเบจ',
    category: 'เสื้อ',
    price: 690,
    imageUrl:
        'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=600&q=80',
    description: 'เสื้อครอปเข้ารูปไหมพรมเนื้อบาง นุ่ม สบาย แมตช์กับกระโปรงหรือยีนส์เอวสูง',
    gender: 'หญิง',
  ),
  const OutfitItem(
    id: '28',
    title: 'เดรสไหมพรม Knit Midi สีมอคค่า',
    category: 'เสื้อ',
    price: 1390,
    imageUrl:
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=600&q=80',
    description: 'ชุดเดรสยาวไหมพรมเข้ารูป ดีไซน์เรียบหรู ใส่ไปเดทดินเนอร์หรือคาเฟ่ชิคๆ',
    gender: 'หญิง',
  ),
  const OutfitItem(
    id: '29',
    title: 'เสื้อแจ็คเก็ตหนัง Biker สีดำ',
    category: 'เสื้อ',
    price: 2190,
    imageUrl:
        'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=600&q=80',
    description: 'แจ็คเก็ตหนังไบเกอร์สุดเท่ อะไหล่เงินคลาสสิก เพิ่มความมั่นใจและสตรีท',
    gender: 'Unisex',
  ),

  // ══════════════════════════════════════════
  // หมวดหมู่: กางเกง & กระโปรง (Bottoms)
  // ══════════════════════════════════════════
  const OutfitItem(
    id: '2',
    title: 'Chinos สีกากี Slim Fit',
    category: 'กางเกง',
    price: 990,
    imageUrl:
        'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=600&q=80',
    description: 'กางเกงชิโน่สีกากี ทรงกระชับ ผ้าคอตตอนยืดหยุ่น แมตช์กับลุคคาเฟ่',
    gender: 'ชาย',
  ),
  const OutfitItem(
    id: '7',
    title: 'กางเกงยีนส์ Skinny ฟอกสี',
    category: 'กางเกง',
    price: 1190,
    imageUrl:
        'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=600&q=80',
    description: 'กางเกงยีนส์ยืดกระชับสัดส่วน สีสว่าง ใส่ไปเรียนหรือเที่ยวชิลๆ',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '14',
    title: 'กางเกงสแล็ค ทรงกระบอกเล็ก สีดำ',
    category: 'กางเกง',
    price: 1290,
    imageUrl:
        'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?auto=format&fit=crop&w=600&q=80',
    description: 'กางเกงสแล็คเนื้อผ้าเรียบหรู ไม่ยับง่าย ทรงสุภาพสำหรับสัมภาษณ์งาน',
    gender: 'ชาย',
  ),
  const OutfitItem(
    id: '15',
    title: 'กางเกงขาสั้นผ้าลินิน สีเบจ',
    category: 'กางเกง',
    price: 590,
    imageUrl:
        'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&w=600&q=80',
    description: 'กางเกงขาสั้นผ้าลินินโปร่งสบาย ระบายความร้อน เหมาะกับทริปเที่ยวทะเล',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '16',
    title: 'กางเกงคาร์โก้ สีเขียวทหาร',
    category: 'กางเกง',
    price: 1390,
    imageUrl:
        'https://images.unsplash.com/photo-1517445312882-bc9910d016b7?auto=format&fit=crop&w=600&q=80',
    description: 'กางเกงคาร์โก้กระเป๋าข้างจุใจ สไตล์สตรีทแฟชั่น ทนทาน ลุยได้ทุกที่',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '17',
    title: 'กางเกงยีนส์ Straight Fit มิดไนท์บลู',
    category: 'กางเกง',
    price: 1450,
    imageUrl:
        'https://images.unsplash.com/photo-1542272604-780c96856592?auto=format&fit=crop&w=600&q=80',
    description: 'กางเกงยีนส์ทรงขากระบอกตรง สียีนส์เข้มพรีเมียม ให้ลุคเนี้ยบในวันเดท',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '18',
    title: 'กางเกงวอร์ม Sweatpants สีเทา',
    category: 'กางเกง',
    price: 690,
    imageUrl:
        'https://images.unsplash.com/photo-1552902865-b72c031ac5ea?auto=format&fit=crop&w=600&q=80',
    description: 'กางเกงวอร์มผ้าสเวตสัมผัสนุ่ม สบายตัวสูงสุด เหมาะกับวันพักผ่อน',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '30',
    title: 'กระโปรงเทนนิสพลีท สีขาว',
    category: 'กางเกง',
    price: 590,
    imageUrl:
        'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?auto=format&fit=crop&w=600&q=80',
    description: 'กระโปรงจับจีบพลีทสไตล์เกาหลี น่ารักสดใส ใส่ไปคาเฟ่หรือเที่ยววันหยุด',
    gender: 'หญิง',
  ),
  const OutfitItem(
    id: '31',
    title: 'กางเกงขายาว Wide Leg เอวสูง สีครีม',
    category: 'กางเกง',
    price: 890,
    imageUrl:
        'https://images.unsplash.com/photo-1508427953056-b00b8d78ebf5?auto=format&fit=crop&w=600&q=80',
    description: 'กางเกงขากระบอกใหญ่เอวสูง ทรงทิ้งตัวสวย เสริมให้ดูสูงเพรียว สไตล์มินิมอล',
    gender: 'หญิง',
  ),
  const OutfitItem(
    id: '32',
    title: 'กระโปรงยีนส์ Midi Skirt ผ่าหน้า',
    category: 'กางเกง',
    price: 990,
    imageUrl:
        'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?auto=format&fit=crop&w=600&q=80',
    description: 'กระโปรงยีนส์ยาวคลุมเข่าผ่าหน้า ทันสมัย ยอดฮิตในหมู่แฟชั่นนิสต้า',
    gender: 'หญิง',
  ),

  // ══════════════════════════════════════════
  // หมวดหมู่: รองเท้า (Shoes)
  // ══════════════════════════════════════════
  const OutfitItem(
    id: '3',
    title: 'รองเท้า Loafer หนังสีน้ำตาล',
    category: 'รองเท้า',
    price: 2590,
    imageUrl:
        'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?auto=format&fit=crop&w=600&q=80',
    description: 'รองเท้าหนังแท้ทรงโลฟเฟอร์ คลาสสิก เรียบหรู เข้ากับลุคคาเฟ่และชิโน่',
    gender: 'ชาย',
  ),
  const OutfitItem(
    id: '8',
    title: 'รองเท้า Sneaker สีขาวคลาสสิก',
    category: 'รองเท้า',
    price: 1990,
    imageUrl:
        'https://images.unsplash.com/photo-1560769629-975ec94e6a86?auto=format&fit=crop&w=600&q=80',
    description: 'สนีกเกอร์สีขาวมินิมอล ใส่สบาย นุ่มเท้า เข้ากับชุดไปเรียนและสตรีท',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '19',
    title: 'รองเท้า Oxford หนังแท้สีดำ',
    category: 'รองเท้า',
    price: 2890,
    imageUrl:
        'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=600&q=80',
    description: 'รองเท้าทางการหนังแท้สีดำเงางาม สุภาพ เนี้ยบ สำหรับการสัมภาษณ์งาน',
    gender: 'ชาย',
  ),
  const OutfitItem(
    id: '20',
    title: 'รองเท้าแตะหนัง Birks สีน้ำตาล',
    category: 'รองเท้า',
    price: 1290,
    imageUrl:
        'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?auto=format&fit=crop&w=600&q=80',
    description: 'รองเท้าแตะหนังดีไซน์มินิมอล ซัพพอร์ตเท้าดี เดินชายหาดสบายไม่เมื่อย',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '21',
    title: 'รองเท้าบูท Chelsea Boots หนังกลับ',
    category: 'รองเท้า',
    price: 3290,
    imageUrl:
        'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?auto=format&fit=crop&w=600&q=80',
    description: 'รองเท้าบูททรงเชลซีหนังกลับสีน้ำตาล ทรงสวย เสริมเสน่ห์วันเดทดินเนอร์',
    gender: 'ชาย',
  ),
  const OutfitItem(
    id: '33',
    title: 'รองเท้า Mary Jane หนังเงาสีเบอร์กันดี',
    category: 'รองเท้า',
    price: 1690,
    imageUrl:
        'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=600&q=80',
    description: 'รองเท้าแมรี่เจนส้นเตี้ย หนังแก้วสีแดงก่ำ สไตล์วินเทจน่ารัก แมตช์กับกระโปรง',
    gender: 'หญิง',
  ),
  const OutfitItem(
    id: '34',
    title: 'รองเท้าบูทส้นตึก หนังสีดำ Ankle Boots',
    category: 'รองเท้า',
    price: 2290,
    imageUrl:
        'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?auto=format&fit=crop&w=600&q=80',
    description: 'รองเท้าบูทหุ้มข้อส้นหนา หนังสีดำเรียบหรู เพิ่มความสูงและความมั่นใจ',
    gender: 'หญิง',
  ),
  const OutfitItem(
    id: '35',
    title: 'รองเท้าส้นสูง Slingback สีนู้ด',
    category: 'รองเท้า',
    price: 1790,
    imageUrl:
        'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?auto=format&fit=crop&w=600&q=80',
    description: 'รองเท้าส้นสูงเปิดส้นโทนสีนู้ด เรียบร้อย สุภาพ เหมาะกับสัมภาษณ์งานและออกงาน',
    gender: 'หญิง',
  ),

  // ══════════════════════════════════════════
  // หมวดหมู่: กระเป๋า (Bags & Accessories)
  // ══════════════════════════════════════════
  const OutfitItem(
    id: '5',
    title: 'กระเป๋าสะพายหนัง Mini สีดำ',
    category: 'กระเป๋า',
    price: 1890,
    imageUrl:
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=600&q=80',
    description: 'กระเป๋าสะพายข้างหนังพรีเมียม ขนาดกะทัดรัด จุของจำเป็นได้พอดี',
    gender: 'หญิง',
  ),
  const OutfitItem(
    id: '22',
    title: 'กระเป๋าผ้า Tote Bag ลินินมินิมอล',
    category: 'กระเป๋า',
    price: 490,
    imageUrl:
        'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=600&q=80',
    description: 'กระเป๋าผ้าแคนวาสลินินธรรมชาติ น้ำหนักเบา จุของเยอะ เหมาะกับไปคาเฟ่และทะเล',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '23',
    title: 'กระเป๋าเป้สะพายหลัง Canvas กันน้ำ',
    category: 'กระเป๋า',
    price: 1590,
    imageUrl:
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=600&q=80',
    description: 'กระเป๋าเป้ช่องใส่โน้ตบุ๊ก ผ้าหนากันละอองน้ำ เหมาะสำหรับชีวิตมหาลัย',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '24',
    title: 'กระเป๋าเอกสารหนัง Briefcase สีดำ',
    category: 'กระเป๋า',
    price: 2790,
    imageUrl:
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=600&q=80',
    description: 'กระเป๋าใส่เอกสารและแล็ปท็อปทรงบรีฟเคส สุภาพ หรูหรา เหมาะกับวันสัมภาษณ์',
    gender: 'ชาย',
  ),
  const OutfitItem(
    id: '25',
    title: 'กระเป๋าคาดอก Crossbody สตรีทสีดำ',
    category: 'กระเป๋า',
    price: 990,
    imageUrl:
        'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?auto=format&fit=crop&w=600&q=80',
    description: 'กระเป๋าคาดอกสไตล์สตรีท คล่องตัว ปรับสายได้ เท่ทุกลุค',
    gender: 'Unisex',
  ),
  const OutfitItem(
    id: '36',
    title: 'กระเป๋าสะพายไหล่ Baguette สีครีม',
    category: 'กระเป๋า',
    price: 1490,
    imageUrl:
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=600&q=80',
    description: 'กระเป๋าสะพายไหล่ทรงบาแก็ตต์สีครีมมินิมอล แมตช์ง่าย เหมาะกับลุคคาเฟ่และเดท',
    gender: 'หญิง',
  ),
];
