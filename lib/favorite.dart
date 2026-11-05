import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

// โมเดลข้อมูลรายการเสื้อผ้า
class OutfitItem {
  final String text;
  final IconData icon;
  final String itemImage;

  OutfitItem({required this.text, required this.icon, required this.itemImage});
}

// โมเดลข้อมูลชุดแต่งตัว
class Outfit {
  final String id;
  final String title;
  final String image;
  final List<String> tags;
  bool isFavorite;
  final List<OutfitItem> items;

  Outfit({
    required this.id,
    required this.title,
    required this.image,
    required this.tags,
    this.isFavorite = true,
    required this.items,
  });

  factory Outfit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    var rawItems = data['items'] as List<dynamic>? ?? [];
    List<OutfitItem> itemList = rawItems.map((item) {
      return OutfitItem(
        text: item['text'] ?? '',
        icon: Icons.checkroom,
        itemImage: item['itemImage'] ?? '',
      );
    }).toList();

    return Outfit(
      id: doc.id,
      title: data['title'] ?? 'ไม่มีชื่อชุด',
      image: data['image'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      isFavorite: data['isFavorite'] ?? true,
      items: itemList,
    );
  }
}

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final int _selectedIndex = 2;

  // ฟังก์ชันสลับสถานะรายการโปรดใน Firestore (ใช้ sub-collection: outfits)
  Future<void> _toggleFavorite(Outfit outfit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('outfits') // ตรงกับ Firestore ในรูปภาพ
        .doc(outfit.id);

    if (outfit.isFavorite) {
      await docRef.delete();
    } else {
      await docRef.set({
        'title': outfit.title,
        'image': outfit.image,
        'tags': outfit.tags,
        'isFavorite': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  void _showOutfitDetail(Outfit outfit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFF5EFE6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    outfit.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D2C24),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF7A6458)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: outfit.image.isNotEmpty
                    ? Image.network(
                        outfit.image,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 180,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image, size: 50),
                      ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: outfit.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF6F0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE5DCD3)),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A6458),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'รายการเสื้อผ้าในลุคนี้ (กดเพื่อดูรูป)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D2C24),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: outfit.items.isEmpty
                              ? const Center(
                                  child: Text('ไม่มีรายการเสื้อผ้าย่อย'),
                                )
                              : ListView.builder(
                                  itemCount: outfit.items.length,
                                  itemBuilder: (context, index) {
                                    final item = outfit.items[index];
                                    return ListTile(
                                      leading: Icon(
                                        item.icon,
                                        color: const Color(0xFF7A6458),
                                      ),
                                      title: Text(
                                        item.text,
                                        style: const TextStyle(
                                          color: Color(0xFF4A3B32),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right,
                                        size: 20,
                                        color: Color(0xFF7A6458),
                                      ),
                                      onTap: () => _showItemSubModal(item),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showItemSubModal(OutfitItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            item.text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.itemImage.isNotEmpty
                        ? Image.network(item.itemImage, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.checkroom, size: 50),
                          ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ตกลง',
                style: TextStyle(color: Color(0xFF3D2C24)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('กรุณาเข้าสู่ระบบก่อนใช้งาน')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D2C24),
        title: const Text(
          'OutfitCheck',
          style: TextStyle(
            color: Color(0xFFF5EFE6),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ดึงข้อมูลจาก users/{uid}/outfits ตามโครงสร้างใน Firestore
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('outfits')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          final favoritedOutfits = docs
              .map((doc) => Outfit.fromFirestore(doc))
              .toList();

          if (favoritedOutfits.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'ยังไม่มีเสื้อผ้าที่กดติดดาวไว้',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ตู้เสื้อผ้า',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D2C24),
                        ),
                      ),
                      const Text(
                        'สไตล์ที่คุณกดดาวไว้ (ซิงค์จาก Firebase)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7A6458),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...favoritedOutfits.map(
                        (outfit) => GestureDetector(
                          onTap: () => _showOutfitDetail(outfit),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Image.network(
                                      outfit.image,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 180,
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                ),
                                              ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      left: 16,
                                      child: Text(
                                        outfit.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: IconButton(
                                        icon: Icon(
                                          outfit.isFavorite
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.orange,
                                        ),
                                        onPressed: () =>
                                            _toggleFavorite(outfit),
                                      ),
                                    ),
                                  ],
                                ),
                                if (outfit.items.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: outfit.items
                                          .map(
                                            (i) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    i.icon,
                                                    size: 18,
                                                    color: const Color(
                                                      0xFF7A6458,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    i.text,
                                                    style: const TextStyle(
                                                      color: Color(0xFF4A3B32),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        backgroundColor: const Color(0xFF3D2C24),
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFFC4B2A9),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'ค้นหา'),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'ตู้เสื้อผ้า',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}
