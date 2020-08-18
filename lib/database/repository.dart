import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter_listview/model/fridge.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Repository {
  static final _tableName = "fridge_items";
  static final _databaseName = "FridgeDatabase.db";
  static final _databaseVersion = 1;

  // singleton pattern
  Repository._internal();

  static final Repository repo = new Repository._internal();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future updateFridgeItem(FridgeItem item) async {}

  _initDatabase() async {
    Directory docs = await getApplicationDocumentsDirectory();
    String path = join(docs.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        "name" TEXT PRIMARY KEY,
        "expiration" TEXT NOT NULL
      )
      ''');
  }

  Future<int> insert(FridgeItem item) async {
    Database db = await database;
    int id = await db.insert(_tableName, item.toMap());
    return id;
  }

  Future<List<FridgeItem>> getFridgeItems() async {
    Database db = await database;
    print(await db.query(_tableName));
    List<FridgeItem> items = [];
    List<Map> maps = await db.query(_tableName);
    maps.forEach((element) {
      items.add(FridgeItem.fromMap(element));
    });
    return items;
  }

  //TODO: clear all items from fridge
  //TODO: clear a single item from the fridge
}
