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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'item.dart';
import 'util.dart';

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
                        this.titleField(context),
                        this.dueDateField(context),
                        this.reminderField(context),
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
                    onPressed: ok(context),
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
                reminderDaysBeforeField(context),
                // Set time
                reminderTimeField(context),
            ],
        );
    }


    Widget titleField(BuildContext context) {
        return new TextField(
            decoration: new InputDecoration(labelText: "Title"),
            controller: itemTextController,
            onChanged: (String s){setState((){});},
        );
    }


    Widget dueDateField(BuildContext context) {
        if (due == null)
            return new FlatButton(
                textColor: Colors.blue,
                child: new Text("Add due date"),
                onPressed: _showDatePicker,
            );
        else
            return new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    new FlatButton(
                        child: new Text("Due " + dateFormat.format(due)),
                        onPressed: _showDatePicker,
                    ),
                    new FlatButton(
                        textColor: Colors.blue,
                        child: new Text("Change"),
                        onPressed: _showDatePicker,
                    ),
                ],
            );
    }


    Widget reminderField(BuildContext context) {
        if (due != null) {
            if (this.reminderSet)
                return this.reminderSettings(context);
            else
                return new FlatButton(
                    textColor: Colors.blue,
                    child: new Text("Add reminder"),
                    onPressed: (){ setState((){ this.reminderSet = true; }); },
                );
        }
        else
            return new Center();
    }


    Widget reminderDaysBeforeField(BuildContext context) {
        return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        new FlatButton(
                            child: new Text(reminderDaysBefore == 1? "1 day before due date" : "$reminderDaysBefore days before due date"),
                            onPressed: _showTimePicker,
                        ),
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
            ],
        );
    }


    Widget reminderTimeField(BuildContext context) {
        return new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                new FlatButton(
                    child: new Text("Time: ${reminderTime.format(context)}"),
                    onPressed: _showTimePicker,
                ),
                new FlatButton(
                    textColor: Colors.blue,
                    child: new Text("Change"),
                    onPressed: _showTimePicker,
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
            if (date != null)
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

    Function ok(BuildContext context) {
        if (itemTextController.text != "") {
            return () {
                    var item = new Item(0, itemTextController.text, due);

                    if (this.reminderSet) {
                        item.setReminder(
                            this.reminderTime,
                            this.reminderDaysBefore);
                    }

                    setState(() {
                        itemTextController.text = "";  // clear textbox,
                    });
                    Navigator.pop<Item>(context, item);  // dismiss dialog
            };
        }
        else
            return null;  // if the onPressed callback is null, the button is disabled
    }
}
