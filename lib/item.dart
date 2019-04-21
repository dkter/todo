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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'notify.dart';


class Item {
    int id;
    String text;
    DateTime due;
    bool done = false;

    Item(this.id, this.text, this.due);


    static List<Item> listFromJson(String json_obj) {
        List<Item> items = <Item>[];
        List parsedList = json.decode(json_obj);
        for (var jsonItem in parsedList) {
            Item item = new Item(items.length, jsonItem["text"], null);
            item.done = jsonItem["done"];

            String due = jsonItem["due"];
            if (due != null)
                item.due = DateTime.parse(jsonItem["due"]);
            else
                item.due = null;
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
            mapData["due"] = item.due == null ? null : item.due.toIso8601String();
            listData.add(mapData);
        }
        String jsonData = json.encode(listData);
        print(jsonData);
        return jsonData;
    }


    void setNotification(TimeOfDay time, int daysBefore) async {
        DateTime notifDate = this.due.subtract(new Duration(days: daysBefore));
        DateTime notifTime = new DateTime(notifDate.year, notifDate.month, notifDate.day, time.hour, time.minute);

        await Notify.notificationPlugin.schedule(
            this.id,
            this.text,
            "Due " + (daysBefore == 0? "today" :
                      (daysBefore == 1? "tomorrow" :
                       "in $daysBefore days")),
            notifTime,
            Notify.platformChannelSpecifics);
    }
}