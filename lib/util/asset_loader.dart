import 'package:flutter/services.dart';

Future<String> readAsset(String filePath) async {
  return await rootBundle.loadString(filePath);
}

T? getItemFromArr<T>(
    List<dynamic> values, int index) {
  T? res;
  int length = values.length;
  for (int idx = 0; idx < length; idx++) {
    if (idx == index) {
      res = values[idx];
      break;
    }
  }
  return res;
}
