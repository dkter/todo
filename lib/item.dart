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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notify.dart';
import 'util.dart';


class Item implements Comparable<Item> {
    int id;
    String text;
    DateTime due;
    bool done = false;
    bool reminderSet = false;
    TimeOfDay reminderTimeOfDay;
    int reminderDaysBefore;

    Item(this.id, this.text, this.due);


    static List<Item> listFromJson(String json_obj) {
        List<Item> items = <Item>[];
        List parsedList = json.decode(json_obj);
        for (var jsonItem in parsedList) {
            Item item = new Item(items.length, jsonItem["text"], null);
            item.done = jsonItem["done"];

            String due = jsonItem["due"];
            if (due != null)
                item.due = DateTime.parse(due);
            else
                item.due = null;

            item.reminderSet = jsonItem["reminderSet"];

            String reminderTimeOfDay = jsonItem["notifTimeOfDay"];
            if (reminderTimeOfDay != null)
                item.reminderTimeOfDay = deserializeTimeOfDay(reminderTimeOfDay);
            else
                item.reminderTimeOfDay = null;

            item.reminderDaysBefore = jsonItem["notifDaysBefore"];

            items.add(item);
        }
        return items;
    }


    static String listToJson(List<Item> items) {
        List<Map> listData = <Map>[];
        for (var item in items){
            var mapData = new Map();
            mapData["text"] = item.text;
            mapData["done"] = item.done;
            mapData["due"] = item.due?.toIso8601String();
            mapData["reminderSet"] = item.reminderSet;
            mapData["notifTimeOfDay"] = serializeTimeOfDay(item.reminderTimeOfDay);
            mapData["notifDaysBefore"] = item.reminderDaysBefore;
            listData.add(mapData);
        }
        String jsonData = json.encode(listData);
        print(jsonData);
        return jsonData;
    }


    int compareTo(Item other) {
        // from most recent due date to least recent (no due date last), then alphabetic, then by id
        // returns -1 if this < other, 1 if other < this
        if (this.due == null) {
            if (other.due == null) {
                if (this.text.compareTo(other.text) != 0)
                    return this.text.compareTo(other.text);
                else {
                    if (this.id < other.id)
                        return -1;
                    else
                        return 1;
                }
            }
            else {
                return 1;
            }
        }
        else if (other.due == null) {
            return -1;
        }
        else if (this.due.compareTo(other.due) < 0) {
            return -1;
        }
        else if (this.due.compareTo(other.due) > 0) {
            return 1;
        }
        else {
            if (this.text.compareTo(other.text) != 0)
                return this.text.compareTo(other.text);
            else {
                if (this.id < other.id)
                    return -1;
                else
                    return 1;
            }
        }
    }


    void setReminder(TimeOfDay reminderTimeOfDay, int reminderDaysBefore) async {
        this.reminderSet = true;
        this.reminderTimeOfDay = reminderTimeOfDay;
        this.reminderDaysBefore = reminderDaysBefore;

        DateTime reminderDate = this.due.subtract(new Duration(days: reminderDaysBefore));
        DateTime reminderTime = new DateTime(reminderDate.year,
                                          reminderDate.month,
                                          reminderDate.day,
                                          reminderTimeOfDay.hour,
                                          reminderTimeOfDay.minute);
        print("Setting reminder for $reminderTime");

        await Notify.notificationPlugin.schedule(
            this.id,
            this.text,
            "Due " + (reminderDaysBefore == 0? "today" :
                      (reminderDaysBefore == 1? "tomorrow" :
                       "in $reminderDaysBefore days")),
            reminderTime,
            Notify.platformChannelSpecifics);
    }

    void updateReminder([TimeOfDay reminderTimeOfDay, int reminderDaysBefore]) async {
        reminderTimeOfDay ??= this.reminderTimeOfDay;
        reminderDaysBefore ??= this.reminderDaysBefore;
        this.reminderTimeOfDay = reminderTimeOfDay;
        this.reminderDaysBefore = reminderDaysBefore;

        // cancel old reminder
        this.deleteReminder();
        this.reminderSet = true;

        DateTime reminderDate = this.due.subtract(new Duration(days: reminderDaysBefore));
        DateTime reminderTime = new DateTime(reminderDate.year,
                                          reminderDate.month,
                                          reminderDate.day,
                                          reminderTimeOfDay.hour,
                                          reminderTimeOfDay.minute);
        print("Setting reminder for $reminderTime");

        await Notify.notificationPlugin.schedule(
            this.id,
            this.text,
            "Due " + (this.reminderDaysBefore == 0? "today" :
                      (this.reminderDaysBefore == 1? "tomorrow" :
                       "in ${this.reminderDaysBefore} days")),
            reminderTime,
            Notify.platformChannelSpecifics);
    }

    void deleteReminder() async {
        this.reminderSet = false;
        await Notify.notificationPlugin.cancel(this.id);   
    }
}