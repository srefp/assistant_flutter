import 'package:flutter/services.dart';
import 'package:path/path.dart';

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

const String assetsPath = 'data/flutter_assets/assets';

/// 获取assets下的文件
String getAssets(String str) {
  return join(assetsPath, str);
}
