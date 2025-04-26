// 检查应用是否已经在运行
import 'dart:ffi';

import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';

/// 程序是否已经在运行
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
void setSelfForeground() {
  windowManager.focus();
}

/// 将其他窗口设置为前台窗口
void setForegroundWindow(int hWnd) {
  // 使用 SetForegroundWindow 函数将窗口设置为前台窗口
  SetForegroundWindow(hWnd);
}

/// 判断其他窗口是否处于前台
bool isWindowForeground(int hWnd) {
  return GetForegroundWindow() == hWnd;
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
