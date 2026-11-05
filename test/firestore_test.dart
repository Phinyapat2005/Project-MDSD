import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('Firestore Service Tests', () {
    test('ทดสอบการอ่านและบันทึกข้อมูลโปรไฟล์ผู้ใช้', () async {
      final instance = FakeFirebaseFirestore();

      // บันทึกข้อมูลจำลอง
      await instance.collection('users').doc('user_test').set({
        'name': 'Poomchana Tiamkeaw',
        'email': '67030180@kmitl.ac.th',
      });
      final snapshot = await instance
          .collection('users')
          .doc('user_test')
          .get();

      expect(snapshot.exists, true);
      expect(snapshot.data()?['name'], 'Poomchana Tiamkeaw');
    });

    test('ทดสอบการเพิ่มชุดใน Sub-collection outfits', () async {
      final instance = FakeFirebaseFirestore();

      await instance
          .collection('users')
          .doc('user_test')
          .collection('outfits')
          .add({'lookName': 'Urban Casual', 'category': 'Casual'});

      final snapshot = await instance
          .collection('users')
          .doc('user_test')
          .collection('outfits')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['lookName'], 'Urban Casual');
    });
  });
}
