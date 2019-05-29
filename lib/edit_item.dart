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
import 'custom_icons_icons.dart';
import 'edit_reminder.dart';
import 'item.dart';
import 'new_item.dart';
import 'util.dart';


class EditItemSheet extends StatefulWidget {
    final Item item;
    const EditItemSheet(this.item);


    @override
    State createState() => new EditItemState(item);
}


class EditItemState extends State<EditItemSheet> {
    static final double ICON_WIDTH = 16.0;

    final Item item;
    EditItemState(this.item);

    bool reminderSet = false;
    TimeOfDay reminderTime;
    int reminderDaysBefore;


    @override
    Widget build(BuildContext context) {
        return new Container(
            margin: const EdgeInsets.all(8.0),
            child: new Column(
                mainAxisSize: MainAxisSize.min,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    this.titleField(context),
                    this.dueDateField(context),
                    this.reminderField(context),
                ],
            ),
        );
    }


    Widget titleField(BuildContext context) {
        return new ListTile(
            leading: new Container(
                width: ICON_WIDTH,
                alignment: Alignment.center,
                child: new Icon(Icons.edit),
            ),
            title: new Text("Edit title"),
            subtitle: new Text(item.text),
            onTap: () {
                Navigator.pop(context, true);
            },
        );
    }


    Widget dueDateField(BuildContext context) {
        if (item.due == null)
            return new ListTile(
                leading: new Container(
                    width: ICON_WIDTH,
                    alignment: Alignment.center,
                    child: new Icon(CustomIcons.calendar_add),
                ),
                title: new Text("Add due date"),
                onTap: _showDatePicker,
            );
        else
            return new ListTile(
                leading: new Container(
                    width: ICON_WIDTH,
                    alignment: Alignment.center,
                    child: new Icon(Icons.event),
                ),
                title: new Text("Edit due date"),
                subtitle: new Text(dateFormat.format(item.due)),
                trailing: new IconButton(
                    icon: new Icon(
                        Icons.delete,
                    ),
                    alignment: Alignment.centerRight,
                    tooltip: "Remove due date",
                    onPressed: _removeDueDate,
                ),
                onTap: _showDatePicker,
            );
    }


    Widget reminderField(BuildContext context) {
        if (item.due != null)
            if (!item.reminderSet)
                return new ListTile(
                    leading: new Container(
                        width: ICON_WIDTH,
                        alignment: Alignment.center,
                        child: new Icon(Icons.alarm_add),
                    ),
                    title: new Text("Add reminder"),
                    onTap: _showEditReminder,
                );
            else
                return new ListTile(
                    leading: new Container(
                        width: ICON_WIDTH,
                        alignment: Alignment.center,
                        child: new Icon(Icons.alarm),
                    ),
                    title: new Text("Edit reminder"),
                    subtitle: new Text("${item.reminderDaysBefore} days before at ${item.reminderTimeOfDay.format(context)}"),
                    trailing: new IconButton(
                        icon: new Icon(
                            Icons.delete,
                        ),
                        alignment: Alignment.centerRight,
                        tooltip: "Remove reminder",
                        onPressed: _removeReminder,
                    ),
                    onTap: _showEditReminder,
                );
        else
            return new Center();
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
                    item.due = date;
                    if (item.reminderSet)
                        item.updateReminder();
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

    void _removeDueDate() {
        setState(() {
            item.due = null;
            if (item.reminderSet) {
                item.deleteReminder();
            }
        });
    }

    void _removeReminder() {
        setState(() {
            item.deleteReminder();
        });
    }
}
