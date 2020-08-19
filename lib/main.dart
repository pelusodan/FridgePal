// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/fridge.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => Fridge(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // load from sql
    Provider.of<Fridge>(context, listen: false).updateItems();
    return MaterialApp(
        title: 'FridgePal',
        theme: ThemeData(primaryColor: Colors.amber),
        debugShowCheckedModeBanner: false,
        home: Main());
  }
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("What's in the Fridge?"),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              return _showConfirmationDialog(context);
            },
          )
        ],
      ),
      body: Center(
        child: FridgeScreen(),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete all items from fridge?"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('This permanently removes all entries from database'),
                  Text('It cannot be undone'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Delete"),
                onPressed: () {
                  Provider.of<Fridge>(context, listen: false).clearFridge();
                  Navigator.of(context, rootNavigator: true).pop(context);
                },
              )
            ],
          );
        });
  }
}

class FridgeScreen extends StatefulWidget {
  @override
  _FridgeScreenState createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  final _biggerFont = TextStyle(fontSize: 18.0);
  final _biggestFont = TextStyle(fontSize: 36.0);
  DateTime selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  String _selectedTitle;

  @override
  Widget build(BuildContext context) => Consumer<Fridge>(
        builder: (context, fridge, child) => Scaffold(
          body: _buildFridge(fridge.items),
          floatingActionButton: new FloatingActionButton(
              elevation: 1.0,
              child: new Icon(Icons.add),
              onPressed: () {
                _addItem();
              }),
        ),
      );

  Widget _buildFridge(List<FridgeItem> items) {
    return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          items.sort((a, b) {
            return a.expiration.compareTo(b.expiration);
          });
          return _buildFridgeItem(items[i]);
        });
  }

  Widget _buildFridgeItem(FridgeItem fridgeItem) {
    return Dismissible(
      child: Card(
        child: ListTile(
          leading: Text(
            fridgeItem.name,
            style: _biggestFont,
          ),
          title: Text(
            "${fridgeItem.expiration.difference(DateTime.now()).inDays} days",
            style: _biggerFont,
          ),
        ),
      ),
      background: Container(
        color: Colors.red,
      ),
      key: UniqueKey(),
      onDismissed: (direction) {
        Provider.of<Fridge>(context, listen: false).dumpFood(fridgeItem);
      },
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
                    if (selectedDate != null &&
                        _formKey.currentState.validate()) {
                      Provider.of<Fridge>(context, listen: false).addFood(
                          FridgeItem(
                              (_selectedTitle + selectedDate.toIso8601String())
                                  .hashCode,
                              _selectedTitle,
                              selectedDate));
                      Navigator.of(context, rootNavigator: true).pop(context);
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
