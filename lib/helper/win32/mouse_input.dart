import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

void apiLeftClick() {
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

void apiMouseMove(int x, int y) {
  final pInputs = calloc<INPUT>(1);
  pInputs[0].type = INPUT_TYPE.INPUT_MOUSE;
  pInputs[0].mi.dwFlags = MOUSE_EVENT_FLAGS.MOUSEEVENTF_MOVE;
  pInputs[0].mi.dx = x;
  pInputs[0].mi.dy = y;
  SendInput(1, pInputs, sizeOf<INPUT>());
  free(pInputs);
}

void apiLeftMoveAndClick(int x, int y) {
  final pInputs = calloc<INPUT>(3);

  // 移动事件
  pInputs[0].type = INPUT_TYPE.INPUT_MOUSE;
  pInputs[0].mi.dwFlags = MOUSE_EVENT_FLAGS.MOUSEEVENTF_MOVE;
  pInputs[0].mi.dx = x;
  pInputs[0].mi.dy = y;

  // 按下事件
  pInputs[1].type = INPUT_TYPE.INPUT_MOUSE;
  pInputs[1].mi.dwFlags = MOUSE_EVENT_FLAGS.MOUSEEVENTF_LEFTDOWN;
  pInputs[1].mi.dx = x;
  pInputs[1].mi.dy = y;

  // 释放事件
  pInputs[2].type = INPUT_TYPE.INPUT_MOUSE;
  pInputs[2].mi.dwFlags = MOUSE_EVENT_FLAGS.MOUSEEVENTF_LEFTUP;
  pInputs[2].mi.dx = x;
  pInputs[2].mi.dy = y;

  SendInput(3, pInputs, sizeOf<INPUT>());
  free(pInputs);
}
