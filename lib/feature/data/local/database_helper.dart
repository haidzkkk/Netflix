
import 'package:path/path.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/data/models/db_local/episode_local.dart';
import 'package:spotify/feature/data/models/db_local/history_local.dart';
import 'package:sqflite/sqflite.dart';

import '../models/db_local/movie_local.dart';

class DataBaseHelper{

  static final DataBaseHelper instance = DataBaseHelper._privateController();
  DataBaseHelper._privateController();
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: AppConstants.dbVersion, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE ${MovieLocalField.movieTableName}(
      ${MovieLocalField.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${MovieLocalField.movieId} TEXT,
      ${MovieLocalField.movieSlug} TEXT,
      ${MovieLocalField.movieName} TEXT,
      ${MovieLocalField.moviePoster} TEXT,
      ${MovieLocalField.movieThumb} TEXT,
      ${MovieLocalField.movieLastTime} INTEGER
      )''');

    await db.execute('''CREATE TABLE ${EpisodeLocalField.tableName}(
      ${EpisodeLocalField.id} TEXT PRIMARY KEY,
      ${EpisodeLocalField.movieId} TEXT,
      ${EpisodeLocalField.slug} TEXT,
      ${EpisodeLocalField.name} TEXT,
      ${EpisodeLocalField.lastTime} INTEGER,
      ${EpisodeLocalField.currentSecond} INTEGER
      )''');

    await db.execute('''CREATE TABLE ${HistoryLocalField.historyTableName}(
      ${HistoryLocalField.historyId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${HistoryLocalField.historyContent} TEXT,
      ${HistoryLocalField.historyTime} INTEGER
      )''');
  }
  Future<List<Map<String, dynamic>>> getAll({
    required String tableName,
    Map<String, dynamic>? whereParams,
    MapEntry<bool, String>? arrange,
    int? pageSize,
    int? pageIndex,
  }) async{
    var offset = pageIndex == null || pageSize == null || pageIndex <= 1 ? 0 : ((pageIndex - 1) * pageSize);

    final db = await instance.database;
    return await db.query(
      tableName,
      orderBy: "${arrange?.value} ${arrange?.key == false ? "ASC" : "DESC"}",
      where: whereParams?.keys.map(((key) => "$key = ?")).toList().join(" and "),
      whereArgs: whereParams?.values.toList(),
      limit: pageSize,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>?> getBy({
    required String tableName,
    required List<String> query,
    required Map<String, dynamic> params,
  }) async {
    var where = params.keys.map(((key) => "$key = ?")).toList().join(" and ");
    final db = await instance.database;
    final maps = await db.query(tableName, columns: query,
        where: where,
        whereArgs: params.values.toList()
    );
    return maps;
  }

  /// when id is int and autoincrement it will return id
  /// if error return -1
  Future<int> insert({
    required String tableName,
    required Map<String, dynamic> body
  }) async{
    final db = await instance.database;
    final id = await db.insert(tableName, body, conflictAlgorithm: ConflictAlgorithm.replace,);
    return id;
  }

  Future<int> update({
    required String tableName,
    required Map<String, dynamic> body,
    required Map<String, dynamic> params,
  }) async{
    var where = params.keys.map(((key) => "$key = ?")).toList().join(" and ");
    final db = await instance.database;
    final id = await db.update(
        tableName,
        body,
        where: where,
        whereArgs: params.values.toList()
    );
    return id;
  }

  Future<int> deleteUser({
    required String tableName,
    required Map<String, dynamic> params,
  }) async{
    var where = params.keys.map(((key) => "$key = ?")).toList().join(" and ");
    final db = await instance.database;
    return await db.delete(
      tableName,
      where: where,
      whereArgs: params.values.toList()
    );
  }


}