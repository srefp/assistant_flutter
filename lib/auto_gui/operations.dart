import 'dart:math';

import 'package:flutter_auto_gui_windows/flutter_auto_gui_windows.dart';

const factor = 65535;

final api = FlutterAutoGuiWindows();

/// 等待
Future<void> delay(double seconds) async {
  await Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()));
}

/// 鼠标点击
Future<void> click({List<int>? point, double seconds = 0}) async {
  if (point != null) {
    await move(point: point, seconds: 0);
  }
  await api.click();
  await delay(seconds);
}

/// 移动鼠标
Future<void> move({required List<int> point, double seconds = 0}) async {
  await api.moveTo(point: Point(point[0], point[1]));
  delay(seconds);
}
