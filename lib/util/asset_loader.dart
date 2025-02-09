import 'package:flutter/services.dart';

Future<String> readAsset(String filePath) async {
  return await rootBundle.loadString(filePath);
}
