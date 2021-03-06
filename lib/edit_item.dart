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

    bool reminderSet = false;
    TimeOfDay reminderTime;
    int reminderDaysBefore;


    EditItemState(this.item);


    @override
    Widget build(BuildContext context) {
        return new Container(
            margin: const EdgeInsets.all(8.0),
            child: new Column(
                mainAxisSize: MainAxisSize.min,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    this._titleField(context),
                    this._dueDateField(context),
                    this._reminderField(context),
                ],
            ),
        );
    }


    Widget _titleField(BuildContext context) {
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


    Widget _dueDateField(BuildContext context) {
        if (item.due == null)
            // Button to add a due date
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
            // Button to edit the existing due date
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


    Widget _reminderField(BuildContext context) {
        if (item.due != null)
            if (!item.reminderSet)
                // Button to add a reminder
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
                // Button to edit the existing reminder
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
            // If there's no due date set, there shouldn't be a reminder field
            return new Center();
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


    void _showDatePicker() {
        DateTime now = DateTime.now();
        Future<DateTime> picker = showDatePicker(
            context: context,
            initialDate: this.item.due ?? now,                          // existing due date if set, otherwise now
            firstDate: now.subtract(new Duration(days: 1)),             // it actually starts the day after the passed day, for some reason
            lastDate: now.add(new Duration(days: DUE_DATE_LIMIT)));     // DUE_DATE_LIMIT days from today

        picker.then((DateTime date) {
            if (date != null)
                setState(() {
                    item.due = date;
                    if (item.reminderSet)
                        item.updateReminder();      // update relative reminder now that there's a new date
                });
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
