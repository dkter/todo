import "package:flutter/material.dart";
import "package:intl/intl.dart";

var dateFormat = new DateFormat.yMMMd();
const int DUE_DATE_LIMIT = 365 * 100;  // days


String serializeTimeOfDay(TimeOfDay tod) {
    // Convert Flutter's TimeOfDay object into a string for JSON serialization
    // H:M 24-hour time, for simplicity
    if (tod == null)
        return null;
    return "${tod.hour}:${tod.minute.toString().padLeft(2, '0')}";
}


TimeOfDay deserializeTimeOfDay(String serialized) {
    // Convert the 24-hour HH:MM time back into a TimeOfDay object
    var hm = serialized.split(":");
    var hour = int.parse(hm[0]);
    var minute = int.parse(hm[1]);
    return TimeOfDay(hour: hour, minute: minute);
}
