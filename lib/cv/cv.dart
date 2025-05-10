import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:assistant/auto_gui/system_control.dart';
import 'package:ffi/ffi.dart';
import 'package:image/image.dart';
import 'package:win32/win32.dart';

/// 使用 Win32 API 截取屏幕区域
Uint8List? captureImageWin(ScreenRect rect) {
  final hdcScreen = GetDC(NULL);
  final hdcMem = CreateCompatibleDC(hdcScreen);

  int? hOld;
  int? hBitmap;
  Pointer<BITMAPINFOHEADER>? bitmapHeader;
  Pointer<Uint8>? buffer;

  try {
    // 创建兼容位图
    hBitmap = CreateCompatibleBitmap(
        hdcScreen,
        rect.width,
        rect.height
    );

    // 选择位图到设备上下文
    hOld = SelectObject(hdcMem, hBitmap);

    // 执行位块传输
    BitBlt(
        hdcMem,
        0,
        0,
        rect.width,
        rect.height,
        hdcScreen,
        rect.left,
        rect.top,
        ROP_CODE.SRCCOPY
    );

    // 获取位图数据
    bitmapHeader = calloc<BITMAPINFOHEADER>()
      ..ref.biSize = sizeOf<BITMAPINFOHEADER>()
      ..ref.biWidth = rect.width
      ..ref.biHeight = -rect.height // 负高度表示从上到下的 DIB
      ..ref.biPlanes = 1
      ..ref.biBitCount = 32
      ..ref.biCompression = BI_COMPRESSION.BI_RGB;

    buffer = calloc<Uint8>(rect.width * rect.height * 4);

    GetDIBits(
        hdcMem,
        hBitmap,
        0,
        rect.height,
        buffer.cast(),
        bitmapHeader.cast(),
        DIB_USAGE.DIB_RGB_COLORS
    );

    // 转换为 Dart 类型
    final imageBytes = buffer.asTypedList(rect.width * rect.height * 4);

    var res = Uint8List.fromList(imageBytes);
    return res;
  } catch (_) {
  } finally {
    // 清理资源
    if (hOld != null) {
      SelectObject(hdcMem, hOld);
    }
    if (hBitmap!= null) {
      DeleteObject(hBitmap);
    }
    DeleteDC(hdcMem);
    ReleaseDC(NULL, hdcScreen);
    if (bitmapHeader!= null) {
      free(bitmapHeader);
    }
    if (buffer!= null) {
      free(buffer);
    }
  }
  return null;
}

/// 将 BGRA 格式的位图数据保存为 PNG 文件
void saveScreenshot(Uint8List bgraData, int width, int height, String path) {
  final img = Image(width: width, height: height);

  // 转换颜色格式 BGRA -> RGBA
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final index = (y * width + x) * 4;
      img.setPixelRgba(
          x,
          y,
          bgraData[index + 2],    // R
          bgraData[index + 1],    // G
          bgraData[index],        // B
          bgraData[index + 3]     // A
      );
    }
  }

  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(encodePng(img));
}
