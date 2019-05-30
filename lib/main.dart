/**
 * A simple to-do list app.
 * Copyright (C) David Teresi 2019
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 * This Source Code Form is "Incompatible With Secondary Licenses", as
 * defined by the Mozilla Public License, v. 2.0.
 */

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'edit_item.dart';
import 'item.dart';
import 'leave_behind.dart';
import 'new_item.dart';
import 'notify.dart';
import 'util.dart';

String FILENAME = "todo.txt";


void main() {
    Notify.initialize();
    runApp(new MyApp());
}


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


    @override
    Widget build(BuildContext context) {
        this._items.sort();

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


    int delete(Item item) {
        print("Deleting item: " + item.text);
        item.deleteReminder();
        // Returns the index of the deleted item, for reinsertion purposes
        int index = _items.indexWhere((i) => i.id == item.id);
        _items.removeAt(index);
        return index;
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


    Widget _buildItems() {
        return new ListView.builder(
            itemBuilder: _buildItem,
            itemCount: _items.length,
        );
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
            background: new LeaveBehindRightView(),
            secondaryBackground: new LeaveBehindLeftView(),
            child: new ItemView(item),
        );
    }


    Future<Null> _addItem(BuildContext context) async {
        DateTime due = null;

        // "add item" modal (dialog)
        Future<Item> dialog = showDialog<Item>(
            context: context,
            builder: (BuildContext context) => new NewItemDialog(),
        );

        dialog.then((Item item) async {
            if (item != null)
                setState(() {
                    item.id = _items.length;
                    _items.add(item);
                });

            String json = Item.listToJson(_items);
            await (await _getItemFile()).writeAsString(json);
        });
        setState((){});
    }


    Map<DismissDirection, double> _dismissThresholds() {
        Map<DismissDirection, double> map = new Map<DismissDirection, double>();
        map.putIfAbsent(DismissDirection.horizontal, () => 0.5);
        return map;
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
}


class ItemView extends StatefulWidget {
    Item item;
    ItemView(this.item);


    @override
    ItemViewState createState() => new ItemViewState(item);
}


class ItemViewState extends State<ItemView> {
    Item item;
    bool editing = false;
    // controller for the item editing view
    TextEditingController itemEditingController;

    ItemViewState(this.item);


    @override
    void initState() {
        super.initState();
        itemEditingController = new TextEditingController(text: item.text);
    }


    @override
    Widget build(BuildContext context) {
        // For comparison purposes, create a DateTime with the start of the current day
        var now = DateTime.now();
        var today = DateTime(now.year, now.month, now.day);

        Widget tile;

        if (editing)
            tile = new ListTile(
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
            );
        else {
            Widget subtitle = null;
            if (item.due != null) {
                if (today.compareTo(item.due) > 0)
                    subtitle = new Text(
                        "Due ${dateFormat.format(item.due)} (overdue)",
                        style: new TextStyle(color: Colors.red)
                    );
                else
                    subtitle = new Text(
                        "Due ${dateFormat.format(item.due)}",
                    );
            }

            tile = new ListTile(
                title: new Text(item.text),
                subtitle: subtitle,
                leading: new Checkbox(
                    value: item.done,
                    onChanged: _setDone,
                ),
                onTap: () {
                    _setDone(!item.done);
                },
                onLongPress: () {
                    _showEditSheet();
                },
            );
        }
        editing = false;
        return tile;
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


    void _setDone(bool value) {
        setState(() {
            item.done = value;
            if (item.reminderSet)
                item.deleteReminder();
        });
        _myHomePageState.update();
    }


    void _setText(String text) {
        setState(() {
            item.text = text;
        });
        _myHomePageState.update();
    }


    void _showEditSheet() {
        Future<bool> sheet = showModalBottomSheet<bool>(
            context: context, 
            builder: (BuildContext context) {
                return new EditItemSheet(item);
            }
        );

        sheet.then((bool editing) {
            if (editing != null)
                setState(() {
                    this.editing = editing;
                });

            setState((){});
        });
    }
}
