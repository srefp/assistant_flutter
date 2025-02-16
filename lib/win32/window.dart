// 检查应用是否已经在运行
import 'dart:ffi';

import 'package:win32/win32.dart';

bool isAppRunning(String appUniqueName) {
  final hWnd = FindWindow(nullptr, TEXT(appUniqueName));
  if (hWnd != NULL) {
    // 如果应用已经在运行，激活该窗口
    SetForegroundWindow(hWnd);
    return true;
  }
  return false;
}