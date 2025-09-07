import 'dart:ui';

import 'package:flutter_auto_gui_windows/flutter_auto_gui_windows.dart';
import 'package:win32/win32.dart';

import '../screen/screen_manager.dart';

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

  void move(List<int> logicalPos) {
    // 鼠标事件标志：绝对坐标 + 移动
    const int flags = MOUSE_EVENT_FLAGS.MOUSEEVENTF_ABSOLUTE |
        MOUSE_EVENT_FLAGS.MOUSEEVENTF_MOVE;

    // 调用win32的mouse_event函数
    mouseEvent(flags, logicalPos[0], logicalPos[1], 0, 0);
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
