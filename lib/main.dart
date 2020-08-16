// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FridgePal',
      theme: ThemeData(primaryColor: Colors.amber),
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
  FridgeItem("Spaghetti", DateTime.now()),
  FridgeItem("Spinach", DateTime.now())
];

class _FridgeState extends State<Fridge> {
  final _fridgeItems = exItems;
  final _biggerFont = TextStyle(fontSize: 18.0);
  final _biggestFont = TextStyle(fontSize: 40.0);
  DateTime selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  String _selectedTitle;

  @override
  Widget build(BuildContext context) => new Scaffold(
        body: _buildFridge(),
        floatingActionButton: new FloatingActionButton(
            elevation: 1.0,
            child: new Icon(Icons.add),
            onPressed: () {
              _addItem();
            }),
      );

  Widget _buildFridge() {
    return ListView.builder(
        itemCount: _fridgeItems.length,
        itemBuilder: (context, i) {
          _fridgeItems.sort(
                  (a,b)  {
                return a.expiration.compareTo(b.expiration);
              });
          return _buildFridgeItem(_fridgeItems[i]);
        });
  }

  Widget _buildFridgeItem(FridgeItem fridgeItem) {
    return Card(
      child: ListTile(
        leading: Text(
          "${fridgeItem.expiration.difference(DateTime.now()).inDays} days",
          style: _biggestFont,
        ),
        title: Text(
            fridgeItem.name,
        style: _biggerFont,),
      ),
    );
  }

  void _addItem() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              children: <Widget>[
                RaisedButton(
                    onPressed: () => _selectDate(context),
                    child: Text("Select date"),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Needs a name!';
                            }
                            _selectedTitle = value;
                            return null;
                          },
                        )
                      ],
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (selectedDate != null && _formKey.currentState.validate()) {
                        setState(() {
                          _fridgeItems
                              .add(FridgeItem(_selectedTitle, selectedDate));
                          Navigator.of(
                            context,
                            rootNavigator: true).pop(context);
                        });
                      }
                    },
                    child: Text("Add to list"),
                  ),
              ],
            ),
          );
        });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}

class FridgeItem {
  String name;
  DateTime expiration;

  FridgeItem(this.name, this.expiration);
}
