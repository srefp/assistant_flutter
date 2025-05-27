import 'package:opencv_dart/opencv.dart' as cv;

void findImageWithMask(templatePath, sourcePath) {
  final templateImage = cv.imread(templatePath, flags: cv.IMREAD_COLOR);
  final sourceImage = cv.imread(sourcePath, flags: cv.IMREAD_COLOR);

  // 转换为灰度图
  final templateGray = cv.cvtColor(templateImage, cv.COLOR_BGR2GRAY);
  final sourceGray = cv.cvtColor(sourceImage, cv.COLOR_BGR2GRAY);

  //
}
