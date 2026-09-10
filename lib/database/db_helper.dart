import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/station.dart';
import '../models/train.dart';
import '../models/train_stop.dart';
import '../models/chat_message.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cityrails.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Check if database exists
    final exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join('assets', 'cityrails.db'));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    final db = await openDatabase(path, version: 1, onCreate: _createLocalTables);
    await _ensureLocalTablesExist(db);
    return db;
  }

  Future<void> _createLocalTables(Database db, int version) async {
    await _ensureLocalTablesExist(db);
  }

  Future<void> _ensureLocalTablesExist(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_name TEXT,
        station_name TEXT,
        line TEXT,
        message TEXT,
        timestamp TEXT,
        likes INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_delays (
        train_no TEXT PRIMARY KEY,
        delay_minutes INTEGER,
        reported_at TEXT,
        station_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorite_stations (
        name TEXT PRIMARY KEY,
        line TEXT
      )
    ''');

    // Insert sample local chat messages if empty
    final chatCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM chat_messages'));
    if (chatCount == 0) {
      await db.insert('chat_messages', {
        'sender_name': 'Nilesh Dharpale',
        'station_name': 'Thane',
        'line': 'Trans-Harbour',
        'message': 'Train started from Thane platform 9.',
        'timestamp': '10 mins ago',
        'likes': 4
      });
      await db.insert('chat_messages', {
        'sender_name': 'Chetan Maindargi',
        'station_name': 'Dombivli',
        'line': 'Central',
        'message': 'Central line trains running late by 5-10 mins near Mumbra.',
        'timestamp': '5 mins ago',
        'likes': 7
      });
      await db.insert('chat_messages', {
        'sender_name': 'Rajesh Sharma',
        'station_name': 'Andheri',
        'line': 'Western',
        'message': 'Fast AC train arriving on PF 5 in 2 minutes.',
        'timestamp': 'Just Now',
        'likes': 12
      });
    }
  }

  // --- Station Queries ---
  Future<List<Station>> getAllStations({String? line}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps;
    if (line != null && line.isNotEmpty && line != 'All') {
      maps = await db.query('stations',
          where: 'line = ?', whereArgs: [line], orderBy: 'name ASC');
    } else {
      maps = await db.query('stations', orderBy: 'name ASC');
    }
    return maps.map((m) => Station.fromMap(m)).toList();
  }

  Future<List<Station>> searchStations(String query) async {
    final db = await instance.database;
    final maps = await db.query(
      'stations',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
      limit: 30,
    );
    return maps.map((m) => Station.fromMap(m)).toList();
  }

  // --- Trains At Station Query ---
  Future<List<Train>> getTrainsAtStation(
    String stationName, {
    String filter = 'ALL', // ALL, SLOW, FAST, AC
    String? direction, // UP, DN, or null for ALL
    DateTime? nowTime,
  }) async {
    final db = await instance.database;
    final now = nowTime ?? DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    String sql = '''
      SELECT t.train_no, t.line, t.train_code, t.origin, t.destination, 
             t.direction, t.is_ac, t.is_fast, t.coaches, t.start_time, t.end_time,
             ts.departure_time, ts.departure_minutes, ts.pf_num, ts.pf_side
      FROM train_stops ts
      JOIN trains t ON ts.train_no = t.train_no
      WHERE ts.station_name = ?
    ''';

    List<dynamic> args = [stationName];

    if (filter == 'SLOW') {
      sql += ' AND t.is_fast = 0';
    } else if (filter == 'FAST') {
      sql += ' AND t.is_fast = 1';
    } else if (filter == 'AC') {
      sql += ' AND t.is_ac = 1';
    }

    if (direction != null && direction.isNotEmpty && direction != 'ALL') {
      sql += ' AND t.direction = ?';
      args.add(direction);
    }

    sql += ' ORDER BY ts.departure_minutes ASC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    List<Train> trains = [];

    for (var map in maps) {
      Train train = Train.fromMap(map);
      int depMins = map['departure_minutes'] ?? 0;

      // Calculate dynamic live location & status
      _computeLiveTrainStatus(train, depMins, currentMinutes, stationName);
      trains.add(train);
    }

    // Sort trains by how close they are to current time (e.g., upcoming first, then recently departed)
    trains.sort((a, b) {
      int depA = _parseTimeToMins(a.stationDepartureTime ?? a.startTime);
      int depB = _parseTimeToMins(b.stationDepartureTime ?? b.startTime);

      int diffA = (depA - currentMinutes + 1440) % 1440;
      int diffB = (depB - currentMinutes + 1440) % 1440;

      return diffA.compareTo(diffB);
    });

    return trains;
  }

  int _parseTimeToMins(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (_) {
      return 0;
    }
  }

  void _computeLiveTrainStatus(
      Train train, int depMins, int currentMins, String stationName) {
    int diff = depMins - currentMins;

    if (diff > 30) {
      train.currentStatus = 'Scheduled at $stationName';
      train.delayMinutes = 0;
    } else if (diff > 5) {
      train.currentStatus = 'Arriving in $diff mins';
      train.delayMinutes = 0;
    } else if (diff >= -2 && diff <= 5) {
      train.currentStatus = 'At $stationName, On Time';
      train.delayMinutes = 0;
    } else if (diff < -2 && diff >= -15) {
      train.currentStatus = 'Crossed $stationName 2 min Early';
      train.delayMinutes = -2;
    } else {
      int simulatedDelay = (currentMins % 7) + 1;
      train.currentStatus =
          'Between $stationName - ${train.destination}, $simulatedDelay min Late';
      train.delayMinutes = simulatedDelay;
    }
  }

  // --- Full Train Details with Route Stops ---
  Future<Train?> getTrainWithRoute(String trainNo, {String? currentStationName}) async {
    final db = await instance.database;

    final trainMaps = await db.query(
      'trains',
      where: 'train_no = ?',
      whereArgs: [trainNo],
    );

    if (trainMaps.isEmpty) return null;

    Train train = Train.fromMap(trainMaps.first);

    final stopMaps = await db.query(
      'train_stops',
      where: 'train_no = ?',
      whereArgs: [trainNo],
      orderBy: 'stop_sequence ASC',
    );

    train.stops = stopMaps.map((m) => TrainStop.fromMap(m)).toList();

    return train;
  }

  // --- A to B Train Search ---
  Future<List<Map<String, dynamic>>> searchABTrains(
      String originStn, String destStn) async {
    final db = await instance.database;

    String sql = '''
      SELECT 
        t.train_no, t.line, t.train_code, t.origin, t.destination,
        t.is_ac, t.is_fast, t.coaches,
        ts1.departure_time as origin_time, ts1.departure_minutes as origin_mins, ts1.pf_num as origin_pf,
        ts2.departure_time as dest_time, ts2.departure_minutes as dest_mins, ts2.pf_num as dest_pf
      FROM train_stops ts1
      JOIN train_stops ts2 ON ts1.train_no = ts2.train_no
      JOIN trains t ON ts1.train_no = t.train_no
      WHERE ts1.station_name = ? 
        AND ts2.station_name = ?
        AND ts1.stop_sequence < ts2.stop_sequence
      ORDER BY ts1.departure_minutes ASC
    ''';

    final maps = await db.rawQuery(sql, [originStn, destStn]);
    return maps;
  }

  // --- Local Chat Forum ---
  Future<List<ChatMessage>> getChatMessages({String? line}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps;
    if (line != null && line.isNotEmpty && line != 'All') {
      maps = await db.query('chat_messages',
          where: 'line = ?', whereArgs: [line], orderBy: 'id DESC', limit: 50);
    } else {
      maps = await db.query('chat_messages', orderBy: 'id DESC', limit: 50);
    }
    return maps.map((m) => ChatMessage.fromMap(m)).toList();
  }

  Future<void> postChatMessage(ChatMessage msg) async {
    final db = await instance.database;
    await db.insert('chat_messages', msg.toMap());
  }

  // --- Favorite Stations ---
  Future<List<String>> getFavoriteStations() async {
    final db = await instance.database;
    final maps = await db.query('favorite_stations');
    return maps.map((m) => m['name'] as String).toList();
  }

  Future<void> toggleFavoriteStation(String name, String line) async {
    final db = await instance.database;
    final exists = await db
        .query('favorite_stations', where: 'name = ?', whereArgs: [name]);
    if (exists.isNotEmpty) {
      await db.delete('favorite_stations', where: 'name = ?', whereArgs: [name]);
    } else {
      await db.insert('favorite_stations', {'name': name, 'line': line});
    }
  }
}
