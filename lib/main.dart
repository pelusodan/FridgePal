// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FridgePal',
      theme: ThemeData(
        primaryColor: Colors.amber
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("What's in the Fridge?"),
        ),
        body: Center(
          child: Fridge(),
        ),
      ),
    );
  }
}

class Fridge extends StatefulWidget {
  @override
  _FridgeState createState() => _FridgeState();
}

final List<FridgeItem> exItems = [
  FridgeItem("Spaghetti",DateTime.now()),
  FridgeItem("Spinach", DateTime.now())
];

class _FridgeState extends State<Fridge> {
  final _fridgeItems = exItems;
  final biggerFont = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) => new Scaffold(
    body: _buildFridge(),
    floatingActionButton: new FloatingActionButton(
        elevation: 1.0,
        child: new Icon(Icons.add),
        onPressed: (){
          _addItem();
        }),
  );

  Widget _buildFridge() {
    return ListView.builder(
      itemCount: _fridgeItems.length,
        itemBuilder: (context, i) {
          return _buildFridgeItem(_fridgeItems[i]);
        });
  }

  Widget _buildFridgeItem(FridgeItem fridgeItem) {
    return ListTile(
      title: Text(
        fridgeItem.name,
        style: biggerFont,
      ),
      subtitle: Text(
        fridgeItem.expiration.toString()
      ),
    );
  }

  void _addItem() {
    setState(() {
      _fridgeItems.add(FridgeItem("Tofu", DateTime.now().subtract(Duration(days: 60))));
    });
  }


}

class FridgeItem {
  String name;
  DateTime expiration;

  FridgeItem(this.name,this.expiration);
}
