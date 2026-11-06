import 'package:flutter_test/flutter_test.dart';
import 'package:outfitcheck/models/outfit_item.dart';

void main() {
  group('OutfitItem Model Tests', () {
    test('ฟอร์แมตราคาและตั้งค่าเริ่มต้นถูกต้อง', () {
      const item = OutfitItem(
        id: '101',
        title: 'เสื้อเชิ้ตโอเวอร์ไซส์',
        category: 'เสื้อ',
        price: 1590,
        imageUrl: 'https://example.com/shirt.jpg',
        description: 'ผ้าคอตตอน 100%',
        gender: 'Unisex',
      );

      expect(item.id, '101');
      expect(item.title, 'เสื้อเชิ้ตโอเวอร์ไซส์');
      expect(item.category, 'เสื้อ');
      expect(item.price, 1590);
      expect(item.formattedPrice, '฿1,590');
      expect(item.gender, 'Unisex');
    });

    test('ฟอร์แมตราคาหลักพันขึ้นไปถูกต้อง', () {
      const item = OutfitItem(
        id: '102',
        title: 'กระเป๋าหนังแท้',
        category: 'กระเป๋า',
        price: 12500,
        imageUrl: 'https://example.com/bag.jpg',
      );

      expect(item.formattedPrice, '฿12,500');
    });
  });
}

