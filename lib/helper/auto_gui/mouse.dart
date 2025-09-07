import 'dart:ui';

import 'package:flutter_auto_gui_windows/flutter_auto_gui_windows.dart';
import 'package:win32/win32.dart';

import '../screen/screen_manager.dart';
import '../win32/mouse_input.dart';

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

  void move(List<int> pos) {
    // 鼠标事件标志：绝对坐标 + 移动
    const int flags = MOUSE_EVENT_FLAGS.MOUSEEVENTF_ABSOLUTE |
        MOUSE_EVENT_FLAGS.MOUSEEVENTF_MOVE;

    final screenWidth = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CXSCREEN);
    final screenHeight = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CYSCREEN);

    // 调用win32的mouse_event函数
    mouseEvent(flags, pos[0] * 65535 ~/ screenWidth,
        pos[1] * 65535 ~/ screenHeight, 0, 0);
  }

  void leftMoveAndClick(List<int> pos) {
    apiLeftMoveAndClick(pos[1], pos[2]);
  }

  void leftButtonClick() {
    apiLeftClick();
  }

  void mouseEventLeftButtonClick() {
    mouseEvent(MOUSE_EVENT_FLAGS.MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  }

  Future<void> rightButtonClick() async {
    await _api.click(button: MouseButton.right);
  }

  Future<void> verticalScroll(int i) async {
    await _api.scroll(clicks: i);
  }
}
