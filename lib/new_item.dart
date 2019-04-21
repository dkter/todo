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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'item.dart';

var dateFormat = new DateFormat.yMMMd();

class NewItemDialog extends StatefulWidget {
    @override
    State createState() => new NewItemState();
}


class NewItemState extends State<NewItemDialog> {
    TextEditingController itemTextController;
    DateTime due;


    @override
    void initState() {
        super.initState();
        itemTextController = new TextEditingController();
        due = null;
    }


    @override
    Widget build(BuildContext context) {
        return new AlertDialog(
            title: const Text("Add an item"),
            content: new SingleChildScrollView(
                child: new ListBody(
                    children: <Widget>[
                        new TextField(
                            decoration: new InputDecoration(labelText: "Title"),
                            controller: itemTextController,
                            onChanged: (String s){setState((){});},
                        ),
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                due != null
                                    ? new FlatButton(
                                        child: new Text("Due " + dateFormat.format(due)),
                                        onPressed: _showPicker,
                                      )
                                    : new Center(),
                                new FlatButton(
                                    textColor: Colors.blue,
                                    child: new Text(
                                        due == null? "Add due date" : "Change",
                                    ),
                                    onPressed: _showPicker,
                                ),
                            ],
                        ),
                    ],
                ),
            ),
            actions: <Widget>[
                new FlatButton(
                    child: new Text("Cancel"),
                    onPressed: Navigator.of(context).pop,  // dismiss dialog
                ),
                new FlatButton(
                    child: new Text("Ok"),
                    onPressed: itemTextController.text == "" ? null : () {
                        var item = new Item(0, itemTextController.text, due);

                        if (this.due != null)
                            item.setNotification(
                                new TimeOfDay(hour: 15, minute: 0),
                                1);
                            
                        setState(() {
                            itemTextController.text = "";  // clear textbox,
                        });
                        Navigator.pop<Item>(context, item);  // dismiss dialog
                    },
                ),
            ],
        );
    }


    void _showPicker() {
        DateTime now = DateTime.now();
        Future<DateTime> picker = showDatePicker(
            context: context,
            initialDate: now,
            firstDate: now,
            lastDate: DateTime(2030));
        picker.then((DateTime date) {
            setState(() {
                due = date;
            });
        });
    }
}
