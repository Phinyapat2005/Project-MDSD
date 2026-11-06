import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfitcheck/models/outfit_item.dart';
import 'package:outfitcheck/widgets/outfit_card.dart';

void main() {
  group('OutfitCard Widget Tests', () {
    testWidgets('แสดงข้อมูลในการ์ดและตรวจจับการแตะ (onTap)',
        (WidgetTester tester) async {
      bool tapped = false;
      const item = OutfitItem(
        id: '1',
        title: 'แจ็คเก็ตยีนส์',
        category: 'เสื้อ',
        price: 990,
        imageUrl: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 180,
                height: 280,
                child: OutfitCard(
                  item: item,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('แจ็คเก็ตยีนส์'), findsOneWidget);
      expect(find.text('฿990'), findsOneWidget);
      expect(find.text('เสื้อ'), findsOneWidget);

      await tester.tap(find.byType(OutfitCard));
      expect(tapped, true);
    });
  });
}
