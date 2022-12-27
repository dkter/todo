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
                        this._titleField(context),
                        this._dueDateField(context),
                        this._reminderField(context),
                    ],
                ),
            ),
            actions: <Widget>[
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


    Widget _titleField(BuildContext context) {
        return new TextField(
            decoration: new InputDecoration(labelText: "Title"),
            controller: itemTextController,
            onChanged: (String s){setState((){});},  // refresh the state
        );
    }


    Widget _dueDateField(BuildContext context) {
        if (due == null)
            return new TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.blue,
                ),
                child: new Text("Add due date"),
                onPressed: _showDatePicker,
            );
        else
            // Display for due date and button to select the date
            return new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    new TextButton(
                        child: new Text("Due " + dateFormat.format(due)),
                        onPressed: _showDatePicker,
                    ),
                    new TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.blue,
                        ),
                        child: new Text("Change"),
                        onPressed: _showDatePicker,
                    ),
                ],
            );
    }


    Widget _reminderField(BuildContext context) {
        if (due != null) {
            if (this.reminderSet)
                // Entire settings widget
                return this._reminderSettings(context);
            else
                // Button to add a reminder
                return new TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.blue,
                    ),
                    child: new Text("Add reminder"),
                    onPressed: (){ setState((){ this.reminderSet = true; }); },
                );
        }
        else
            return new Center();
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


    void _showDatePicker() {
        DateTime now = DateTime.now();
        Future<DateTime> picker = showDatePicker(
            context: context,
            initialDate: this.due ?? now,                               // working due date if set, otherwise now
            firstDate: now.subtract(new Duration(days: 1)),             // it actually starts the day after the passed day, for some reason
            lastDate: now.add(new Duration(days: DUE_DATE_LIMIT)));     // DUE_DATE_LIMIT days from today

        picker.then((DateTime date) {
            if (date != null)
                setState(() {
                    due = date;  // will be used to create an item if the user presses the Ok button
                });
        });
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

    Function _ok(BuildContext context) {
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
