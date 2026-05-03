import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dart_ical/dart_ical.dart';
// import 'dart:html' as html;

class SharedPref {
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

/// Replaces accented/special characters with ASCII equivalents
/// so the filename is safe across all platforms.
String sanitizeString(String name) {
  const accents = 'àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ'
      'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸ';
  const replacements = 'aaaaaaaceeeeiiiidnoooooouuuuyby'
      'AAAAAAACEEEEIIIIDNOOOOOOUUUUYBY';

  var result = '';
  for (final char in name.characters) {
    final idx = accents.indexOf(char);
    result += idx >= 0 ? replacements[idx] : char;
  }
  // Remove anything that's not alphanumeric, space, dash or underscore
  return result
      .replaceAll(RegExp(r'[^\w\s\-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '_');
}