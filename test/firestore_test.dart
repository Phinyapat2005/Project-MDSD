import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:outfitcheck/screens/favorite.dart';
import 'package:outfitcheck/services/firestore_service.dart';

void main() {
  group('Firestore Service Tests', () {
    late FakeFirebaseFirestore fakeDb;
    late FirestoreService firestoreService;

    setUp(() {
      fakeDb = FakeFirebaseFirestore();
      firestoreService = FirestoreService(firestore: fakeDb);
    });

    test('ทดสอบการอ่านและบันทึกข้อมูลโปรไฟล์ผู้ใช้ผ่าน FirestoreService.createOrUpdateUser', () async {
      await firestoreService.createOrUpdateUser(
        uid: 'user_123',
        email: 'poom@kmitl.ac.th',
        displayName: 'Poomchana Tiamkeaw',
        photoUrl: 'https://example.com/avatar.jpg',
      );

      final snapshot = await fakeDb.collection('users').doc('user_123').get();

      expect(snapshot.exists, true);
      expect(snapshot.data()?['displayName'], 'Poomchana Tiamkeaw');
      expect(snapshot.data()?['email'], 'poom@kmitl.ac.th');
      expect(snapshot.data()?['photoUrl'], 'https://example.com/avatar.jpg');
    });

    test('ทดสอบการเพิ่มชุดผ่าน FirestoreService.addOutfit', () async {
      await firestoreService.addOutfit(
        uid: 'user_123',
        outfitName: 'Summer Breeze',
        category: 'Casual',
        imageUrl: 'https://example.com/summer.jpg',
      );

      final snapshot = await fakeDb
          .collection('users')
          .doc('user_123')
          .collection('outfits')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['outfitName'], 'Summer Breeze');
      expect(snapshot.docs.first.data()['category'], 'Casual');
      expect(snapshot.docs.first.data()['imageUrl'], 'https://example.com/summer.jpg');
    });

    test('ทดสอบการดึงข้อมูล Stream ผ่าน FirestoreService.getOutfitsStream', () async {
      await firestoreService.addOutfit(
        uid: 'user_123',
        outfitName: 'Casual Look',
        category: 'Everyday',
        imageUrl: 'https://example.com/casual.jpg',
      );

      final stream = firestoreService.getOutfitsStream('user_123');
      final snapshot = await stream.first;

      expect(snapshot.docs.isNotEmpty, true);
      expect(snapshot.docs.first.get('outfitName'), 'Casual Look');
    });

    test('ทดสอบการแก้ไขชื่อชุดผ่าน FirestoreService.updateOutfitName', () async {
      final docRef = await fakeDb
          .collection('users')
          .doc('user_123')
          .collection('outfits')
          .add({'outfitName': 'Old Name', 'category': 'Casual'});

      await firestoreService.updateOutfitName(
        uid: 'user_123',
        outfitId: docRef.id,
        newName: 'New Style Name',
      );

      final updatedDoc = await docRef.get();
      expect(updatedDoc.data()?['outfitName'], 'New Style Name');
    });

    test('ทดสอบการลบชุดผ่าน FirestoreService.deleteOutfit', () async {
      final docRef = await fakeDb
          .collection('users')
          .doc('user_123')
          .collection('outfits')
          .add({'outfitName': 'To Delete'});

      await firestoreService.deleteOutfit(
        uid: 'user_123',
        outfitId: docRef.id,
      );

      final deletedDoc = await docRef.get();
      expect(deletedDoc.exists, false);
    });

    test('ทดสอบการแปลง Outfit.fromFirestore หลากหลายรูปแบบ', () async {
      // 1. เคสข้อมูลครบถ้วน
      final docRef1 = await fakeDb
          .collection('users')
          .doc('user_test')
          .collection('outfits')
          .add({
        'outfitName': 'Urban Minimal',
        'imageUrl': 'https://example.com/urban.jpg',
        'category': 'Casual',
        'items': [
          {'text': 'เสื้อยืดสีขาว', 'itemImage': 'https://example.com/shirt.jpg'},
          {'text': 'กางเกงสแล็ค'},
          'รองเท้าผ้าใบ',
        ],
      });

      final doc1 = await docRef1.get();
      final outfit1 = Outfit.fromFirestore(doc1);

      expect(outfit1.title, 'Urban Minimal');
      expect(outfit1.image, 'https://example.com/urban.jpg');
      expect(outfit1.tags, contains('Casual'));
      expect(outfit1.items.length, 3);
      expect(outfit1.items[0].text, 'เสื้อยืดสีขาว');
      expect(outfit1.items[2].text, 'รองเท้าผ้าใบ');

      // 2. เคสข้อมูลว่างเปล่า (Default fallback)
      final docRef2 = await fakeDb
          .collection('users')
          .doc('user_test')
          .collection('outfits')
          .add({});

      final doc2 = await docRef2.get();
      final outfit2 = Outfit.fromFirestore(doc2);

      expect(outfit2.title, 'ลุคแต่งตัว');
      expect(outfit2.image, '');
      expect(outfit2.tags.isEmpty, true);
      expect(outfit2.items.isEmpty, true);
    });
  });
}
