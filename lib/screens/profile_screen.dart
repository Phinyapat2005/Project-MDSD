import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';
import 'favorite.dart';
import 'screens/search_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedIndex = 3;

  Future<void> _signOut() async {
    final navigator = Navigator.of(context);
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // ฟังก์ชันแสดงหน้าต่าง Popup สำหรับแก้ไขข้อมูล
  Future<void> _showEditDialog(
    String userId,
    String title,
    Map<String, String> currentData,
  ) async {
    final controllers = <String, TextEditingController>{};
    currentData.forEach((key, value) {
      controllers[key] = TextEditingController(
        text: value == '-' || value == 'ยังไม่ระบุ' ? '' : value,
      );
    });

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
                // Header สีน้ำตาลตกแต่ง Pop-up
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  color: const Color(0xFF3C261A),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_note,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'แก้ไข$title',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // ส่วนเนื้อหากรอกข้อมูล
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: controllers.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: entry.key,
                              labelStyle: const TextStyle(
                                color: Color(0xFF8C6D58),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8F4EE),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFC46835),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // ปุ่มดำเนินการ (ยกเลิก / บันทึก)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'ยกเลิก',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC46835),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final navigator = Navigator.of(context);

                            final updateData = <String, dynamic>{};
                            controllers.forEach((key, controller) {
                              final text = controller.text.trim();
                              if (key == 'ส่วนสูง (ชม.)') {
                                updateData['height'] = text.isEmpty
                                    ? '-'
                                    : text;
                              }
                              if (key == 'น้ำหนัก (กก.)') {
                                updateData['weight'] = text.isEmpty
                                    ? '-'
                                    : text;
                              }
                              if (key == 'รอบเอว (นิ้ว)') {
                                updateData['waist'] = text.isEmpty ? '-' : text;
                              }
                              if (key == 'รอบอก (นิ้ว)') {
                                updateData['chest'] = text.isEmpty ? '-' : text;
                              }
                              if (key == 'รอบสะโพก (นิ้ว)') {
                                updateData['hips'] = text.isEmpty ? '-' : text;
                              }
                              if (key == 'เบอร์โทร') {
                                updateData['phone'] = text.isEmpty
                                    ? 'ยังไม่ระบุ'
                                    : text;
                              }
                              if (key == 'วันเกิด') {
                                updateData['birthDate'] = text.isEmpty
                                    ? 'ยังไม่ระบุ'
                                    : text;
                              }
                            });

                            // อัปเดตข้อมูลขึ้น Cloud Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .update(updateData);

                            navigator.pop();
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    const colorHeaderBg = Color(0xFF3C261A);
    const colorPageBg = Color(0xFFF8F4EE);
    const colorBadge = Color(0xFFC46835);
    const colorCardBg = Colors.white;

    if (currentUser == null) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: colorPageBg,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

          final String name =
              currentUser.displayName ?? data['name'] ?? 'ผู้ใช้งาน';
          final String email = currentUser.email ?? data['email'] ?? '-';
          final String photoUrl =
              currentUser.photoURL ?? data['photoUrl'] ?? '';

          final String phone = data['phone'] ?? 'ยังไม่ระบุ';
          final String birthDate = data['birthDate'] ?? 'ยังไม่ระบุ';
          final String height = data['height']?.toString() ?? '-';
          final String weight = data['weight']?.toString() ?? '-';
          final String waist = data['waist']?.toString() ?? '-';
          final String chest = data['chest']?.toString() ?? '-';
          final String hips = data['hips']?.toString() ?? '-';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header สีน้ำตาล
                Container(
                  width: double.infinity,
                  color: colorHeaderBg,
                  padding: const EdgeInsets.only(
                    top: 60,
                    bottom: 24,
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorBadge,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'สมาชิก Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // เนื้อหาหลัก
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // การ์ด 1: ข้อมูลสัดส่วนร่างกาย
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorCardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ข้อมูลสัดส่วนร่างกาย',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showEditDialog(
                                    currentUser.uid,
                                    'ข้อมูลสัดส่วนร่างกาย',
                                    {
                                      'ส่วนสูง (ชม.)': height,
                                      'น้ำหนัก (กก.)': weight,
                                      'รอบเอว (นิ้ว)': waist,
                                      'รอบอก (นิ้ว)': chest,
                                      'รอบสะโพก (นิ้ว)': hips,
                                    },
                                  ),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  label: const Text(
                                    'แก้ไข',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildMetricBox(
                                  'ส่วนสูง',
                                  height,
                                  'ชม.',
                                  Icons.height,
                                ),
                                const SizedBox(width: 8),
                                _buildMetricBox(
                                  'น้ำหนัก',
                                  weight,
                                  'กก.',
                                  Icons.scale,
                                ),
                                const SizedBox(width: 8),
                                _buildMetricBox(
                                  'รอบเอว',
                                  waist,
                                  'นิ้ว',
                                  Icons.straighten,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildMetricBox(
                                  'รอบอก',
                                  chest,
                                  'นิ้ว',
                                  Icons.straighten,
                                ),
                                const SizedBox(width: 8),
                                _buildMetricBox(
                                  'รอบสะโพก',
                                  hips,
                                  'นิ้ว',
                                  Icons.straighten,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // การ์ด 2: ข้อมูลบัญชีผู้ใช้
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorCardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ข้อมูลบัญชีผู้ใช้',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showEditDialog(
                                    currentUser.uid,
                                    'ข้อมูลเพิ่มเติม',
                                    {'เบอร์โทร': phone, 'วันเกิด': birthDate},
                                  ),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  label: const Text(
                                    'แก้ไข',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('ชื่อ-นามสกุล', name),
                            const Divider(height: 24),
                            _buildInfoRow('อีเมล', email),
                            const Divider(height: 24),
                            _buildInfoRow('เบอร์โทร', phone),
                            const Divider(height: 24),
                            _buildInfoRow('วันเกิด', birthDate),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ปุ่ม Logout
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 45),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('ออกจากระบบ'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          } else if (index == 2) {
            // สลับไปหน้า FavoriteScreen โดยตรง
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FavoriteScreen()),
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

  Widget _buildMetricBox(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F6F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF8C6D58)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
