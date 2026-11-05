import 'package:flutter_test/flutter_test.dart';

import 'package:outfitcheck/main.dart';

void main() {
  testWidgets('shows the OutfitCheck home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('สวัสดี, คุณสมชาย'), findsOneWidget);
    expect(find.text('แนะนำชุดวันนี้'), findsOneWidget);
    expect(find.text('สถานที่แนะนำวันนี้'), findsOneWidget);
    expect(find.text('สัดส่วนของคุณ'), findsOneWidget);
    expect(find.text('Welcome to OutfitCheck'), findsNothing);
  });

  testWidgets('switches the outfit display mode', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('ชิ้นส่วน'));
    await tester.pumpAndSettle();

    expect(find.text('ชิ้นส่วน'), findsOneWidget);
    expect(find.text('รวม'), findsOneWidget);
  });
}
