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
    bool reminderSet;
    TimeOfDay reminderTime;
    int reminderDaysBefore;


    @override
    void initState() {
        super.initState();
        this.itemTextController = new TextEditingController();
        this.due = null;
        this.reminderSet = false;
        this.reminderTime = new TimeOfDay(hour:15, minute:0);
        this.reminderDaysBefore = 1;
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
                                        onPressed: _showDatePicker,
                                      )
                                    : new Center(),
                                new FlatButton(
                                    textColor: Colors.blue,
                                    child: new Text(
                                        due == null? "Add due date" : "Change",
                                    ),
                                    onPressed: _showDatePicker,
                                ),
                            ],
                        ),
                        (due != null
                            ? (this.reminderSet
                                ? this.reminderSettings(context)
                                : new FlatButton(
                                    textColor: Colors.blue,
                                    child: new Text("Add reminder"),
                                    onPressed: (){setState((){this.reminderSet = true;});},
                                  )
                              )
                            : new Center()
                        )
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

                        if (this.reminderTime != null) {
                            item.setNotification(
                                this.reminderTime,
                                this.reminderDaysBefore);
                        }

                        setState(() {
                            itemTextController.text = "";  // clear textbox,
                        });
                        Navigator.pop<Item>(context, item);  // dismiss dialog
                    },
                ),
            ],
        );
    }


    Widget reminderSettings(BuildContext context) {
        return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                new Text("Reminder"),
                // Set number of days before
                new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        new FlatButton(
                            child: new Text(reminderDaysBefore == 1? "1 day before due date" : "$reminderDaysBefore days before due date"),
                            onPressed: _showTimePicker,
                        ),
                        /*new FlatButton(
                            textColor: Colors.blue,
                            child: new Text("Change"),
                            onPressed: _showTimePicker,
                        ),*/
                    ],
                ),
                new Slider(
                    value: this.reminderDaysBefore * 1.0,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    onChanged: (double value) {
                        setState((){
                            this.reminderDaysBefore = value.round();
                        });
                    }
                ),
                // Set time
                new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        new FlatButton(
                            child: new Text("Time: ${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}"),
                            onPressed: _showTimePicker,
                        ),
                        new FlatButton(
                            textColor: Colors.blue,
                            child: new Text("Change"),
                            onPressed: _showTimePicker,
                        ),
                    ],
                ),
            ],
        );
    }


    void _showDatePicker() {
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

    void _showTimePicker() {
        Future<TimeOfDay> picker = showTimePicker(
            context: context,
            initialTime: TimeOfDay.now());
        picker.then((TimeOfDay time) {
            setState(() {
                reminderTime = time ?? reminderTime;
            });
        });
    }
}
