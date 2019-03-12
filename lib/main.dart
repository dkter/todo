/**
 * A simple to-do list app.
 * Copyright (C) David Teresi 2018
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 * This Source Code Form is "Incompatible With Secondary Licenses", as
 * defined by the Mozilla Public License, v. 2.0.
 */

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'item.dart';
import 'leave_behind.dart';

String FILENAME = "todo.txt";

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            title: 'Todo',
            theme: new ThemeData(
                primarySwatch: Colors.blue,
            ),
            home: new MyHomePage(title: 'Todo'),
        );
    }
}

_MyHomePageState _myHomePageState = new _MyHomePageState();

class MyHomePage extends StatefulWidget {
    MyHomePage({Key key, this.title}) : super(key: key);

    final String title;

    @override
    _MyHomePageState createState() => _myHomePageState;
}

class _MyHomePageState extends State<MyHomePage> {
    List<Item> _items = <Item>[];
    TextEditingController newItemController;

    @override
    void initState() {
        super.initState();
        _readItemData().then((List<Item> items) {
            setState(() {
                _items = items;
            });
        });

        newItemController = new TextEditingController();
    }

    Map<DismissDirection, double> _dismissThresholds() {
        Map<DismissDirection, double> map = new Map<DismissDirection, double>();
        map.putIfAbsent(DismissDirection.horizontal, () => 0.5);
        return map;
    }

    Future<Null> _addItem(BuildContext context) async {
        /*
        // "add item" modal (bottom sheet)
        showModalBottomSheet(context: context, builder: (BuildContext context) {
            return new Container(
                margin: const EdgeInsets.all(16.0),
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        new Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
                            child: new Text(
                                "Add an item",
                                style: new TextStyle(fontSize: 24.0)),
                        ),
                        new TextField(),
                    ],
                )
            );
        });
        */
        // "add item" modal (dialog)
        showDialog(context: context, builder: (BuildContext context) {
            return new AlertDialog(
                title: const Text("Add an item"),
                content: new SingleChildScrollView(
                    child: new Form(
                        child: new ListBody(
                            children: <Widget>[
                                new TextFormField(
                                    decoration: new InputDecoration(labelText: "Title"),
                                    controller: newItemController,
                                ),
                            ],
                        ),
                    ),
                ),
                actions: <Widget>[
                    new FlatButton(
                        child: new Text("Cancel"),
                        onPressed: Navigator.of(context).pop,  // dismiss dialog
                    ),
                    new FlatButton(
                        child: new Text("Ok"),
                        onPressed: () {
                            setState(() {
                                // add item to list
                                _items.add(new Item(_items.length, newItemController.text));
                                newItemController.text = "";  // clear textbox
                            });
                            Navigator.of(context).pop();  // dismiss dialog
                        },
                    ),
                ],
            );
        });

        String json = Item.listToJson(_items);
        await (await _getItemFile()).writeAsString(json);
    }

    Future<File> _getItemFile() async {
        String dir = (await getApplicationDocumentsDirectory()).path;
        return new File("$dir/$FILENAME");
    }

    Future<List<Item>> _readItemData() async {
        try {
            File file = await _getItemFile();
            String json = await file.readAsString();
            List<Item> items = Item.listFromJson(json);
            return items;
        } on FileSystemException {
            return <Item>[];
        }
    }

    Widget _buildItem(BuildContext context, int index) {
        Item item = _items[index];
        return new Dismissible(
            key: new Key(item.id.toString()),
            direction: DismissDirection.horizontal,
            onDismissed: (DismissDirection direction) {
                int deleted_index;
                setState(() {
                    deleted_index = delete(item);
                });

                var deletion_snackbar = new SnackBar(
                    content: new Text(item.text + " deleted"),
                    action: new SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                            setState(() {
                                // reinsert item
                                _items.insert(deleted_index, item);
                            });
                        }
                    )
                );

                update();
                Scaffold.of(context).showSnackBar(deletion_snackbar);
            },
            resizeDuration: null,
            dismissThresholds: _dismissThresholds(),
            background: new LeaveBehindView(),
            child: new ItemView(item),
        );
    }

    void update() {
        String json = Item.listToJson(_items);
        _getItemFile().then((File file) {
            file.writeAsString(json);
        });
    }

    void updateLocal() {
        _readItemData().then((List<Item> items) {
            setState(() {
                _items = items;
            });
        });
    }

    int delete(Item item) {
        // Returns the index of the deleted item, for reinsertion purposes
        int index = _items.indexWhere((i) => i.id == item.id);
        _items.removeAt(index);
        return index;
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                title: new Text(widget.title),
            ),
            body: _buildItems(),
            floatingActionButton: new FloatingActionButton(
                onPressed: () { _addItem(context); },
                tooltip: 'Add item',
                child: new Icon(Icons.add),
            ),
        );
    }

    Widget _buildItems() {
        return new ListView.builder(
            //padding: const EdgeInsets.all(16.0),
            itemBuilder: _buildItem,
            itemCount: _items.length,
        );
    }
}

class ItemView extends StatefulWidget {
    final Item item;
    const ItemView(this.item);

    @override
    ItemViewState createState() => new ItemViewState(item);
}

class ItemViewState extends State<ItemView> {
    final Item item;
    bool editing = false;
    // controller for the item editing view
    TextEditingController itemEditingController;

    ItemViewState(this.item);

    @override
    void initState() {
        super.initState();
        itemEditingController = new TextEditingController(text: item.text);
    }

    void _setDone(bool value) {
        setState(() {
            item.done = value;
        });
        _myHomePageState.update();
    }

    void _setText(String text) {
        setState(() {
            item.text = text;
        });
        _myHomePageState.update();
    }

    void _delete() {
        setState(() {
            _myHomePageState.setState(() {
                _myHomePageState.delete(item);
                _myHomePageState.update();
                _myHomePageState.updateLocal();
            });
        });
    }

    Map<DismissDirection, double> _dismissThresholds() {
        Map<DismissDirection, double> map = new Map<DismissDirection, double>();
        map.putIfAbsent(DismissDirection.horizontal, () => 0.5);
        return map;
    }

    @override
    Widget build(BuildContext context) {
        // delete empty items
        if (item.text == "") _delete();

        Widget tile = editing
          ? new ListTile(
                title: new TextField(
                    controller: itemEditingController,
                    autofocus: true,
                    onSubmitted: _setText,
                ),
                trailing: new IconButton(
                    icon: new Icon(Icons.done),
                    tooltip: 'Done',
                    onPressed: () {
                        _setText(itemEditingController.text);
                    },
                ),
            )
          : new ListTile(
                title: new Text(item.text),
                leading: new Checkbox(
                    value: item.done,
                    onChanged: _setDone,
                ),
                onTap: () {
                    _setDone(!item.done);
                },
                onLongPress: () {
                    setState(() {
                        editing = true;
                    });
                },
            );
        editing = false;
        return tile;
        // return new Dismissible(
        //     key: new Key(item.id.toString()),
        //     direction: DismissDirection.horizontal,
        //     onDismissed: (DismissDirection direction) {
        //         _delete();
        //     },
        //     resizeDuration: null,
        //     dismissThresholds: _dismissThresholds(),
        //     background: new LeaveBehindView(),
        //     child: tile,
        // );
    }
}
