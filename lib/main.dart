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

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            title: 'Todo',
            theme: new ThemeData(
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
                // counter didn't reset back to zero; the application is not restarted.
                primarySwatch: Colors.blue,
            ),
            home: new MyHomePage(title: 'Todo'),
        );
    }
}

_MyHomePageState _myHomePageState = new _MyHomePageState();

class MyHomePage extends StatefulWidget {
    MyHomePage({Key key, this.title}) : super(key: key);

    // This widget is the home page of your application. It is stateful, meaning
    // that it has a State object (defined below) that contains fields that affect
    // how it looks.

    // This class is the configuration for the state. It holds the values (in this
    // case the title) provided by the parent (in this case the App widget) and
    // used by the build method of the State. Fields in a Widget subclass are
    // always marked "final".

    final String title;

    @override
    _MyHomePageState createState() => _myHomePageState;
}

class _MyHomePageState extends State<MyHomePage> {
    List<Item> _items = <Item>[];

    @override
    void initState() {
        super.initState();
        _readItemData().then((List<Item> items) {
            setState(() {
                _items = items;
            });
        });
    }

    Map<DismissDirection, double> _dismissThresholds() {
        Map<DismissDirection, double> map = new Map<DismissDirection, double>();
        map.putIfAbsent(DismissDirection.horizontal, () => 0.5);
        return map;
    }

    Future<Null> _addItem() async {
        setState(() {
            // This call to setState tells the Flutter framework that something has
            // changed in this State, which causes it to rerun the build method below
            // so that the display can reflect the updated values. If we changed
            // _counter without calling setState(), then the build method would not be
            // called again, and so nothing would appear to happen.
            _items.add(new Item(_items.length, ""));
        });
        String json = Item.listToJson(_items);
        await (await _getItemFile()).writeAsString(json);
    }

    Future<File> _getItemFile() async {
        String dir = (await getApplicationDocumentsDirectory()).path;
        return new File("$dir/counter.txt");
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
                    content: Text(item.text + " deleted"),
                    action: SnackBarAction(
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
        // This method is rerun every time setState is called, for instance as done
        // by the _incrementCounter method above.
        //
        // The Flutter framework has been optimized to make rerunning build methods
        // fast, so that you can just rebuild anything that needs updating rather
        // than having to individually change instances of widgets.
        return new Scaffold(
            appBar: new AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: new Text(widget.title),
            ),
            body: _buildItems(),
            floatingActionButton: new FloatingActionButton(
                onPressed: _addItem,
                tooltip: 'Add item',
                child: new Icon(Icons.add),
            ), // This trailing comma makes auto-formatting nicer for build methods.
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
    ItemViewState(this.item);

    void _toggleDone(bool value) {
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
        Widget tile = (item.text == "") || editing 
          ? new ListTile(
                title: new TextField(
                    controller: new TextEditingController(text: item.text),
                    autofocus: true,
                    onSubmitted: _setText,
                ),
                // trailing: new IconButton(
                //     icon: new Icon(Icons.delete),
                //     tooltip: 'Delete',
                //     onPressed: _delete,
                // ),
            )
          : new ListTile(
                title: new Text(item.text),
                leading: new Checkbox(
                    value: item.done,
                    onChanged: _toggleDone,
                ),
                onTap: () {
                    _toggleDone(!item.done);
                },
                onLongPress: () {
                    setState(() {
                        editing = true;
                    });
                }
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
