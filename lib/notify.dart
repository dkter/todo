 /* 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 * This Source Code Form is "Incompatible With Secondary Licenses", as
 * defined by the Mozilla Public License, v. 2.0.
 */


import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';


class Notify {
    static Future<dynamic> onSelectNotification(String text) {

    }

    static FlutterLocalNotificationsPlugin notificationPlugin = new FlutterLocalNotificationsPlugin();

    static var initializationSettingsAndroid =
            new AndroidInitializationSettings('ic_notif');
    static var initializationSettingsIOS = new IOSInitializationSettings();
    static var initializationSettings = new InitializationSettings(
            initializationSettingsAndroid, initializationSettingsIOS);

    static var androidChannelSpecifics = new AndroidNotificationDetails(
            "reminders",
            "Task reminders",
            "Scheduled reminders to complete tasks",
            importance: Importance.Max,
            priority: Priority.High);

    static var iOSChannelSpecifics = new IOSNotificationDetails();

    static var platformChannelSpecifics = new NotificationDetails(
            androidChannelSpecifics,
            iOSChannelSpecifics);

    static void initialize() {
        // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
        Notify.notificationPlugin.initialize(
            Notify.initializationSettings,
            onSelectNotification: Notify.onSelectNotification);
    }
}