 /* 
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


import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class Notify {
    static void onSelectNotification(NotificationResponse details) {

    }

    static FlutterLocalNotificationsPlugin notificationPlugin = new FlutterLocalNotificationsPlugin();

    static var initializationSettingsAndroid =
            new AndroidInitializationSettings('ic_notif');
    static var initializationSettingsDarwin = new DarwinInitializationSettings();
    static var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
    );

    static var androidChannelSpecifics = new AndroidNotificationDetails(
            "reminders",
            "Task reminders",
            channelDescription: "Scheduled reminders to complete tasks",
            importance: Importance.max,
            priority: Priority.high);

    //static var iOSChannelSpecifics = new IOSNotificationDetails();

    static var platformChannelSpecifics = new NotificationDetails(
            android: androidChannelSpecifics);//,
            //iOS: iOSChannelSpecifics);

    static void initialize() {
        // Initialize the flutter_local_notifications plugin
        Notify.notificationPlugin.initialize(
            Notify.initializationSettings,
            onDidReceiveNotificationResponse: Notify.onSelectNotification);
    }
}