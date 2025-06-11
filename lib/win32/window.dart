// 检查应用是否已经在运行
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';

/// 获取窗口标题
String? getWindowTitle(int hWnd) {
  return using((arena) {
    final buffer = arena<WCHAR>(256).cast<Utf16>();
    final length = GetWindowText(hWnd, buffer, 256);

    if (length == 0) {
      final error = GetLastError();
      if (error != 0) return null; // 无效句柄或窗口没有标题
    }

    return buffer.toDartString(length: length);
  });
}

/// 将自己的窗口设置为前台窗口
void setSelfForeground() {
  windowManager.focus();
}

bool isWindowMinimized(int hWnd) => IsIconic(hWnd) != 0;

/// 将其他窗口设置为前台窗口
void setForegroundWindow(int hWnd) {
  // 如果窗口最小化则先恢复
  if (isWindowMinimized(hWnd)) {
    ShowWindowAsync(hWnd, SHOW_WINDOW_CMD.SW_RESTORE);
    // 发送重绘消息强制刷新窗口
    SendMessage(hWnd, WM_PAINT, 0, 0);
  }

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
