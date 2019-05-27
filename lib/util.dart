import "package:flutter/material.dart";
import "package:intl/intl.dart";

var dateFormat = new DateFormat.yMMMd();

String serializeTimeOfDay(TimeOfDay tod) {
    if (tod == null) return null;
    return "${tod.hour}:${tod.minute.toString().padLeft(2, '0')}";
}

TimeOfDay deserializeTimeOfDay(String serialized) {
    var hm = serialized.split(":");
    var hour = int.parse(hm[0]);
    var minute = int.parse(hm[1]);
    return TimeOfDay(hour: hour, minute: minute);
}