import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/mock_outfits.dart';
import '../models/outfit_item.dart';
import '../widgets/ai_stylist_sheet.dart';
import '../widgets/outfit_card.dart';
import '../services/local_database_service.dart';
import 'favorite.dart' hide OutfitItem;
import 'profile_screen.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// [SearchScreen] - หน้าค้นหาเสื้อผ้าและสไตล์ (Outfit Search Screen)
/// ออกแบบตาม Design System ใน Figma โครงการ OutfitCheck
/// รองรับระบบ AI Stylist แนะนำชุดตามโอกาสและสถานการณ์
class SearchScreen extends StatefulWidget {
  /// สามารถกำหนดหมวดหมู่เริ่มต้นได้ เช่น เมื่อกดมาจากหน้าแรก (ค่าเริ่มต้นคือ 'ทั้งหมด')
  final String initialCategory;

  /// Callback เมื่อผู้ใช้แตะที่การ์ดสินค้า เพื่อให้เพื่อนเปิดหน้า Detail ของเพื่อนได้
  /// หากไม่ส่งค่ามา จะเปิด Bottom Sheet แสดงรายละเอียดในตัวให้อัตโนมัติ
  final ValueChanged<OutfitItem>? onItemTap;

  const SearchScreen({
    super.key,
    this.initialCategory = 'ทั้งหมด',
    this.onItemTap,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<String> _categories = [
    'ทั้งหมด',
    'เสื้อ',
    'กางเกง',
    'รองเท้า',
    'กระเป๋า',
  ];

  /// แท็กคำค้นหายอดนิยม (Suggested Quick Tags)
  final List<String> _popularTags = [
    'เสื้อ Oversized',
    'Minimal',
    'Streetwear',
    'รองเท้า Loafer',
    'กระเป๋าหนัง',
    'Chinos',
  ];

  /// สถานการณ์ยอดนิยมสำหรับ AI Stylist
  final List<Map<String, String>> _aiScenarios = [
    {'label': '☕ ชุดไปคาเฟ่', 'query': 'ชุดไปคาเฟ่'},
    {'label': '💼 สัมภาษณ์งาน', 'query': 'สัมภาษณ์งาน'},
    {'label': '🍿 ไปเดทวันเสาร์', 'query': 'ไปเดทวันเสาร์'},
    {'label': '🎓 ไปเรียนมหาลัย', 'query': 'ไปเรียนมหาลัย'},
    {'label': '🌴 เที่ยวทะเล', 'query': 'เที่ยวทะเล'},
    {'label': '⛰️ แคมป์ปิ้งเขาใหญ่', 'query': 'แคมป์ปิ้งเขาใหญ่'},
    {'label': '🛍️ เดินสยาม/ห้าง', 'query': 'เดินสยาม/ห้าง'},
    {'label': '🙏 ไปวัดทำบุญ', 'query': 'ไปวัดทำบุญ'},
    {'label': '🎸 ไปดูคอนเสิร์ต', 'query': 'ไปดูคอนเสิร์ต'},
    {'label': '💍 ไปงานแต่งงาน', 'query': 'ไปงานแต่งงาน'},
    {'label': '🕶️ สตรีทเท่ๆ', 'query': 'สตรีทเท่ๆ'},
  ];

  late String _selectedCategory;
  String _selectedGender = 'ทั้งหมด'; // 'ทั้งหมด', 'ชาย', 'หญิง'
  String _searchQuery = '';
  bool _isFocused = false;

  /// ประวัติการค้นหาล่าสุด (Recent Searches) สูงสุด 8 รายการ
  final List<String> _recentSearches = [];
  static const int _maxRecentSearches = 8;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _searchFocusNode.addListener(() {
      setState(() {
        _isFocused = _searchFocusNode.hasFocus;
      });
    });
    _loadRecentSearches();
  }

  /// โหลดประวัติการค้นหาจาก Local SQLite Database
  Future<void> _loadRecentSearches() async {
    try {
      final saved = await LocalDatabaseService.instance.getRecentSearches(
        limit: _maxRecentSearches,
      );
      if (saved.isNotEmpty && mounted) {
        setState(() {
          _recentSearches.clear();
          _recentSearches.addAll(saved);
        });
      }
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<OutfitItem> get _filteredItems {
    return mockOutfits.where((item) {
      final matchesCategory = _selectedCategory == 'ทั้งหมด' ||
          item.category.trim() == _selectedCategory.trim();
      final matchesGender = _selectedGender == 'ทั้งหมด' ||
          item.gender == 'Unisex' ||
          item.gender == _selectedGender;
      final matchesQuery = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.gender.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesGender && matchesQuery;
    }).toList();
  }

  /// เปิดหน้าต่าง AI Stylist แนะนำชุด
  void _openAiStylist([String? prompt]) {
    _searchFocusNode.unfocus();
    final queryText = prompt ??
        (_searchQuery.isNotEmpty ? _searchQuery : 'ชุดไปคาเฟ่');

    AiStylistSheet.show(
      context,
      initialPrompt: queryText,
      initialGender: _selectedGender,
      onItemTap: (item) => _handleItemTap(item),
    );
  }

  /// บันทึกคำค้นหาลงประวัติ (ทั้ง State และ Local SQLite Database)
  void _saveToRecentSearches(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _recentSearches.remove(trimmed);
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches.removeLast();
      }
    });

    // บันทึกลง SQLite Database แบบถาวร
    try {
      LocalDatabaseService.instance.insertSearch(
        trimmed,
        maxLimit: _maxRecentSearches,
      );
    } catch (e) {
      debugPrint('Error saving search to SQLite: $e');
    }
  }

