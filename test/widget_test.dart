// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spotify/main.dart';

void main() {
  Map<String, dynamic> params = {"id": 1, "age": "10"};
  var where = params.keys.map(((key) => "$key = ?")).toList();

  print("where: ${where.join(" and ")}");
  print("whereArgs: ${params.values.toList()}");
}
