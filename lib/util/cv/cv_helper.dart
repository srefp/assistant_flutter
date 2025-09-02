import 'dart:convert';
import 'dart:typed_data';

import 'package:assistant/cv/cv.dart';
import 'package:image/image.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../../auto_gui/system_control.dart';

/// 记录鼠标按下的位置
bool recordMouseDownPos = false;

/// 记录鼠标松开的位置
bool recordMouseUpPos = false;

/// 鼠标按下的位置
List<int> mouseDownPos = [];

/// 鼠标松开的位置
List<int> mouseUpPos = [];

Uint8List captureAsPng(ScreenRect rect) {
  final bgraData = captureAsBgra(rect)!;
  return bgraToPng(bgraData, rect.width, rect.height);
}

Uint8List bgraToPng(Uint8List bgraData, int width, int height) {
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

  return encodePng(img);
}

Uint8List pngToBgra(Uint8List pngBytes) {
  // 解码 PNG → 得到 Image 对象（内部是 RGBA）
  Image? image = decodePng(pngBytes);
  if (image == null) throw Exception("Failed to decode PNG");

  int width = image.width;
  int height = image.height;

  // 创建 BGRA 输出数组：每像素 4 字节
  final bgraData = Uint8List(width * height * 4);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      Pixel pixel = image.getPixel(x, y);

      int offset = (y * width + x) * 4;
      bgraData[offset + 0] = pixel.b.toInt(); // B
      bgraData[offset + 1] = pixel.g.toInt(); // G
      bgraData[offset + 2] = pixel.r.toInt(); // R
      bgraData[offset + 3] = pixel.a.toInt(); // A
    }
  }

  return bgraData;
}

/// 将Uint8List转换为Mat（灰度图）
///
/// [list] 要转换的Uint8List
/// [width] 图像宽度
/// [height] 图像高度
///
/// 返回转换后的Mat对象
cv.Mat bgraListToMat(Uint8List list, int width, int height) {
  var mat = cv.Mat.fromList(height, width, cv.MatType.CV_8UC3, list);
  mat = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
  return mat;
}

/// 将Uint8List转换为base64字符串
///
/// [list] 要转换的Uint8List
///
/// 返回转换后的base64字符串
String pngListToString(Uint8List list) {
  return base64Encode(list);
}

/// 将base64字符串转换为Uint8List
///
/// [base64] 要转换的base64字符串
///
/// 返回转换后的Uint8List
Uint8List stringToPngList(String base64) {
  return base64Decode(base64);
}
