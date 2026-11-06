import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// [LocalDatabaseService] - ระบบจัดการฐานข้อมูลภายในเครื่อง (Local SQLite Database)
/// ใช้ SQLite (ผ่าน sqflite) ตามเกณฑ์รายวิชา MDSD (Mobile Device Software Development)
/// 
/// โครงสร้างตาราง (Tables):
/// 1. `search_history` - บันทึกประวัติการค้นหาเสื้อผ้าและสไตล์ (Search History)
/// 2. `cached_outfits` - แคชชุดเสื้อผ้าในตู้เสื้อผ้าสำหรับเปิดดูแบบ Offline (Offline Wardrobe Cache)
/// 3. `user_measurements` - บันทึกประวัติสัดส่วนร่างกายของผู้ใช้ในเครื่อง (User Measurements Log)
class LocalDatabaseService {
  LocalDatabaseService._internal();

  /// Singleton Instance สำหรับเรียกใช้งานทั่วทั้งแอป
  static final LocalDatabaseService instance = LocalDatabaseService._internal();

  Database? _db;

  /// รองรับการ Inject Mock Database สำหรับ Unit Test
  @visibleForTesting
  set dbForTesting(Database? db) => _db = db;

  /// ดึง Database Instance พร้อมเปิดการเชื่อมต่ออัตโนมัติหากยังไม่ได้เปิด
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await initDb();
    return _db!;
  }

  /// เริ่มต้นสร้าง/เปิดฐานข้อมูล SQLite
  Future<Database> initDb({String dbName = 'outfitcheck_local.db'}) async {
    // สำหรับ Desktop (Windows, macOS, Linux) หรือตอนรัน flutter test ให้ใช้ ffi
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await createTables(db);
        await seedDefaultData(db);
      },
    );
  }

  /// สร้าง Schema ตารางทั้งหมดใน SQLite
  static Future<void> createTables(Database db) async {
    // 1. ตารางประวัติการค้นหา (search_history)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL
      )
    ''');

    // 2. ตารางแคชตู้เสื้อผ้าออฟไลน์ (cached_outfits)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cached_outfits (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        image TEXT,
        tags TEXT,
        items_json TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 1,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 3. ตารางประวัติสัดส่วนร่างกาย (user_measurements)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        height REAL,
        waist REAL,
        weight REAL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  /// ข้อมูลเริ่มต้นเมื่อสร้างฐานข้อมูลครั้งแรก (Seed Data)
  static Future<void> seedDefaultData(Database db) async {
    final defaultSearches = [
      'คาเฟ่มินิมอล',
      'ทำงานออฟฟิศ',
      'เดทตอนเย็น',
      'แคมป์ปิ้งเขาใหญ่',
      'ชุดไปงานแต่ง',
    ];

    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = db.batch();
    for (int i = 0; i < defaultSearches.length; i++) {
      batch.insert(
        'search_history',
        {
          'query': defaultSearches[i],
          'created_at': now - (i * 1000),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  // ===========================================================================
  // 1. หมวดจัดการประวัติการค้นหา (Search History CRUD)
  // ===========================================================================

  /// บันทึกคำค้นหาล่าสุด (หากมีอยู่แล้วจะอัปเดตเวลาล่าสุด / Upsert)
  /// และจำกัดประวัติสูงสุดไม่เกิน [maxLimit] รายการ
  Future<void> insertSearch(String query, {int maxLimit = 20}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'search_history',
      {
        'query': trimmed,
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // ลบรายการเก่าที่เกินจำนวนที่กำหนดทิ้งอัตโนมัติ
    await db.execute('''
      DELETE FROM search_history 
      WHERE id NOT IN (
        SELECT id FROM search_history 
        ORDER BY created_at DESC 
        LIMIT ?
      )
    ''', [maxLimit]);
  }

  /// ดึงประวัติการค้นหาล่าสุด เรียงจากล่าสุดไปเก่าสุด
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    final db = await database;
    final rows = await db.query(
      'search_history',
      columns: ['query'],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map((r) => r['query'] as String).toList();
  }

  /// ลบคำค้นหาที่ระบุออกจากประวัติ
  Future<int> deleteSearch(String query) async {
    final db = await database;
    return await db.delete(
      'search_history',
      where: 'query = ?',
      whereArgs: [query.trim()],
    );
  }

  /// ล้างประวัติการค้นหาทั้งหมด
  Future<int> clearAllSearches() async {
    final db = await database;
    return await db.delete('search_history');
  }

  // ===========================================================================
  // 2. หมวดแคชตู้เสื้อผ้าออฟไลน์ (Offline Wardrobe Cache CRUD)
  // ===========================================================================

  /// บันทึกหรืออัปเดตชุดเสื้อผ้าลงใน Local Cache
  Future<void> saveCachedOutfit({
    required String id,
    required String userId,
    required String title,
    String? image,
    List<String>? tags,
    List<Map<String, dynamic>>? items,
    bool isFavorite = true,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'cached_outfits',
      {
        'id': id,
        'user_id': userId,
        'title': title,
        'image': image ?? '',
        'tags': jsonEncode(tags ?? []),
        'items_json': jsonEncode(items ?? []),
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// บันทึกชุดเสื้อผ้าพร้อมกันหลายรายการ (Batch Cache) จาก Firestore
  Future<void> cacheOutfits(
    String userId,
    List<Map<String, dynamic>> outfitList,
  ) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = db.batch();

    for (final outfit in outfitList) {
      final id = (outfit['id'] ?? '').toString();
      if (id.isEmpty) continue;

      final title = (outfit['title'] ?? outfit['outfitName'] ?? 'ชุดเสื้อผ้า').toString();
      final image = (outfit['image'] ?? outfit['imageUrl'] ?? '').toString();

      List<String> tags = [];
      if (outfit['tags'] is List) {
        tags = (outfit['tags'] as List).map((e) => e.toString()).toList();
      } else if (outfit['category'] != null) {
        tags = [outfit['category'].toString()];
      }

      List<Map<String, dynamic>> items = [];
      if (outfit['items'] is List) {
        for (var it in (outfit['items'] as List)) {
          if (it is Map) {
            items.add({
              'text': (it['text'] ?? it['name'] ?? '').toString(),
              'itemImage': (it['itemImage'] ?? it['imageUrl'] ?? '').toString(),
            });
          } else {
            items.add({'text': it.toString(), 'itemImage': ''});
          }
        }
      }

      batch.insert(
        'cached_outfits',
        {
          'id': id,
          'user_id': userId,
          'title': title,
          'image': image,
          'tags': jsonEncode(tags),
          'items_json': jsonEncode(items),
          'is_favorite': (outfit['isFavorite'] == false) ? 0 : 1,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// ดึงรายการชุดเสื้อผ้าที่แคชไว้ในเครื่องของผู้ใช้
  Future<List<Map<String, dynamic>>> getCachedOutfits(String userId) async {
    final db = await database;
    final rows = await db.query(
      'cached_outfits',
      where: 'user_id = ? AND is_favorite = 1',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );

    return rows.map((row) {
      List<String> tags = [];
      try {
        final decoded = jsonDecode(row['tags'] as String? ?? '[]');
        if (decoded is List) {
          tags = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}

      List<Map<String, dynamic>> items = [];
      try {
        final decoded = jsonDecode(row['items_json'] as String? ?? '[]');
        if (decoded is List) {
          items = decoded.cast<Map<String, dynamic>>();
        }
      } catch (_) {}

      return {
        'id': row['id'],
        'userId': row['user_id'],
        'title': row['title'],
        'image': row['image'],
        'tags': tags,
        'items': items,
        'isFavorite': row['is_favorite'] == 1,
        'updatedAt': row['updated_at'],
      };
    }).toList();
  }

  /// ลบชุดเสื้อผ้าออกจากแคช
  Future<int> deleteCachedOutfit(String id) async {
    final db = await database;
    return await db.delete(
      'cached_outfits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ลบแคชชุดเสื้อผ้าทั้งหมดของผู้ใช้คนนี้
  Future<int> clearCachedOutfits(String userId) async {
    final db = await database;
    return await db.delete(
      'cached_outfits',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ===========================================================================
  // 3. หมวดบันทึกสัดส่วนร่างกาย (User Measurements CRUD)
  // ===========================================================================

  /// บันทึกสัดส่วนร่างกายล่าสุดลงใน Local Database
  Future<int> saveMeasurement({
    required String userId,
    double? height,
    double? waist,
    double? weight,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    return await db.insert(
      'user_measurements',
      {
        'user_id': userId,
        'height': height,
        'waist': waist,
        'weight': weight,
        'updated_at': now,
      },
    );
  }

  /// ดึงข้อมูลสัดส่วนร่างกายล่าสุดของผู้ใช้
  Future<Map<String, dynamic>?> getLatestMeasurement(String userId) async {
    final db = await database;
    final rows = await db.query(
      'user_measurements',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return rows.first;
  }

  /// ดึงประวัติการวัดสัดส่วนทั้งหมดของผู้ใช้ (Measurement Log)
  Future<List<Map<String, dynamic>>> getMeasurementHistory(String userId) async {
    final db = await database;
    return await db.query(
      'user_measurements',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
  }

  /// ปิดการเชื่อมต่อฐานข้อมูล
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
