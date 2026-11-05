import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'home_screen.dart';

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

    // 1. ดึงรายการเสื้อผ้าย่อย items
    var rawItems = data['items'] as List<dynamic>? ?? [];
    List<OutfitItem> itemList = rawItems.map((item) {
      if (item is Map) {
        return OutfitItem(
          text: (item['text'] ?? item['name'] ?? item['title'] ?? 'เสื้อผ้า').toString(),
          icon: Icons.checkroom,
          itemImage: (item['itemImage'] ?? item['imageUrl'] ?? item['image'] ?? '').toString(),
        );
      }
      return OutfitItem(
        text: item.toString(),
        icon: Icons.checkroom,
        itemImage: '',
      );
    }).toList();

    // 2. ดึงชื่อชุด (รองรับ title, outfitName, lookName, name)
    final title = (data['title'] ??
            data['outfitName'] ??
            data['lookName'] ??
            data['name'] ??
            'ลุคแต่งตัว')
        .toString();

    // 3. ดึงรูปภาพ (รองรับ image, imageUrl, photoUrl, outfitImage)
    final image = (data['image'] ??
            data['imageUrl'] ??
            data['photoUrl'] ??
            data['outfitImage'] ??
            '')
        .toString();

    // 4. ดึงแท็ก (รองรับ tags แบบ List หรือ category แบบ String)
    List<String> tagList = [];
    if (data['tags'] is List) {
      tagList = (data['tags'] as List).map((t) => t.toString()).toList();
    } else if (data['category'] != null && data['category'].toString().isNotEmpty) {
      tagList = [data['category'].toString()];
    }

    return Outfit(
      id: doc.id,
      title: title,
      image: image,
      tags: tagList,
      isFavorite: data['isFavorite'] ?? true,
      items: itemList,
    );
  }
}

class FavoriteScreen extends StatefulWidget {
  final String? userId;
  final FirebaseFirestore? firestore;

  const FavoriteScreen({
    super.key,
    this.userId,
    this.firestore,
  });

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final int _selectedIndex = 2;

  String? get _currentUserId {
    if (widget.userId != null) return widget.userId;
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore get _firestore =>
      widget.firestore ?? FirebaseFirestore.instance;

  // ฟังก์ชันสลับสถานะรายการโปรดใน Firestore (ลบออกจาก sub-collection outfits)
  Future<void> _toggleFavorite(Outfit outfit) async {
    final uid = _currentUserId;
    if (uid == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('outfits')
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

  // แสดง Pop-up รายละเอียดลุค
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
                  Expanded(
                    child: Text(
                      outfit.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D2C24),
                      ),
                      overflow: TextOverflow.ellipsis,
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
                child: _buildOutfitImage(outfit.image),
              ),
              const SizedBox(height: 12),
              if (outfit.tags.isNotEmpty)
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
                          'รายการเสื้อผ้าในลุคนี้',
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

  // วิดเจ็ตสำหรับแสดงรูปภาพของชุด (รองรับทั้ง Network URL และ Asset ในเครื่อง)
  Widget _buildOutfitImage(
    String imagePath, {
    double height = 180,
    double width = double.infinity,
  }) {
    final trimmed = imagePath.trim();
    if (trimmed.isEmpty) {
      return _buildPlaceholderImage(
        height: height,
        width: width,
        message: 'ยังไม่มีรูปภาพ',
      );
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        height: height,
        width: width,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: width,
            color: const Color(0xFFE5DCD3),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(
          height: height,
          width: width,
          message: 'โหลดรูปไม่สำเร็จ (ตรวจสอบ URL)',
        ),
      );
    }

    // กรณีเป็น path assets ในเครื่อง เช่น assets/images/...
    return Image.asset(
      trimmed,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(
        height: height,
        width: width,
        message: 'ไม่พบไฟล์รูปในเครื่อง',
      ),
    );
  }

  // รูปสำรองเมื่อไม่มีรูปภาพหรือโหลดรูปไม่สำเร็จ
  Widget _buildPlaceholderImage({
    double height = 180,
    double width = double.infinity,
    String message = 'OutfitCheck',
  }) {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFFE5DCD3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.checkroom, size: 48, color: Color(0xFF7A6458)),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF7A6458),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentUserId;

    if (uid == null) {
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
        stream: _firestore
            .collection('users')
            .doc(uid)
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
          final favoritedOutfits =
              docs.map((doc) => Outfit.fromFirestore(doc)).toList();

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

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: favoritedOutfits.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ตู้เสื้อผ้า',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D2C24),
                      ),
                    ),
                    Text(
                      'สไตล์ที่คุณกดดาวไว้ (ซิงค์จาก Firebase)',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7A6458)),
                    ),
                    SizedBox(height: 16),
                  ],
                );
              }

              final outfit = favoritedOutfits[index - 1];

              return GestureDetector(
                onTap: () => _showOutfitDetail(outfit),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            _buildOutfitImage(outfit.image),
                            Positioned(
                              bottom: 12,
                              left: 16,
                              right: 60,
                              child: Text(
                                outfit.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black54,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
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
                                onPressed: () => _toggleFavorite(outfit),
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
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            i.icon,
                                            size: 18,
                                            color: const Color(0xFF7A6458),
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
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          } else if (index == 3) {
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
