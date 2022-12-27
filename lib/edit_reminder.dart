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
import 'util.dart';

class EditReminderDialog extends StatefulWidget {
    final Item item;
    const EditReminderDialog(this.item);

    @override
    State createState() => new EditReminderState(this.item);
}


class EditReminderState extends State<EditReminderDialog> {
    final Item item;
    EditReminderState(this.item);

    TextEditingController itemTextController;
    bool reminderSet;
    TimeOfDay reminderTime;
    int reminderDaysBefore;


    @override
    void initState() {
        super.initState();
        this.itemTextController = new TextEditingController();
        this.reminderSet = false;
        this.reminderTime = this.item.reminderTimeOfDay.replacing();  // calling replacing with no arguments copies the object
        this.reminderDaysBefore = this.item.reminderDaysBefore;
    }


    @override
    Widget build(BuildContext context) {
        return new AlertDialog(
            title: Text(
                (this.item.reminderSet? "Edit reminder" : "Add reminder"),
            ),
            content: _reminderSettings(context),
            actions: <Widget>[
                new TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.red,
                    ),
                    child: new Text("Delete"),
                    onPressed: _delete(context),
                ),
                new TextButton(
                    child: new Text("Cancel"),
                    onPressed: Navigator.of(context).pop,  // dismiss dialog
                ),
                new TextButton(
                    child: new Text("Ok"),
                    onPressed: _ok(context),
                ),
            ],
        );
    }


    Widget _reminderSettings(BuildContext context) {
        return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                new Text("Reminder"),
                // Set number of days before
                this._reminderDaysBeforeField(context),
                // Set time
                this._reminderTimeField(context),
            ],
        );
    }


    Widget _reminderDaysBeforeField(BuildContext context) {
        // Display and slider to select the number of days before the due date to show the reminder
        return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        new TextButton(
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


    Widget _reminderTimeField(BuildContext context) {
        // Display and button to show time picker for reminder
        return new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                new TextButton(
                    child: new Text("Time: ${reminderTime.format(context)}"),
                    onPressed: _showTimePicker,
                ),
                new TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.blue,
                    ),
                    child: new Text("Change"),
                    onPressed: _showTimePicker,
                ),
            ],
        );
    }


    void _showTimePicker() {
        Future<TimeOfDay> picker = showTimePicker(
            context: context,
            initialTime: TimeOfDay.now());

        picker.then((TimeOfDay time) {
            setState(() {
                reminderTime = time ?? reminderTime;   // if the user pressed cancel, don't delete the existing time
            });
        });
    }


    Function _delete(BuildContext context) {
        // When the user presses the delete button, delete the reminder entirely
        return () {
            if (this.reminderTime != null) {
                item.deleteReminder();
            }

            Navigator.pop(context);  // dismiss dialog
        };
    }


    Function _ok(BuildContext context) {
        return () {
            if (this.reminderTime != null) {
                item.updateReminder(
                    this.reminderTime,
                    this.reminderDaysBefore);
            }

            Navigator.pop(context);  // dismiss dialog
        };
    }
}
