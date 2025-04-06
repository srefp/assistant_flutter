import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:win32/win32.dart';

class Rect {
  int left;
  int top;
  int right;
  int bottom;
  late int width;
  late int height;

  Rect(this.left, this.top, this.right, this.bottom) {
    width = right - left;
    height = bottom - top;
  }
}

class SystemControl {

  /// 获取整个屏幕的矩形
  static Rect getScreenRect() {
    final width = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CXSCREEN);
    final height = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CYSCREEN);
    if (width == 0 || height == 0) {
      debugPrint('获取屏幕尺寸失败: ${GetLastError()}');
      return Rect(0, 0, 0, 0);
    }
    return Rect(0, 0, width, height);
  }

  static Rect getCaptureRect(int hWnd) {
    if (hWnd == 0) {
      return getScreenRect();
    }

    var windowRect = getWindowRect(hWnd);
    var gameScreenRect = getGameScreenRect(hWnd);
    var left = windowRect.left;
    var top = windowRect.top + windowRect.height - gameScreenRect.height;
    var right = left + gameScreenRect.width;
    var bottom = top + gameScreenRect.height;
    return Rect(left, top, right, bottom);
  }

  static Rect getWindowRect(int hWnd) {
    final rect = calloc<RECT>();
    // 调用DwmGetWindowAttribute获取窗口位置
    final result = DwmGetWindowAttribute(
      hWnd,
      DWMWINDOWATTRIBUTE.DWMWA_EXTENDED_FRAME_BOUNDS,
      rect.cast(),
      sizeOf<RECT>(),
    );
    if (result != S_OK) {
      debugPrint('获取窗口位置失败: $result');
      free(rect);
      return Rect(0, 0, 0, 0);
    }
    final left = rect.ref.left;
    final top = rect.ref.top;
    final right = rect.ref.right;
    final bottom = rect.ref.bottom;
    free(rect);
    return Rect(left, top, right, bottom);
  }

  // 新增方法，根据窗口句柄获取ClientRect
  static Rect getGameScreenRect(int hWnd) {
    final rect = calloc<RECT>();
    // 调用GetClientRect获取窗口客户区矩形
    final success = GetClientRect(hWnd, rect);
    if (success == FALSE) {
      debugPrint('获取窗口客户区矩形失败: ${GetLastError()}');
      free(rect);
      return Rect(0, 0, 0, 0);
    }
    final left = rect.ref.left;
    final top = rect.ref.top;
    final right = rect.ref.right;
    final bottom = rect.ref.bottom;
    free(rect);
    return Rect(left, top, right, bottom);
  }
}