  /// ทำการค้นหาจากคำที่กำหนด
  void _performSearch(String query) {
    final trimmed = query.trim();
    _searchController.text = trimmed;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: trimmed.length),
    );
    setState(() {
      _searchQuery = trimmed;
      _isFocused = false;
    });
    _searchFocusNode.unfocus();
    if (trimmed.isNotEmpty) {
      _saveToRecentSearches(trimmed);

      // ถ้าเป็นคำเกี่ยวกับสถานการณ์ แนะนำให้เปิด AI
      final lower = trimmed.toLowerCase();
      if (lower.contains('คาเฟ่') ||
          lower.contains('สัมภาษณ์') ||
          lower.contains('เดท') ||
          lower.contains('ทะเล') ||
          lower.contains('เรียน') ||
          lower.contains('สตรีท')) {
        _openAiStylist(trimmed);
      }
    }
  }

  void _removeRecentSearch(String query) {
    setState(() {
      _recentSearches.remove(query);
    });
    try {
      LocalDatabaseService.instance.deleteSearch(query);
    } catch (e) {
      debugPrint('Error deleting search from SQLite: $e');
    }
  }

  void _clearAllRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
    try {
      LocalDatabaseService.instance.clearAllSearches();
    } catch (e) {
      debugPrint('Error clearing searches from SQLite: $e');
    }
  }

  void _handleItemTap(OutfitItem item) {
    if (widget.onItemTap != null) {
      widget.onItemTap!(item);
    } else {
      _showItemDetails(item);
    }
  }

  Future<void> _addToWardrobe(OutfitItem item) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณาเข้าสู่ระบบก่อนเพิ่มเสื้อผ้าลงตู้เสื้อผ้า'),
            backgroundColor: Color(0xFFAC5D3E),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('outfits')
          .add({
        'title': item.title,
        'outfitName': item.title,
        'image': item.imageUrl,
        'imageUrl': item.imageUrl,
        'category': item.category,
        'tags': [item.category, item.gender],
        'price': item.price,
        'isFavorite': true,
        'items': [
          {
            'text': '${item.category}: ${item.title}',
            'itemImage': item.imageUrl,
          }
        ],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เพิ่ม "${item.title}" ลงตู้เสื้อผ้าแล้ว! ✨'),
          backgroundColor: const Color(0xFF382319),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถบันทึกลงตู้เสื้อผ้าได้: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showItemDetails(OutfitItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F2EC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1.3,
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAC5D3E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        color: Color(0xFFAC5D3E),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    item.formattedPrice,
                    style: const TextStyle(
                      color: Color(0xFF2C1E18),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: const TextStyle(
                  color: Color(0xFF2C1E18),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  item.description!,
                  style: const TextStyle(
                    color: Color(0xFF6E5D53),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _addToWardrobe(item);
                  },
                  icon: const Icon(Icons.checkroom, color: Colors.white),
                  label: const Text(
                    'เพิ่มลงตู้เสื้อผ้า',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF382319),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final bool showSearchSuggestions = _searchQuery.isEmpty && _isFocused;

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F2EC),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top Section: Title + Search Bar + AI Stylist Banner ───
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (Navigator.canPop(context)) ...[
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.brown.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 18,
                                    color: Color(0xFF2C1E18),
                                  ),
                                ),
                              ),
                            ],
                            const Text(
                              'ค้นหา',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C1E18),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        // ปุ่มลัด AI Stylist
                        GestureDetector(
                          onTap: () => _openAiStylist(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFAC5D3E).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFAC5D3E).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: Color(0xFFAC5D3E),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'AI Stylist',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFAC5D3E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim();
                          });
                        },
                        onSubmitted: (value) => _performSearch(value),
                        style: const TextStyle(
                          color: Color(0xFF2C1E18),
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ค้นหาเสื้อผ้า, สไตล์ หรือบอก AI...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFA89F95),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF9E8E81),
                            size: 22,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Color(0xFF9E8E81),
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _isFocused = true;
                                    });
                                    _searchFocusNode.requestFocus();
                                  },
                                )
                              : IconButton(
                                  tooltip: 'ถาม AI Stylist',
                                  icon: const Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFFAC5D3E),
                                    size: 20,
                                  ),
                                  onPressed: () => _openAiStylist(),
                                ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    // AI Stylist Banner Card
                    GestureDetector(
                      onTap: () => _openAiStylist(
                          _searchQuery.isNotEmpty ? _searchQuery : 'ชุดไปคาเฟ่'),
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF382319),
                              Color(0xFF4A3124),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF382319).withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFAC5D3E).withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFFF7C896),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '✨ Gemini AI แนะนำชุดตามโอกาส',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'บอกสถานการณ์ เช่น "ชุดไปคาเฟ่" ให้ AI จัดเซ็ตให้',
                                    style: TextStyle(
                                      color: Color(0xFFD6C8BC),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFAC5D3E),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'ถาม AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Expanded Area: Suggestions หรือ Category + Grid ───
              Expanded(
                child: showSearchSuggestions
                    ? _buildSearchSuggestions()
                    : Column(
                        children: [
                          // Gender Selector Segmented Control
                          _buildGenderSelector(),
                          const SizedBox(height: 10),
                          // Category Filter Chips
                          _buildCategoryChips(),
                          const SizedBox(height: 14),
                          // Product Grid or Empty State
                          Expanded(
                            child: filtered.isEmpty
                                ? _buildEmptyState()
                                : _buildGrid(filtered),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
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
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: หน้าแสดงประวัติค้นหา + AI Scenarios + แท็กยอดนิยม
  // ─────────────────────────────────────────────
  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── AI Situations Section ──
          Row(
            children: const [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: Color(0xFFAC5D3E),
              ),
              SizedBox(width: 6),
              Text(
                'ให้ AI แนะนำตามสถานการณ์',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1E18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _aiScenarios.map((item) {
              return GestureDetector(
                onTap: () => _openAiStylist(item['query']),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAC5D3E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFAC5D3E).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    item['label']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF382319),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Recent Searches Section ──
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ค้นหาล่าสุด',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1E18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF382319).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.storage,
                              size: 10, color: Color(0xFF7A6458)),
                          SizedBox(width: 3),
                          Text(
                            'SQLite',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A6458),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _clearAllRecentSearches,
                  child: const Text(
                    'ล้างทั้งหมด',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFAC5D3E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(_recentSearches.length, (index) {
              final query = _recentSearches[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE5DC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.history,
                      size: 18,
                      color: Color(0xFF8A7360),
                    ),
                  ),
                  title: Text(
                    query,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C1E18),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFFA89F95),
                    ),
                    onPressed: () => _removeRecentSearch(query),
                  ),
                  onTap: () => _performSearch(query),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(
              color: Color(0xFFE5DDD5),
              thickness: 1,
            ),
            const SizedBox(height: 16),
          ],

          // ── Popular Tags Section ──
          Row(
            children: const [
              Icon(
                Icons.local_fire_department_rounded,
                size: 18,
                color: Color(0xFFAC5D3E),
              ),
              SizedBox(width: 6),
              Text(
                'ค้นหายอดนิยม',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1E18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularTags.map((tag) {
              return GestureDetector(
                onTap: () => _performSearch(tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE0D6CC),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        size: 14,
                        color: Color(0xFFAC5D3E),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2C1E18),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: ตัวเลือกเพศ (Gender Selector: ทั้งหมด, ชาย, หญิง)
  // ─────────────────────────────────────────────
  Widget _buildGenderSelector() {
    final genders = [
      {'label': 'ทั้งหมด', 'icon': Icons.all_inclusive_rounded},
      {'label': 'ชาย', 'icon': Icons.man_rounded},
      {'label': 'หญิง', 'icon': Icons.woman_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFEFE8DF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: genders.map((g) {
            final label = g['label'] as String;
            final icon = g['icon'] as IconData;
            final isSelected = _selectedGender == label;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = label;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected
                            ? const Color(0xFF382319)
                            : const Color(0xFF8A7D75),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        label == 'ทั้งหมด'
                            ? 'ทั้งหมด'
                            : (label == 'ชาย' ? 'ผู้ชาย' : 'ผู้หญิง'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF382319)
                              : const Color(0xFF8A7D75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: Category Filter Chips (แนวนอน - รองรับการลากด้วยเมาส์ และทัชสกรีน)
  // ─────────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = category == _selectedCategory;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF382319) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF382319),
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: Product Grid
  // ─────────────────────────────────────────────
  Widget _buildGrid(List<OutfitItem> items) {
    return GridView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.67, // ปรับให้สูงขึ้นเพื่อป้องกัน overflow 100%
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return OutfitCard(
          item: item,
          onTap: () => _handleItemTap(item),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Widget: Empty State (ไม่พบผลการค้นหา)
  // ─────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.brown.shade200,
          ),
          const SizedBox(height: 12),
          const Text(
            'ไม่พบเสื้อผ้าที่ค้นหา',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6E5D53),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ลองค้นหาด้วยคำอื่น หรือเลือกหมวดหมู่อื่นดูนะ',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFA89F95),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openAiStylist(_searchQuery),
            icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            label: const Text(
              'ให้ AI ช่วยแนะนำชุดตามคำนี้',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF382319),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
