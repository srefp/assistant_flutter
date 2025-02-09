import 'package:flutter_auto_gui/flutter_auto_gui.dart';

/// 鼠标点击
Future<void> click(double delay) async {
  await FlutterAutoGUI.click();
  await Future.delayed(Duration(microseconds: (delay * 1000).toInt()));
}
