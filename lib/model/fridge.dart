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

  void clearFridge() {
    _items.clear();
    notifyListeners();
  }

  void dumpFood(FridgeItem item) {
    _items.remove(item);
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
  String name;
  DateTime expiration;

  FridgeItem(this.name, this.expiration);

  FridgeItem.fromMap(Map<String, dynamic> map) {
    name = map["name"];
    expiration = DateTime.parse(map["expiration"]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "name": name,
      "expiration": expiration.toIso8601String()
    };
    return map;
  }
}
