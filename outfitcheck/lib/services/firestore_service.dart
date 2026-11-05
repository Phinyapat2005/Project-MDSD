import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // ดึง Instance ของ Firestore มาใช้งาน
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -------------------------------------------------------------------
  // 1. CREATE: สร้างหรืออัปเดตข้อมูลผู้ใช้ (Save User Data)
  // -------------------------------------------------------------------
  Future<void> createOrUpdateUser({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      // อ้างอิงไปยัง Collection 'users' และ Document ที่ใช้ ID เป็น uid
      await _db.collection('users').doc(uid).set(
        {
          'uid': uid,
          'email': email,
          'displayName': displayName,
          'photoUrl': photoUrl ?? '',
          'createdAt': FieldValue.serverTimestamp(), // บันทึกเวลาฝั่ง Server
          'lastLogin': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ); // merge: true ช่วยป้องกันการลบข้อมูลฟิลด์อื่นที่มีอยู่เดิม
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // -------------------------------------------------------------------
  // 2. CREATE: เพิ่มข้อมูลชุดแต่งกายใหม่ (Add Outfit Data)
  // -------------------------------------------------------------------
  Future<void> addOutfit({
    required String uid,
    required String outfitName,
    required String category,
    required String imageUrl,
  }) async {
    try {
      // ใช้ .add() เพื่อให้ Firestore เจน Sub-document ID ให้อัตโนมัติ
      await _db.collection('users').doc(uid).collection('outfits').add({
        'outfitName': outfitName,
        'category': category,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding outfit: $e');
      rethrow;
    }
  }

  // -------------------------------------------------------------------
  // 3. READ: ดึงข้อมูลแบบเรียลไทม์ (Stream Data)
  // -------------------------------------------------------------------
  Stream<QuerySnapshot> getOutfitsStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('outfits')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // -------------------------------------------------------------------
  // 4. UPDATE: แก้ไขข้อมูลเฉพาะฟิลด์ที่ต้องการ (Update Outfit)
  // -------------------------------------------------------------------
  Future<void> updateOutfitName({
    required String uid,
    required String outfitId,
    required String newName,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('outfits')
          .doc(outfitId)
          .update({
            'outfitName': newName,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error updating outfit: $e');
      rethrow;
    }
  }

  // -------------------------------------------------------------------
  // 5. DELETE: ลบข้อมูล (Delete Outfit)
  // -------------------------------------------------------------------
  Future<void> deleteOutfit({
    required String uid,
    required String outfitId,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('outfits')
          .doc(outfitId)
          .delete();
    } catch (e) {
      print('Error deleting outfit: $e');
      rethrow;
    }
  }
}
