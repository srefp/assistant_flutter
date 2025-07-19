import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// 判断系统光标是否隐藏（返回 true 表示隐藏）
bool isCursorHidden() {
  // 定义 CURSORINFO 结构体（需与 Windows API 定义一致）
  final cursorInfo = calloc<CURSORINFO>();
  cursorInfo.ref.cbSize = sizeOf<CURSORINFO>(); // 必须设置结构体大小

  // 调用 Windows API 获取光标信息
  final success = GetCursorInfo(cursorInfo);
  if (success != 0) {
    free(cursorInfo);
    return false;
  }

  // flags 为 0 表示隐藏，非 0（CURSOR_SHOWING=0x00000001）表示显示
  final showing = (cursorInfo.ref.flags & CURSOR_SHOWING) != 0;
  free(cursorInfo); // 释放内存

  return !showing;
}

// Windows API 常量定义（需与系统一致）
const int CURSOR_SHOWING = 0x00000001;
