// 检查应用是否已经在运行
import 'dart:ffi';

import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';

bool isAppRunning(String appUniqueName) {
  final hWnd = FindWindow(nullptr, TEXT(appUniqueName));
  if (hWnd != NULL) {
    // 如果应用已经在运行，激活该窗口
    SetForegroundWindow(hWnd);
    return true;
  }
  return false;
}

/// 将自己的窗口设置为前台窗口
void setForegroundWindow() {
  windowManager.focus();
}

/// 将其他窗口置顶
void setWindowTopmost(int hWnd) {
  // 使用 SetWindowPos 函数将窗口置顶
  SetWindowPos(
    hWnd,
    HWND_TOPMOST,
    0,
    0,
    0,
    0,
    SET_WINDOW_POS_FLAGS.SWP_NOMOVE | SET_WINDOW_POS_FLAGS.SWP_NOSIZE,
  );
}
