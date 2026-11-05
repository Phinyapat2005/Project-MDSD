import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/ai_stylist_sheet.dart';
import 'search_screen.dart';
import 'favorite.dart';
import 'profile_screen.dart';

/// [HomeScreen] - หน้าแรกของแอปพลิเคชัน OutfitCheck
/// แปลงและปรับปรุงจาก React component ใน `src/components/HomeScreen.tsx`
/// แสดงชุดแนะนำประจำวัน, สถานที่แนะนำ, สัดส่วนของผู้ใช้ และทางลัดค้นหาสไตล์
class HomeScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;

  const HomeScreen({
    super.key,
    this.userId,
    this.userName,
    this.firestore,
    this.auth,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // สลับโหมดการแสดงผลชุด: 'combined' (รวม) หรือ 'pieces' (ชิ้นส่วน)
  String _viewMode = 'combined';
  bool _isSaved = false;
  final int _selectedIndex = 0;

  String? get _currentUserId {
    if (widget.userId != null) return widget.userId;
    try {
      return (widget.auth ?? FirebaseAuth.instance).currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    if (widget.firestore != null) return widget.firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // ฟังก์ชันแปลงวันที่ปัจจุบันเป็นภาษาไทยแบบสวยงาม
  String _getThaiFormattedDate() {
    final now = DateTime.now();
    const thaiDays = [
      'วันจันทร์',
      'วันอังคาร',
      'วันพุธ',
      'วันพฤหัสบดี',
      'วันศุกร์',
      'วันเสาร์',
      'วันอาทิตย์'
    ];
    const thaiMonths = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];

    final dayName = thaiDays[now.weekday - 1];
    final dayNum = now.day;
    final monthName = thaiMonths[now.month - 1];
    final year = now.year + 543; // แปลง ค.ศ. เป็น พ.ศ.

    return '$dayName, $dayNum $monthName $year';
  }

  // บันทึกชุด Urban Casual ลงตู้เสื้อผ้าใน Cloud Firestore
  Future<void> _handleShopOutfit() async {
    setState(() => _isSaved = true);

    final uid = _currentUserId;
    final db = _firestore;
    if (uid != null && db != null) {
      try {
        await db.collection('users').doc(uid).collection('outfits').add({
          'title': 'Urban Casual',
          'image':
              'https://images.unsplash.com/photo-1516257984-b1b4d707412e?auto=format&fit=crop&w=600&q=80',
          'tags': ['#UrbanCasual', '#EverydayStyle', '#ช้อปชุดนี้', '#ชุดแนะนำวันนี้'],
          'isFavorite': true,
          'createdAt': FieldValue.serverTimestamp(),
          'items': [
            {
              'name': 'เสื้อคลุมยีนส์ Oversized',
              'title': 'เสื้อคลุมยีนส์ Oversized',
              'price': 1290,
              'category': 'เสื้อ',
              'itemImage':
                  'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?auto=format&fit=crop&w=600&q=80',
            },
            {
              'name': 'Chinos สีกากี Slim Fit',
              'title': 'Chinos สีกากี Slim Fit',
              'price': 990,
              'category': 'กางเกง',
              'itemImage':
                  'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=600&q=80',
            },
            {
              'name': 'รองเท้า Loafer หนังแท้สีน้ำตาล',
              'title': 'รองเท้า Loafer หนังแท้สีน้ำตาล',
              'price': 2590,
              'category': 'รองเท้า',
              'itemImage':
                  'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?auto=format&fit=crop&w=600&q=80',
            },
          ],
        });
      } catch (e) {
        debugPrint('Firestore save outfit error: $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.checkroom, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '✨ บันทึกชุด \'Urban Casual\' ลงในตู้เสื้อผ้าแล้ว!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF3D2C24),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // หน้าต่าง Pop-up แก้ไขสัดส่วนร่างกาย
  Future<void> _showEditMeasurementsDialog(
    String userId,
    String height,
    String waist,
    String weight,
  ) async {
    final heightController = TextEditingController(
      text: height == '-' ? '' : height,
    );
    final waistController = TextEditingController(
      text: waist == '-' ? '' : waist,
    );
    final weightController = TextEditingController(
      text: weight == '-' ? '' : weight,
    );

    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  color: const Color(0xFF3D2C24),
                  child: const Text(
                    'แก้ไขสัดส่วนร่างกาย',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'ส่วนสูง (ซม.)',
                          hintText: 'เช่น 175',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.height),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: waistController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'รอบเอว (นิ้ว)',
                          hintText: 'เช่น 32',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.straighten),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'น้ำหนัก (กก.)',
                          hintText: 'เช่น 68',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.scale),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('ยกเลิก'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFAC5D3E),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                final h = heightController.text.trim();
                                final w = waistController.text.trim();
                                final wt = weightController.text.trim();

                                final db = _firestore;
                                if (db != null) {
                                  await db.collection('users').doc(userId).set({
                                    'height': h.isEmpty ? '175' : h,
                                    'waist': w.isEmpty ? '32' : w,
                                    'weight': wt.isEmpty ? '68' : wt,
                                  }, SetOptions(merge: true));
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text(
                                'บันทึก',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // เปิด AI Stylist Bottom Sheet สำหรับสถานที่แนะนำ
  void _openAiStylistForPlace(String placeScenario) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiStylistSheet(
        initialPrompt: placeScenario,
        initialGender: 'ทั้งหมด',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentUserId;
    final db = _firestore;

    if (uid != null && db != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F2EC),
        body: StreamBuilder<DocumentSnapshot>(
          stream: db.collection('users').doc(uid).snapshots(),
          builder: (context, snapshot) {
            String userName = widget.userName ?? 'สมชาย ใจดี';
            String height = '175';
            String weight = '68';
            String waist = '32';

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              if (data != null) {
                if (data['name'] != null && data['name'].toString().isNotEmpty) {
                  userName = data['name'].toString();
                }
                if (data['height'] != null && data['height'].toString().isNotEmpty) {
                  height = data['height'].toString();
                }
                if (data['weight'] != null && data['weight'].toString().isNotEmpty) {
                  weight = data['weight'].toString();
                }
                if (data['waist'] != null && data['waist'].toString().isNotEmpty) {
                  waist = data['waist'].toString();
                }
              }
            }

            return SafeArea(
              child: _buildBodyContent(uid, userName, height, waist, weight),
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    // กรณีออฟไลน์ หรือยังไม่ได้ล็อกอิน ให้แสดงผลด้วยข้อมูลพื้นฐาน
    final fallbackName = widget.userName ?? 'สมชาย ใจดี';
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      body: SafeArea(
        child: _buildBodyContent('guest', fallbackName, '175', '32', '68'),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBodyContent(
    String uid,
    String userName,
    String height,
    String waist,
    String weight,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: วันที่ & คำทักทาย ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getThaiFormattedDate(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF847367),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'สวัสดี, $userName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1E18),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Card 1: แนะนำชุดวันนี้ (Today's Outfit) ───
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE8DFD8).withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // หัวการ์ดและปุ่มสลับ รวม / ชิ้นส่วน
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Color(0xFFAC5D3E),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'แนะนำชุดวันนี้',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFAC5D3E),
                          ),
                        ),
                      ],
                    ),

                    // Toggle รวม / ชิ้นส่วน
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F2EC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildToggleButton(
                            label: 'รวม',
                            isActive: _viewMode == 'combined',
                            onTap: () => setState(() => _viewMode = 'combined'),
                          ),
                          _buildToggleButton(
                            label: 'ชิ้นส่วน',
                            isActive: _viewMode == 'pieces',
                            onTap: () => setState(() => _viewMode = 'pieces'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // เนื้อหาตาม ViewMode
                if (_viewMode == 'combined')
                  _buildCombinedView()
                else
                  _buildPiecesView(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Card 2: สถานที่แนะนำวันนี้ (Place Recommendation) ───
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE8DFD8).withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: Color(0xFFAC5D3E),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'สถานที่แนะนำวันนี้',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFAC5D3E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // แบนเนอร์ภาพสถานที่
                GestureDetector(
                  onTap: () => _openAiStylistForPlace(
                    'ไปคาเฟ่ The Glasshouse บรรยากาศกลาสเฮ้าส์อบอุ่น',
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 130,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        // Gradient Overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // ป้ายแท็กชื่อสถานที่
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.coffee,
                                  size: 14,
                                  color: Color(0xFFF6D89E),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'คาเฟ่ \'The Glasshouse\'',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'เหมาะกับชุด Urban Casual ของคุณในวันนี้ (แตะเพื่อดูคำแนะนำสไตล์ลิสต์)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF847367),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Card 3: สัดส่วนของคุณ (Your Measurements) ───
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE8DFD8).withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('👤', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text(
                          'สัดส่วนของคุณ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C1E18),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => _showEditMeasurementsDialog(
                        uid,
                        height,
                        waist,
                        weight,
                      ),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: Color(0xFF847367),
                      ),
                      label: const Text(
                        'แก้ไข',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF847367),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 3 Metric Cards (ส่วนสูง, รอบเอว, น้ำหนัก)
                Row(
                  children: [
                    _buildMeasurementBox('ส่วนสูง', height, 'ซม.'),
                    const SizedBox(width: 10),
                    _buildMeasurementBox('รอบเอว', waist, 'นิ้ว'),
                    const SizedBox(width: 10),
                    _buildMeasurementBox('น้ำหนัก', weight, 'กก.'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Card 4: ค้นหาเสื้อผ้า & สไตล์ (Explore Collections) ───
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF3D2C24),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3D2C24).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFFEBDDCF),
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'ค้นหาเสื้อผ้า & สไตล์',
                        style: TextStyle(
                          color: Color(0xFFF5EFE9),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        'สำรวจคอลเลกชัน',
                        style: TextStyle(
                          color: Color(0xFFA69488),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: Color(0xFFA69488),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (index == _selectedIndex) return;
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FavoriteScreen()),
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
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3D2C24) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF847367),
          ),
        ),
      ),
    );
  }

  // มุมมอง "รวม" (Combined View)
  Widget _buildCombinedView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // รูปถ่ายนางแบบ/นายแบบ
        Expanded(
          flex: 5,
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1516257984-b1b4d707412e?auto=format&fit=crop&w=600&q=80',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Urban Casual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // รายการชิ้นเสื้อผ้า + ปุ่มช้อป
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGarmentMiniChip('👕', 'เสื้อคลุมยีนส์/แจ็คเก็ต'),
              const SizedBox(height: 6),
              _buildGarmentMiniChip('👖', 'Chinos สีกากี'),
              const SizedBox(height: 6),
              _buildGarmentMiniChip('👞', 'รองเท้า Loafer'),
              const SizedBox(height: 12),

              // ปุ่ม Favorite & ช้อปชุดนี้
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F2EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isSaved ? Icons.star : Icons.star_border,
                        color: const Color(0xFFAC5D3E),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isSaved = !_isSaved),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAC5D3E),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _handleShopOutfit,
                      child: const Text(
                        'ช้อปชุดนี้',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGarmentMiniChip(String emoji, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8DFD8).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C1E18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // มุมมอง "ชิ้นส่วน" (Pieces View)
  Widget _buildPiecesView() {
    return Column(
      children: [
        _buildPieceItem(
          title: 'เสื้อคลุมยีนส์ Oversized',
          price: '฿1,290',
          imageUrl:
              'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?auto=format&fit=crop&w=200&q=80',
          category: 'เสื้อ',
        ),
        const SizedBox(height: 8),
        _buildPieceItem(
          title: 'Chinos สีกากี Slim Fit',
          price: '฿990',
          imageUrl:
              'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=200&q=80',
          category: 'กางเกง',
        ),
        const SizedBox(height: 8),
        _buildPieceItem(
          title: 'รองเท้า Loafer หนังแท้',
          price: '฿2,590',
          imageUrl:
              'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?auto=format&fit=crop&w=200&q=80',
          category: 'รองเท้า',
        ),
      ],
    );
  }

  Widget _buildPieceItem({
    required String title,
    required String price,
    required String imageUrl,
    required String category,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(initialCategory: category),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE8DFD8).withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1E18),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFAC5D3E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFF847367),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementBox(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8DFD8).withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF847367),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1E18),
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF847367),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
