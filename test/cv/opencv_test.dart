import 'package:assistant/helper/auto_gui/system_control.dart';
import 'package:assistant/helper/cv/cv.dart';
import 'package:flutter/widgets.dart';
import 'package:opencv_dart/opencv.dart' as cv;

void main() {
  final rect = ScreenRect(10, 10, 12, 12);

  // 截图
  final image = captureAsBgra(rect);

  cv.Mat mat = uint8ListToMat(image!, rect.width, rect.height);

  // 灰度图
  final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

  debugPrint(image.toString());

  debugPrint(gray.toString());
}
