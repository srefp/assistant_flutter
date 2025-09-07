import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

void sendInputLeftButtonClick() {
  final pInputs = calloc<INPUT>(2);

  // 按下事件
  pInputs[0].type = INPUT_TYPE.INPUT_MOUSE;
  pInputs[0].mi.dwFlags = MOUSE_EVENT_FLAGS.MOUSEEVENTF_LEFTDOWN;

  // 释放事件
  pInputs[1].type = INPUT_TYPE.INPUT_MOUSE;
  pInputs[1].mi.dwFlags = MOUSE_EVENT_FLAGS.MOUSEEVENTF_LEFTUP;

  SendInput(2, pInputs, sizeOf<INPUT>());
  free(pInputs);
}
