import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/outfit_item.dart';
import '../services/ai_stylist_service.dart';

class AiStylistSheet extends StatefulWidget {
  final String initialPrompt;
  final String initialGender;
  final ValueChanged<OutfitItem>? onItemTap;

  const AiStylistSheet({
    super.key,
    this.initialPrompt = 'ชุดไปคาเฟ่',
    this.initialGender = 'ทั้งหมด',
    this.onItemTap,
  });

  static Future<void> show(
    BuildContext context, {
    String initialPrompt = 'ชุดไปคาเฟ่',
    String initialGender = 'ทั้งหมด',
    ValueChanged<OutfitItem>? onItemTap,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiStylistSheet(
        initialPrompt: initialPrompt,
        initialGender: initialGender,
        onItemTap: onItemTap,
      ),
    );
  }

  @override
  State<AiStylistSheet> createState() => _AiStylistSheetState();
}

class _AiStylistSheetState extends State<AiStylistSheet> {
  late TextEditingController _promptController;
  final ScrollController _itemsScrollController = ScrollController();
  bool _isLoading = true;
  AiStylistResult? _result;
  late String _selectedGender;

  final List<String> _quickPrompts = [
    'ชุดไปคาเฟ่',
    'สัมภาษณ์งาน',
    'ไปเดทวันเสาร์',
    'ไปเรียนมหาลัย',
    'เที่ยวทะเล',
    'สตรีทเท่ๆ',
  ];

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialGender;
    _promptController = TextEditingController(text: widget.initialPrompt);
    _requestAiAdvice(widget.initialPrompt);
  }

  @override
  void dispose() {
    _promptController.dispose();
    _itemsScrollController.dispose();
    super.dispose();
  }

  Future<void> _requestAiAdvice(String prompt, {String? gender}) async {
    final text = prompt.trim();
    if (text.isEmpty) return;

    final targetGender = gender ?? _selectedGender;

    setState(() {
      _isLoading = true;
      _selectedGender = targetGender;
    });

    final res = await AiStylistService.recommendOutfit(
      text,
      gender: targetGender,
    );

    if (mounted) {
      setState(() {
        _result = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F2EC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF382319),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFE8B87D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'AI Stylist แนะนำชุด',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C1E18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFAC5D3E).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Gemini AI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFAC5D3E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'วิเคราะห์สถานการณ์และเลือกแมตช์ชุดที่เหมาะที่สุด',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A7D75),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8A7D75)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search Input for Scenario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _promptController,
                textInputAction: TextInputAction.send,
                onSubmitted: _requestAiAdvice,
                style: const TextStyle(
                  color: Color(0xFF2C1E18),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'พิมพ์สถานการณ์ เช่น ชุดไปคาเฟ่, สัมภาษณ์งาน...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFA89F95),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFFAC5D3E),
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Color(0xFF382319),
                    ),
                    onPressed: () =>
                        _requestAiAdvice(_promptController.text),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Gender Selector Row for AI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildGenderToggle('ทั้งหมด', '✨ ทั้งหมด'),
                const SizedBox(width: 8),
                _buildGenderToggle('ชาย', '👨 ชาย'),
                const SizedBox(width: 8),
                _buildGenderToggle('หญิง', '👩 หญิง'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Quick Prompt Chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                final isSelected = _promptController.text.trim() == prompt;

                return GestureDetector(
                  onTap: () {
                    _promptController.text = prompt;
                    _requestAiAdvice(prompt);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF382319) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF382319)
                            : const Color(0xFFE2D7CC),
                      ),
                    ),
                    child: Text(
                      prompt,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : const Color(0xFF5C493E),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          const Divider(height: 1, color: Color(0xFFE5DDD5)),

          // Scrollable Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _result != null
                    ? _buildResultContent(_result!)
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF382319).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFFAC5D3E),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'AI Stylist กำลังวิเคราะห์สไตล์...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1E18),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'กำลังเลือกชุดที่แมตช์กับโอกาสของคุณจากตู้เสื้อผ้า',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8A7D75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent(AiStylistResult res) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Advice Card
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates_rounded,
                      color: Color(0xFFAC5D3E),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        res.styleVibe,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAC5D3E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  res.advice,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF2C1E18),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: res.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F2EC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7A685D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Title: Matched Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.checkroom_rounded,
                    size: 20,
                    color: Color(0xFF382319),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'เซ็ตชุดที่ AI แนะนำ (${res.recommendedItems.length} ชิ้น)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1E18),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'รวม ฿${_calculateTotal(res.recommendedItems)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFAC5D3E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ปุ่มเลื่อน ซ้าย - ขวา
                  InkWell(
                    onTap: () {
                      if (_itemsScrollController.hasClients) {
                        _itemsScrollController.animateTo(
                          (_itemsScrollController.offset - 160).clamp(
                            0.0,
                            _itemsScrollController.position.maxScrollExtent,
                          ),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDED5CC)),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        size: 18,
                        color: Color(0xFF382319),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      if (_itemsScrollController.hasClients) {
                        _itemsScrollController.animateTo(
                          (_itemsScrollController.offset + 160).clamp(
                            0.0,
                            _itemsScrollController.position.maxScrollExtent,
                          ),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDED5CC)),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF382319),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items Horizontal List (รองรับการลากด้วยเมาส์ และทัชสกรีน)
          SizedBox(
            height: 195,
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
                controller: _itemsScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: res.recommendedItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = res.recommendedItems[index];
                  return _buildMiniItemCard(item);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Button: Save entire set
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'บันทึกเซ็ต "${res.styleVibe}" (${res.recommendedItems.length} ชิ้น) ลงตู้เสื้อผ้าแล้ว! ✨',
                    ),
                    backgroundColor: const Color(0xFF382319),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.bookmark_add_rounded, color: Colors.white),
              label: const Text(
                'บันทึกทั้งเซ็ตนี้ลงตู้เสื้อผ้า',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  Widget _buildMiniItemCard(OutfitItem item) {
    return GestureDetector(
      onTap: () {
        if (widget.onItemTap != null) {
          widget.onItemTap!(item);
        }
      },
      child: Container(
        width: 135,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 1.15,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFEDE5DC),
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFF9E8E81),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFAC5D3E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C1E18),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.formattedPrice,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1E18),
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

  String _calculateTotal(List<OutfitItem> items) {
    final total = items.fold<int>(0, (sum, item) => sum + item.price);
    return total.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildGenderToggle(String value, String label) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _requestAiAdvice(_promptController.text, gender: value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF382319) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF382319)
                  : const Color(0xFFE2D7CC),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF5C493E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

