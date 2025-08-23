import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:assistant/auto_gui/system_control.dart';
import 'package:ffi/ffi.dart';
import 'package:image/image.dart';
import 'package:opencv_dart/opencv.dart' as cv;
import 'package:win32/win32.dart';

Future<String> encodeImage(cv.Mat mat) async {
  final encodedBytes = cv.imencode('.png', mat);
  return base64Encode(encodedBytes.$2);
}

cv.Mat captureImageWindows(ScreenRect rect) {
  var image = captureImageWin(rect);
  // cv.Mat mat = cv.imdecode(image!, cv.IMREAD_COLOR);
  cv.Mat mat = uint8ListToMat(image!, rect.width, rect.height);
  mat = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
  return mat;
}

// 在文件底部添加以下函数
cv.Mat uint8ListToMat(Uint8List bytes, int width, int height,
    {int channels = 3, // 默认输出BGR三通道
    bool swapRB = true // 是否交换红蓝通道
    }) {
  // 创建临时Mat对象
  final mat = cv.Mat.fromList(
    height,
    width,
    cv.MatType.CV_8UC4, // 输入为RGBA四通道格式
    bytes,
  );

  // 颜色空间转换（RGBA -> BGR）
  final converted =
      cv.cvtColor(mat, swapRB ? cv.COLOR_RGBA2BGR : cv.COLOR_RGBA2RGB);

  // 如果要求通道数不同则进行转换
  if (channels == 1) {
    final gray = cv.cvtColor(converted, cv.COLOR_BGR2GRAY);
    converted.dispose();
    return gray;
  }

  mat.dispose(); // 释放原始矩阵内存
  return converted;
}

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
    hBitmap = CreateCompatibleBitmap(hdcScreen, rect.width, rect.height);

    // 选择位图到设备上下文
    hOld = SelectObject(hdcMem, hBitmap);

    // 执行位块传输
    BitBlt(hdcMem, 0, 0, rect.width, rect.height, hdcScreen, rect.left,
        rect.top, ROP_CODE.SRCCOPY);

    // 获取位图数据
    bitmapHeader = calloc<BITMAPINFOHEADER>()
      ..ref.biSize = sizeOf<BITMAPINFOHEADER>()
      ..ref.biWidth = rect.width
      ..ref.biHeight = -rect.height // 负高度表示从上到下的 DIB
      ..ref.biPlanes = 1
      ..ref.biBitCount = 32
      ..ref.biCompression = BI_COMPRESSION.BI_RGB;

    buffer = calloc<Uint8>(rect.width * rect.height * 4);

    GetDIBits(hdcMem, hBitmap, 0, rect.height, buffer.cast(),
        bitmapHeader.cast(), DIB_USAGE.DIB_RGB_COLORS);

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
    if (hBitmap != null) {
      DeleteObject(hBitmap);
    }
    DeleteDC(hdcMem);
    ReleaseDC(NULL, hdcScreen);
    if (bitmapHeader != null) {
      free(bitmapHeader);
    }
    if (buffer != null) {
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
          bgraData[index + 2], // R
          bgraData[index + 1], // G
          bgraData[index], // B
          bgraData[index + 3] // A
          );
    }
  }

  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(encodePng(img));
}
