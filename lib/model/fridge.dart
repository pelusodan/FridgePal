import 'package:flutter/cupertino.dart';
import 'package:flutter_listview/database/repository.dart';

class Fridge extends ChangeNotifier {
  List<FridgeItem> _items = [];
  final Repository db = Repository.repo;

  List<FridgeItem> get items => _items;

  Future<void> addFood(FridgeItem item) async {
    db.insert(item);
    updateItems();
  }

  void clearFridge() async {
    await db.removeAll();
    _items = await db.getFridgeItems();
    notifyListeners();
  }

  void dumpFood(FridgeItem item) async {
    await db.remove(item);
    _items = await db.getFridgeItems();
    notifyListeners();
  }

  int getFridgeLength() {
    return _items.length;
  }

  void updateItems() async {
    _items = await db.getFridgeItems();
    notifyListeners();
  }
}

class FridgeItem {
  int id;
  String name;
  DateTime expiration;

  FridgeItem(this.id,this.name, this.expiration);

  FridgeItem.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    expiration = DateTime.parse(map["expiration"]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "id": id,
      "name": name,
      "expiration": expiration.toIso8601String()
    };
    return map;
  }
}
