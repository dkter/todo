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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'notify.dart';
import 'util.dart';


class Item {
    int id;
    String text;
    DateTime due;
    bool done = false;
    TimeOfDay notifTimeOfDay;
    int notifDaysBefore;

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

            String notifTimeOfDay = jsonItem["notifTimeOfDay"];
            if (notifTimeOfDay != null)
                item.notifTimeOfDay = deserializeTimeOfDay(notifTimeOfDay);
            else
                item.notifTimeOfDay = null;

            item.notifDaysBefore = jsonItem["notifDaysBefore"];

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
            mapData["notifTimeOfDay"] = serializeTimeOfDay(item.notifTimeOfDay);
            mapData["notifDaysBefore"] = item.notifDaysBefore;
            listData.add(mapData);
        }
        String jsonData = json.encode(listData);
        print(jsonData);
        return jsonData;
    }


    void setNotification(TimeOfDay notifTimeOfDay, int notifDaysBefore) async {
        this.notifTimeOfDay = notifTimeOfDay;
        this.notifDaysBefore = notifDaysBefore;

        DateTime notifDate = this.due.subtract(new Duration(days: notifDaysBefore));
        DateTime notifTime = new DateTime(notifDate.year,
                                          notifDate.month,
                                          notifDate.day,
                                          notifTimeOfDay.hour,
                                          notifTimeOfDay.minute);
        print("Setting reminder for $notifTime");

        await Notify.notificationPlugin.schedule(
            this.id,
            this.text,
            "Due " + (notifDaysBefore == 0? "today" :
                      (notifDaysBefore == 1? "tomorrow" :
                       "in $notifDaysBefore days")),
            notifTime,
            Notify.platformChannelSpecifics);
    }

    void updateNotification() async {
        // cancel old notification
        this.deleteNotification();

        DateTime notifDate = this.due.subtract(new Duration(days: this.notifDaysBefore));
        DateTime notifTime = new DateTime(notifDate.year,
                                          notifDate.month,
                                          notifDate.day,
                                          this.notifTimeOfDay.hour,
                                          this.notifTimeOfDay.minute);
        print("Setting reminder for $notifTime");

        await Notify.notificationPlugin.schedule(
            this.id,
            this.text,
            "Due " + (this.notifDaysBefore == 0? "today" :
                      (this.notifDaysBefore == 1? "tomorrow" :
                       "in ${this.notifDaysBefore} days")),
            notifTime,
            Notify.platformChannelSpecifics);
    }

    void deleteNotification() async {
        await Notify.notificationPlugin.cancel(this.id);   
    }
}