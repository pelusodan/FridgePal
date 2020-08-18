import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_listview/main.dart';

class Fridge extends ChangeNotifier {
  final List<FridgeItem> _items = [];

  List<FridgeItem> get items => _items;

  void addFood(FridgeItem item) {
    _items.add(item);
    notifyListeners();
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
}

class FridgeItem {
  String name;
  DateTime expiration;

  FridgeItem(this.name, this.expiration);
}