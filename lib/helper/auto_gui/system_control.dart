import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../../constant/ratio.dart';
import '../screen/screen_manager.dart';

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
      return ScreenRect(0, 0, 0, 0);
    }
    return ScreenRect(0, 0, width, height);
  }

  static ScreenRect rect =
      SystemControl.getCaptureRect(ScreenManager.instance.hWnd);

  static Ratio ratio = Ratio.fromWidthHeight(rect.width, rect.height);

  static void refreshRect() {
    rect = SystemControl.getCaptureRect(ScreenManager.instance.hWnd);
    ratio = Ratio.fromWidthHeight(rect.width, rect.height);
  }

  static ScreenRect getCaptureRect(int hWnd) {
    if (!Platform.isWindows) {
      return ScreenRect(0, 0, 0, 0);
    }
    if (hWnd == 0) {
      return getScreenRect();
    }

    var windowRect = getWindowRect(hWnd);
    var processScreenRect = getProcessScreenRect(hWnd);
    var left = windowRect.left;
    var top = windowRect.top + windowRect.height - processScreenRect.height;
    var right = left + processScreenRect.width;
    var bottom = top + processScreenRect.height;
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
  static ScreenRect getProcessScreenRect(int hWnd) {
    final rect = calloc<RECT>();
    // 调用GetClientRect获取窗口客户区矩形
    final success = GetClientRect(hWnd, rect);
    if (success == FALSE) {
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
