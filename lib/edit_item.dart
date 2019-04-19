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
import 'item.dart';
import 'new_item.dart';


class EditItemSheet extends StatefulWidget {
    final Item item;
    const EditItemSheet(this.item);


    @override
    State createState() => new EditItemState(item);
}


class EditItemState extends State<EditItemSheet> {
    final Item item;
    EditItemState(this.item);


    @override
    Widget build(BuildContext context) {
        return new BottomSheet(
            builder: (BuildContext context) => new Container(
                margin: const EdgeInsets.all(16.0),
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        new Row(
                            children: <Widget>[
                                new Text(
                                    item.text,
                                    style: new TextStyle(fontSize: 24.0)),
                                new FlatButton(
                                    textColor: Colors.blue,
                                    child: new Text("Edit"),
                                    onPressed: () {
                                        Navigator.pop(context, [item, true]);
                                    },
                                ),
                            ],
                        ),
                        new Row(
                            children: <Widget>[
                                item.due != null
                                    ? new Text("Due " + dateFormat.format(item.due))
                                    : new Center(),
                                new FlatButton(
                                    textColor: Colors.blue,
                                    child: new Text(
                                        item.due == null? "Add due date" : "Change",
                                    ),
                                    onPressed: _showPicker,
                                ),
                            ],
                        ),
                    ],
                ),
            ),
            onClosing: () {
                Navigator.pop(context, [item, false]);
            },
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
                item.due = date;
            });
        });
    }
}
