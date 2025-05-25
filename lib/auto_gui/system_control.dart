import 'dart:ffi';

import 'package:assistant/constants/ratio.dart';
import 'package:ffi/ffi.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:win32/win32.dart';

class ScreenRect {
  int left;
  int top;
  int right;
  int bottom;
  late int width;
  late int height;

  ScreenRect(this.left, this.top, this.right, this.bottom) {
    width = right - left;
    height = bottom - top;
  }

  @override
  String toString() {
    return 'Rect(left: $left, top: $top, right: $right, bottom: $bottom, width: $width, height: $height)';
  }

  String getWidthAndHeight() {
    return '${width}x$height';
  }
}

class SystemControl {

  /// 获取整个屏幕的矩形
  static ScreenRect getScreenRect() {
    final width = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CXSCREEN);
    final height = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CYSCREEN);
    if (width == 0 || height == 0) {
      debugPrint('获取屏幕尺寸失败: ${GetLastError()}');
      return ScreenRect(0, 0, 0, 0);
    }
    return ScreenRect(0, 0, width, height);
  }

  static ScreenRect rect = getScreenRect();

  static Ratio ratio = Ratio.fromWidthHeight(rect.width, rect.height);

  static ScreenRect getCaptureRect(int hWnd) {
    if (hWnd == 0) {
      return getScreenRect();
    }

    var windowRect = getWindowRect(hWnd);
    var gameScreenRect = getGameScreenRect(hWnd);
    var left = windowRect.left;
    var top = windowRect.top + windowRect.height - gameScreenRect.height;
    var right = left + gameScreenRect.width;
    var bottom = top + gameScreenRect.height;
    return ScreenRect(left, top, right, bottom);
  }

  static ScreenRect getWindowRect(int hWnd) {
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
      return ScreenRect(0, 0, 0, 0);
    }
    final left = rect.ref.left;
    final top = rect.ref.top;
    final right = rect.ref.right;
    final bottom = rect.ref.bottom;
    free(rect);
    return ScreenRect(left, top, right, bottom);
  }

  // 新增方法，根据窗口句柄获取ClientRect
  static ScreenRect getGameScreenRect(int hWnd) {
    final rect = calloc<RECT>();
    // 调用GetClientRect获取窗口客户区矩形
    final success = GetClientRect(hWnd, rect);
    if (success == FALSE) {
      debugPrint('获取窗口客户区矩形失败: ${GetLastError()}');
      free(rect);
      return ScreenRect(0, 0, 0, 0);
    }
    final left = rect.ref.left;
    final top = rect.ref.top;
    final right = rect.ref.right;
    final bottom = rect.ref.bottom;
    free(rect);
    return ScreenRect(left, top, right, bottom);
  }
}
