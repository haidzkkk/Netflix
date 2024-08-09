import 'package:flutter/foundation.dart';

void printData(String? context){
  if (kDebugMode) {
    print(context ?? "");
  }
}