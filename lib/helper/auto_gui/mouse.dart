import 'dart:math';
import 'dart:ui';

import 'package:assistant/helper/screen/screen_manager.dart';
import 'package:flutter_auto_gui_windows/flutter_auto_gui_windows.dart';
import 'package:win32/win32.dart';

import '../../app/config/app_config.dart';

final _api = FlutterAutoGuiWindows();

class Mouse {
  Future<void> leftButtonDown() async {
    await _api.mouseDown(button: MouseButton.left);
  }

  Future<void> leftButtonUp() async {
    await _api.mouseUp(button: MouseButton.left);
  }

  Future<void> moveMouseBy(List<int> distance) async {
    await _api.moveToRel(
        offset: Size(distance[0].toDouble(), distance[1].toDouble()));
  }

  Future<void> move(List<int> res) async {
    await _api.moveTo(point: Point(res[0], res[1]));
  }

  Future<void> leftButtonClick() async {
    await _api.click(button: MouseButton.left);
  }

  Future<void> rightButtonClick() async {
    await _api.click(button: MouseButton.right);
  }

  Future<void> verticalScroll(int i) async {
    await _api.scroll(clicks: i);
  }
}
