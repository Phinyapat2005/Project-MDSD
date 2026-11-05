import 'package:flutter/material.dart';

void main() {
  runApp(const OutfitCheckApp());
}

class OutfitCheckApp extends StatelessWidget {
  const OutfitCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OutfitCheck',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5EFE6),
        primaryColor: const Color(0xFF3D2C24),
      ),
      home: const WardrobeScreen(),
    );
  }
}

// โมเดลข้อมูลรายการเสื้อผ้า
class OutfitItem {
  final String text;
  final IconData icon;
  final String itemImage;

  OutfitItem({required this.text, required this.icon, required this.itemImage});
}

// โมเดลข้อมูลชุดแต่งตัว
class Outfit {
  final int id;
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
    this.isFavorite = false,
    required this.items,
  });
}

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  // ข้อมูลตัวอย่าง outfits
  final List<Outfit> outfits = [
    Outfit(
      id: 1,
      title: 'ลุค Urban Casual',
      image: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=600&auto=format&fit=crop',
      tags: ['Casual', 'Office'],
      isFavorite: true,
      items: [
        OutfitItem(text: 'เสื้อคลุมยีนส์', icon: Icons.checkroom, itemImage: 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?q=80&w=500&auto=format&fit=crop'),
        OutfitItem(text: 'Chinos สีกากี', icon: Icons.content_cut, itemImage: 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?q=80&w=500&auto=format&fit=crop'),
        OutfitItem(text: 'รองเท้า Loafer', icon: Icons.nordic_walking, itemImage: 'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?q=80&w=500&auto=format&fit=crop'),
      ],
    ),
    Outfit(
      id: 2,
      title: 'ลุค Soft Beige',
      image: 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?q=80&w=600&auto=format&fit=crop',
      tags: ['Minimal', 'Weekend'],
      isFavorite: true,
      items: [
        OutfitItem(text: 'เสื้อ Linen ครีม', icon: Icons.checkroom, itemImage: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?q=80&w=500&auto=format&fit=crop'),
        OutfitItem(text: 'กางเกงผ้า Wide Leg', icon: Icons.content_cut, itemImage: 'https://images.unsplash.com/photo-1509551388413-e18d0ac5d495?q=80&w=500&auto=format&fit=crop'),
        OutfitItem(text: 'รองเท้า Mule', icon: Icons.nordic_walking, itemImage: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?q=80&w=500&auto=format&fit=crop'),
      ],
    ),
    Outfit(
      id: 3,
      title: 'ลุค Smart Casual',
      image: 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?q=80&w=600&auto=format&fit=crop',
      tags: ['Smart', 'Work'],
      isFavorite: false,
      items: [
        OutfitItem(text: 'เสื้อเชิ้ตขาว', icon: Icons.checkroom, itemImage: 'https://images.unsplash.com/photo-1621072156002-e2fccdc0b176?q=80&w=500&auto=format&fit=crop'),
        OutfitItem(text: 'กางเกงสแล็คสีกรม', icon: Icons.content_cut, itemImage: 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?q=80&w=500&auto=format&fit=crop'),
        OutfitItem(text: 'รองเท้าหนัง Derby', icon: Icons.nordic_walking, itemImage: 'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?q=80&w=500&auto=format&fit=crop'),
      ],
    ),
  ];

  int _selectedIndex = 2; // แท็บตู้เสื้อผ้าเป็นหลัก

  // ฟังก์ชันสลับสถานะรายการโปรด
  void _toggleFavorite(Outfit outfit) {
    setState(() {
      outfit.isFavorite = !outfit.isFavorite;
    });
  }

  // แสดง Modal รายละเอียดลุค
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
              // Header Modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    outfit.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3D2C24)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF7A6458)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              // รูปภาพหลัก
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(outfit.image, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              // Tags
              Wrap(
                spacing: 8,
                children: outfit.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5DCD3)),
                  ),
                  child: Text(tag, style: const TextStyle(fontSize: 12, color: Color(0xFF7A6458))),
                )).toList(),
              ),
              const SizedBox(height: 16),
              // รายการเสื้อผ้า
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
                        const Text('รายการเสื้อผ้าในลุคนี้ (กดเพื่อดูรูป)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3D2C24))),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: outfit.items.length,
                            itemBuilder: (context, index) {
                              final item = outfit.items[index];
                              return ListTile(
                                leading: Icon(item.icon, color: const Color(0xFF7A6458)),
                                title: Text(item.text, style: const TextStyle(color: Color(0xFF4A3B32), fontWeight: FontWeight.w500)),
                                trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF7A6458)),
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

  // แสดง Dialog รูปสินค้าชิ้นเดี่ยว (แก้จุดเกิด RenderPhysicalShape / child!.hasSize error แล้ว)
  void _showItemSubModal(OutfitItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(item.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    child: Image.network(item.itemImage, fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ตกลง', style: TextStyle(color: Color(0xFF3D2C24))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritedOutfits = outfits.where((o) => o.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D2C24),
        title: const Text('OutfitCheck', style: TextStyle(color: Color(0xFFF5EFE6), fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 2,
      ),
      body: CustomScrollView(
        slivers: [
          // Section 1: หัวข้อ และ สไตล์ที่กดดาวไว้
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ตู้เสื้อผ้า', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3D2C24))),
                  const Text('สไตล์ที่คุณกดดาวไว้', style: TextStyle(fontSize: 12, color: Color(0xFF7A6458))),
                  const SizedBox(height: 16),
                  
                  ...favoritedOutfits.map((outfit) => GestureDetector(
                    onTap: () => _showOutfitDetail(outfit),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Image.network(outfit.image, height: 180, width: double.infinity, fit: BoxFit.cover),
                              Positioned(
                                bottom: 12,
                                left: 16,
                                child: Text(outfit.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: IconButton(
                                  icon: const Icon(Icons.star, color: Colors.orange),
                                  onPressed: () => _toggleFavorite(outfit),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: outfit.items.map((i) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(i.icon, size: 18, color: const Color(0xFF7A6458)),
                                    const SizedBox(width: 8),
                                    Text(i.text, style: const TextStyle(color: Color(0xFF4A3B32))),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

                  const SizedBox(height: 10),
                  const Text('สไตล์ทั้งหมด', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3D2C24))),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Section 2: สไตล์ทั้งหมด
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final outfit = outfits[index];
                  return GestureDetector(
                    onTap: () => _showOutfitDetail(outfit),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 130,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                Image.network(
                                  outfit.image, 
                                  width: double.infinity, 
                                  height: double.infinity, 
                                  fit: BoxFit.cover
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: () => _toggleFavorite(outfit),
                                    child: Icon(
                                      outfit.isFavorite ? Icons.star : Icons.star_border,
                                      color: outfit.isFavorite ? Colors.orange : Colors.grey,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              outfit.title, 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3D2C24)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: outfits.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 60),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFF3D2C24),
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFFC4B2A9),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'ค้นหา'),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'ตู้เสื้อผ้า'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}