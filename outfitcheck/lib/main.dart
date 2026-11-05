import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

const _cream = Color(0xFFF6F0E8);
const _cocoa = Color(0xFF4A3326);
const _terracotta = Color(0xFFBC5732);
const _muted = Color(0xFF89796F);
const _softCream = Color(0xFFFAF6F0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OutfitCheck',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _terracotta,
          primary: _terracotta,
          surface: _cream,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showPieces = false;
  bool _isSaved = false;
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const _PhoneStatusBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildGreeting(),
                        const SizedBox(height: 14),
                        _buildOutfitCard(),
                        const SizedBox(height: 14),
                        _buildPlaceCard(),
                        const SizedBox(height: 14),
                        _buildMeasurementsCard(),
                        const SizedBox(height: 14),
                        _buildExploreCard(),
                      ],
                    ),
                  ),
                ),
                _buildBottomNavigation(),
                const _HomeIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'วันพฤหัสบดี, 24 กันยายน 2569',
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'สวัสดี, คุณสมชาย',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF261A14),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitCard() {
    return _HomeCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: _terracotta,
                size: 18,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'แนะนำชุดวันนี้',
                  style: TextStyle(
                    color: Color(0xFF261A14),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _ModeButton(
                label: 'รวม',
                selected: !_showPieces,
                onTap: () => setState(() => _showPieces = false),
              ),
              const SizedBox(width: 4),
              _ModeButton(
                label: 'ชิ้นส่วน',
                selected: _showPieces,
                onTap: () => setState(() => _showPieces = true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1516257984-b1b4d707412e?auto=format&fit=crop&w=600&q=80',
                    height: 168,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) =>
                        const _ImagePlaceholder(icon: Icons.checkroom),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 10,
                child: SizedBox(
                  height: 168,
                  child: Column(
                    children: [
                      const _OutfitItem(
                        icon: Icons.checkroom_outlined,
                        label: 'เสื้อคลุมยีนส์/แจ็คเก็ต',
                      ),
                      const SizedBox(height: 7),
                      const _OutfitItem(
                        icon: Icons.straighten,
                        label: 'Chinos สีกากี',
                      ),
                      const SizedBox(height: 7),
                      const _OutfitItem(
                        icon: Icons.hiking_outlined,
                        label: 'รองเท้า Loafer',
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                setState(() => _isSaved = !_isSaved),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 34,
                              minHeight: 34,
                            ),
                            icon: Icon(
                              _isSaved ? Icons.star : Icons.star_border,
                              color: _terracotta,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: SizedBox(
                              height: 34,
                              child: FilledButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "บันทึกชุด 'Urban Casual' แล้ว",
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: _terracotta,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: const Text('ช้อปชุดนี้'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard() {
    return _HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            icon: Icons.location_on_outlined,
            label: 'สถานที่แนะนำวันนี้',
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _ImagePlaceholder(icon: Icons.local_cafe),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x99000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 9,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Text(
                        "คาเฟ่ 'The Glasshouse'",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'เหมาะกับชุด Urban Casual ของคุณในวันนี้',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsCard() {
    return _HomeCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: _terracotta, size: 19),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'สัดส่วนของคุณ',
                  style: TextStyle(
                    color: Color(0xFF261A14),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showMeasurementDialog(context),
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('แก้ไข'),
                style: TextButton.styleFrom(
                  foregroundColor: _muted,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(
                child: _MeasurementTile(label: 'ส่วนสูง', value: '175 ซม.'),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _MeasurementTile(label: 'รอบเอว', value: '32 นิ้ว'),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _MeasurementTile(label: 'น้ำหนัก', value: '68 กก.'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExploreCard() {
    return Material(
      color: _cocoa,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => setState(() => _selectedTab = 1),
        borderRadius: BorderRadius.circular(14),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white, size: 19),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'ค้นหาเสื้อผ้า & สไตล์',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'สำรวจคอลเลกชัน',
                style: TextStyle(color: Color(0xFFC9B8AC), fontSize: 10),
              ),
              SizedBox(width: 3),
              Icon(Icons.chevron_right, color: Color(0xFFC9B8AC), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    const tabs = [
      (Icons.home_filled, 'หน้าแรก'),
      (Icons.search, 'ค้นหา'),
      (Icons.checkroom_outlined, 'ตู้เสื้อผ้า'),
      (Icons.person_outline, 'โปรไฟล์'),
    ];

    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: const BoxDecoration(
        color: _cocoa,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final (icon, label) = tabs[index];
          final selected = _selectedTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              borderRadius: BorderRadius.circular(13),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF604636)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: selected ? Colors.white : const Color(0xFFB5A69D),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFFB5A69D),
                        fontSize: 9,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _showMeasurementDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('สัดส่วนของคุณ'),
        content: const Text(
          'ส่วนสูง 175 ซม. · รอบเอว 32 นิ้ว · น้ำหนัก 68 กก.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}

class _PhoneStatusBar extends StatelessWidget {
  const _PhoneStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      color: _cocoa,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          const SizedBox(
            width: 48,
            child: Text(
              '9:41',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 96,
                height: 25,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(right: 13),
                    decoration: const BoxDecoration(
                      color: Color(0xFF17233A),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.wifi, color: Colors.white, size: 13),
                SizedBox(width: 5),
                Icon(Icons.battery_full, color: Colors.white, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2F2018),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _terracotta, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF261A14),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _cocoa : _softCream,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _muted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OutfitItem extends StatelessWidget {
  const _OutfitItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _softCream,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(icon, color: _cocoa, size: 15),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF49382E), fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementTile extends StatelessWidget {
  const _MeasurementTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
      decoration: BoxDecoration(
        color: _softCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF261A14),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9DFD3),
      alignment: Alignment.center,
      child: Icon(icon, size: 38, color: _muted),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      color: _cocoa,
      alignment: Alignment.center,
      child: Container(
        width: 90,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
