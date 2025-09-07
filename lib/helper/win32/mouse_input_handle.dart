import 'package:win32/win32.dart';

import '../screen/screen_manager.dart';

/// 向指定窗口句柄发送点击事件
void apiSendClick(int x, int y) {
  final lParam = (y << 16) | (x & 0xFFFF);
  PostMessage(ScreenManager.instance.hWnd, WM_MOUSEMOVE, 0, lParam);
  PostMessage(ScreenManager.instance.hWnd, WM_LBUTTONDOWN, 0, lParam);
  PostMessage(ScreenManager.instance.hWnd, WM_LBUTTONUP, 0, lParam);
}
