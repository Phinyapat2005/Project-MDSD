import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:outfitcheck/services/local_database_service.dart';

void main() {
  setUpAll(() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  late Database testDb;

  setUp(() async {
    testDb = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await LocalDatabaseService.createTables(db);
      },
    );
    LocalDatabaseService.instance.dbForTesting = testDb;
  });

  tearDown(() async {
    await LocalDatabaseService.instance.close();
  });

  group('LocalDatabaseService - Search History Tests', () {
    test('เริ่มต้นตารางประวัติการค้นหาว่างเปล่า', () async {
      final searches = await LocalDatabaseService.instance.getRecentSearches();
      expect(searches, isEmpty);
    });

    test('seedDefaultData เพิ่มคำค้นหาเริ่มต้นถูกต้อง', () async {
      await LocalDatabaseService.seedDefaultData(testDb);
      final searches = await LocalDatabaseService.instance.getRecentSearches();
      expect(searches, isNotEmpty);
      expect(searches.contains('คาเฟ่มินิมอล'), isTrue);
      expect(searches.contains('แคมป์ปิ้งเขาใหญ่'), isTrue);
    });

    test('insertSearch บันทึกคำค้นหาใหม่และเรียงลำดับตามเวลาล่าสุด', () async {
      await LocalDatabaseService.instance.insertSearch('เสื้อเชิ้ตขาว');
      await Future.delayed(const Duration(milliseconds: 10));
      await LocalDatabaseService.instance.insertSearch('กางเกงสแล็ค');

      final searches = await LocalDatabaseService.instance.getRecentSearches();
      expect(searches.length, 2);
      expect(searches[0], 'กางเกงสแล็ค'); // ล่าสุดต้องอยู่อันดับ 1
      expect(searches[1], 'เสื้อเชิ้ตขาว');
    });

    test('insertSearch ไม่บันทึกคำว่าง (empty string)', () async {
      await LocalDatabaseService.instance.insertSearch('   ');
      final searches = await LocalDatabaseService.instance.getRecentSearches();
      expect(searches, isEmpty);
    });

    test('insertSearch อัปเดตเวลาล่าสุดเมื่อค้นหาคำเดิมซ้ำ (Upsert)', () async {
      await LocalDatabaseService.instance.insertSearch('รองเท้าผ้าใบ');
      await Future.delayed(const Duration(milliseconds: 10));
      await LocalDatabaseService.instance.insertSearch('เสื้อแจ็คเก็ต');
      await Future.delayed(const Duration(milliseconds: 10));
      // ค้นหา 'รองเท้าผ้าใบ' ซ้ำอีกรอบ
      await LocalDatabaseService.instance.insertSearch('รองเท้าผ้าใบ');

      final searches = await LocalDatabaseService.instance.getRecentSearches();
      expect(searches.length, 2);
      // 'รองเท้าผ้าใบ' ต้องเลื่อนมาเป็นอันดับแรก
      expect(searches[0], 'รองเท้าผ้าใบ');
      expect(searches[1], 'เสื้อแจ็คเก็ต');
    });

    test('insertSearch ตัดคำเก่าทิ้งเมื่อเกิน maxLimit', () async {
      for (int i = 1; i <= 6; i++) {
        await LocalDatabaseService.instance
            .insertSearch('ค้นหา $i', maxLimit: 3);
        await Future.delayed(const Duration(milliseconds: 5));
      }

      final searches =
          await LocalDatabaseService.instance.getRecentSearches(limit: 10);
      expect(searches.length, 3);
      expect(searches, ['ค้นหา 6', 'ค้นหา 5', 'ค้นหา 4']);
    });

    test('deleteSearch ลบคำที่ต้องการออกจากประวัติ', () async {
      await LocalDatabaseService.instance.insertSearch('คำที่ 1');
      await LocalDatabaseService.instance.insertSearch('คำที่ 2');

      final deletedCount =
          await LocalDatabaseService.instance.deleteSearch('คำที่ 1');
      expect(deletedCount, 1);

      final searches = await LocalDatabaseService.instance.getRecentSearches();
      expect(searches, ['คำที่ 2']);
    });

    test('clearAllSearches ล้างประวัติการค้นหาทั้งหมด', () async {
      await LocalDatabaseService.instance.insertSearch('คำที่ 1');
      await LocalDatabaseService.instance.insertSearch('คำที่ 2');

      final clearedCount =
          await LocalDatabaseService.instance.clearAllSearches();
      expect(clearedCount, 2);

      final searches = await LocalDatabaseService.instance.getRecentSearches();
      expect(searches, isEmpty);
    });
  });

  group('LocalDatabaseService - Offline Cached Outfits Tests', () {
    test('saveCachedOutfit และ getCachedOutfits ดึงชุดที่แคชไว้ได้ถูกต้อง', () async {
      await LocalDatabaseService.instance.saveCachedOutfit(
        id: 'outfit_1',
        userId: 'user_123',
        title: 'ชุดสูททำงาน',
        image: 'https://example.com/suit.jpg',
        tags: ['ทำงาน', 'ทางการ'],
        items: [
          {'text': 'เสื้อสูทสีกรม', 'itemImage': ''},
          {'text': 'กางเกงสแล็ค', 'itemImage': ''},
        ],
      );

      final outfits =
          await LocalDatabaseService.instance.getCachedOutfits('user_123');
      expect(outfits.length, 1);
      expect(outfits.first['id'], 'outfit_1');
      expect(outfits.first['title'], 'ชุดสูททำงาน');
      expect(outfits.first['tags'], ['ทำงาน', 'ทางการ']);
      expect((outfits.first['items'] as List).length, 2);
    });

    test('cacheOutfits บันทึกแบบ Batch หลายรายการได้ถูกต้อง', () async {
      final list = [
        {
          'id': 'batch_1',
          'title': 'ชุดไปทะเล',
          'image': 'https://example.com/beach.jpg',
          'tags': ['ทะเล', 'ชิล'],
          'items': [{'text': 'เสื้อฮาวาย'}],
          'isFavorite': true,
        },
        {
          'id': 'batch_2',
          'title': 'ชุดแคมป์ปิ้ง',
          'image': 'https://example.com/camp.jpg',
          'tags': ['แคมป์ปิ้ง'],
          'items': [{'text': 'เสื้อกั๊ก'}],
          'isFavorite': true,
        },
      ];

      await LocalDatabaseService.instance.cacheOutfits('user_456', list);
      final outfits =
          await LocalDatabaseService.instance.getCachedOutfits('user_456');
      expect(outfits.length, 2);
    });

    test('deleteCachedOutfit และ clearCachedOutfits ลบชุดในแคชได้', () async {
      await LocalDatabaseService.instance.saveCachedOutfit(
        id: 'del_1',
        userId: 'user_del',
        title: 'ชุดที่ 1',
      );
      await LocalDatabaseService.instance.saveCachedOutfit(
        id: 'del_2',
        userId: 'user_del',
        title: 'ชุดที่ 2',
      );

      // ลบทีละตัว
      await LocalDatabaseService.instance.deleteCachedOutfit('del_1');
      var list =
          await LocalDatabaseService.instance.getCachedOutfits('user_del');
      expect(list.length, 1);
      expect(list.first['id'], 'del_2');

      // ล้างทั้งหมดของผู้ใช้
      await LocalDatabaseService.instance.clearCachedOutfits('user_del');
      list = await LocalDatabaseService.instance.getCachedOutfits('user_del');
      expect(list, isEmpty);
    });
  });

  group('LocalDatabaseService - User Measurements Tests', () {
    test('saveMeasurement และ getLatestMeasurement บันทึกและดึงสัดส่วนล่าสุดได้', () async {
      await LocalDatabaseService.instance.saveMeasurement(
        userId: 'user_measure',
        height: 175.0,
        waist: 30.5,
        weight: 65.0,
      );

      final latest = await LocalDatabaseService.instance
          .getLatestMeasurement('user_measure');
      expect(latest, isNotNull);
      expect(latest!['height'], 175.0);
      expect(latest['waist'], 30.5);
      expect(latest['weight'], 65.0);
    });

    test('getMeasurementHistory ดึงประวัติสัดส่วนทั้งหมดเรียงตามลำดับเวลา', () async {
      await LocalDatabaseService.instance.saveMeasurement(
        userId: 'user_history',
        height: 170.0,
        waist: 32.0,
        weight: 70.0,
      );
      await Future.delayed(const Duration(milliseconds: 10));
      await LocalDatabaseService.instance.saveMeasurement(
        userId: 'user_history',
        height: 170.0,
        waist: 30.0,
        weight: 68.0,
      );

      final history = await LocalDatabaseService.instance
          .getMeasurementHistory('user_history');
      expect(history.length, 2);
      // ตัวล่าสุดต้องมาเป็นตัวแรก
      expect(history.first['weight'], 68.0);
      expect(history.last['weight'], 70.0);
    });
  });
}
