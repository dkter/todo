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
import 'dart:convert';

class Item {
    int id;
    String text;
    bool done = false;

    Item(this.id, this.text);

    static List<Item> listFromJson(String json_obj) {
        List<Item> items = <Item>[];
        List parsedList = json.decode(json_obj);
        for (var jsonItem in parsedList) {
            Item item = new Item(items.length, jsonItem["text"]);
            item.done = jsonItem["done"];
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
            listData.add(mapData);
            print(item.id);
        }
        String jsonData = json.encode(listData);
        print(jsonData);
        return jsonData;
    }
}