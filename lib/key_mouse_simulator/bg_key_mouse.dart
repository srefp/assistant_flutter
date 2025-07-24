import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_auto_gui/flutter_auto_gui.dart';
import 'package:win32/win32.dart';

class BgKeyMouse {
  static void sendMouseClickToWindow(int hWnd, int x, int y,
      {MouseButton button = MouseButton.left, int clickCount = 1}) {
    // 将客户区坐标转换为屏幕坐标（SendInput 使用屏幕坐标）
    final point = calloc<POINT>();
    point.ref.x = x;
    point.ref.y = y;
    ClientToScreen(hWnd, point);

    // 构造鼠标输入事件
    // final input = Input(
    //   type: INPUT_TYPE.INPUT_MOUSE,
    //   mi: MOUSEINPUT(
    //     dx: point.x,
    //     dy: point.y,
    //     mouseData: 0,
    //     dwFlags: MOUSE_EVENT_FLAGS.MOUSEEVENTF_MOVE |
    //         MOUSE_EVENT_FLAGS.MOUSEEVENTF_ABSOLUTE, // 移动到目标位置
    //   ),
    // );
    //
    // // 发送按下事件
    // input.mi.dwFlags = button == MouseButton.left
    //     ? MOUSE_EVENT_FLAGS.MOUSEEVENTF_LEFTDOWN
    //     : MOUSE_EVENT_FLAGS.MOUSEEVENTF_RIGHTDOWN;
    // SendInput(1, [input], sizeOf<Input>());
    //
    // // 发送释放事件（模拟点击）
    // input.mi.dwFlags =
    //     button == MouseButton.left ? MOUSEEVENTF_LEFTUP : MOUSEEVENTF_RIGHTUP;
    // SendInput(1, [input], sizeOf<Input>());
  }
}
