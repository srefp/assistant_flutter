import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

void enableMica() {
  final dwmapi = DynamicLibrary.open('dwmapi.dll');
  final dwmSetWindowAttribute = dwmapi.lookupFunction<
      Int32 Function(IntPtr hWnd, Int32 dwAttribute, Pointer<Void> pvAttribute,
          Int32 cbAttribute),
      int Function(int hWnd, int dwAttribute, Pointer<Void> pvAttribute,
          int cbAttribute)>('DwmSetWindowAttribute');

  final micaEffect = 1029; // Mica 效果标识
  final value = calloc<Int32>()..value = 1; // 1 表示启用 Mica
  dwmSetWindowAttribute(getWindowHandle(), micaEffect, value.cast(), 4);
  calloc.free(value);
}

/// 获取当前 Flutter 窗口的 HWND（Windows 专用）
// 获取当前窗口句柄
int getWindowHandle() {
  // 获取窗口标题
  final windowTitle = 'assistant'.toNativeUtf16();

  // 查找窗口
  final hWnd = FindWindow(nullptr, windowTitle);
  free(windowTitle);

  print('Window Handle: $hWnd');
  return hWnd;
}
