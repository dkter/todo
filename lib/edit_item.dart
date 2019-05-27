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
import 'item.dart';
import 'new_item.dart';
import 'edit_reminder.dart';
import 'util.dart';


class EditItemSheet extends StatefulWidget {
    final Item item;
    const EditItemSheet(this.item);


    @override
    State createState() => new EditItemState(item);
}


class EditItemState extends State<EditItemSheet> {
    final Item item;
    EditItemState(this.item);

    bool reminderSet = false;
    TimeOfDay reminderTime;
    int reminderDaysBefore;


    @override
    Widget build(BuildContext context) {
        return new Container(
            margin: const EdgeInsets.all(16.0),
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    this.titleField(context),
                    this.dueDateField(context),
                    this.reminderField(context),
                ],
            ),
        );
    }


    Widget titleField(BuildContext context) {
        return new Row(
            children: <Widget>[
                new Text(
                    item.text,
                    style: new TextStyle(fontSize: 24.0)),
                new FlatButton(
                    textColor: Colors.blue,
                    child: new Text("Edit"),
                    onPressed: () {
                        Navigator.pop(context, true);
                    },
                ),
            ],
        );
    }


    Widget dueDateField(BuildContext context) {
        return new Row(
            children: <Widget>[
                item.due != null
                    ? new Text("Due " + dateFormat.format(item.due))
                    : new Center(),
                new FlatButton(
                    textColor: Colors.blue,
                    child: new Text(
                        item.due == null? "Add due date" : "Change",
                    ),
                    onPressed: _showDatePicker,
                ),
            ],
        );
    }


    Widget reminderField(BuildContext context) {
        if (item.reminderSet)
            return new Row(
                children: <Widget>[
                    new Text("Reminder set for ${item.notifDaysBefore} day${item.notifDaysBefore == 1? '' : 's'} before at ${item.notifTimeOfDay.format(context)}"),
                    new FlatButton(
                        textColor: Colors.blue,
                        child: new Text("Edit"),
                        onPressed: _showEditReminder,
                    ),
                ],
            );
        else
            return new FlatButton(
                textColor: Colors.blue,
                child: new Text("Add reminder"),
                onPressed: _showEditReminder,
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
                item.due = date;
                if (item.reminderSet)
                    item.updateNotification();
            });
        });
    }

    void _showEditReminder() {
        // "add item" modal (dialog)
        Future dialog = showDialog(
            context: context,
            builder: (BuildContext context) => new EditReminderDialog(this.item),
        );

        dialog.then((dynamic) async {
            setState((){});
        });
    }
}
