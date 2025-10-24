import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dart_ical/dart_ical.dart';
// import 'dart:html' as html;

class SharedPref{
  
  static void setSharedValueBool(
      String key,
      bool value,
    ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  static Future<bool?> getSharedValueBool(
      String key,
    ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value = prefs.getBool(key);
    return value;
  }

  static setThemeMode(ThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      prefs.setString('themeMode', 'light');
    } else if (mode == ThemeMode.dark) {
      prefs.setString('themeMode', 'dark');
    } else {
      prefs.setString('themeMode', 'system');
    }
  }

  static Future<ThemeMode> getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeMode = prefs.getString('themeMode');
    if (themeMode == 'light') {
      return ThemeMode.light;
    } else if (themeMode == 'dark') {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }
}

// void downloadCalendarEvent() {
//   final event = ICalEvent(
//     summary: 'My Event',
//     description: 'Description here',
//     start: DateTime.now(),
//     end: DateTime.now().add(Duration(hours: 1)),
//     location: 'Online',
//   );

//   final calendar = ICal([event]);
//   final calendarData = calendar.serialize();

//   final bytes = utf8.encode(calendarData);
//   final blob = html.Blob([bytes]);
//   final url = html.Url.createObjectUrlFromBlob(blob);

//   final anchor = html.AnchorElement(href: url)
//     ..setAttribute("download", "event.ics")
//     ..click();

//   html.Url.revokeObjectUrl(url);
// }