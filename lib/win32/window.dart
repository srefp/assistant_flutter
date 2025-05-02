// 检查应用是否已经在运行
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';

/// 将自己的窗口设置为前台窗口
void setSelfForeground() {
  windowManager.focus();
}

bool isWindowMinimized(int hWnd) => IsIconic(hWnd) != 0;

/// 将其他窗口设置为前台窗口
void setForegroundWindow(int hWnd) {
  // 如果窗口最小化则先恢复
  if (isWindowMinimized(hWnd)) {
    ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_RESTORE);
    BringWindowToTop(hWnd);
    UpdateWindow(hWnd);
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
