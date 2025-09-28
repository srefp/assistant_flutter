import 'package:opencv_dart/opencv.dart' as cv;

/// 快速图片缩放算法（OpenCV实现）
/// [image] 原始图片对象（Mat类型）
/// [scale] 缩放比例（0.0 ~ 1.0）
cv.Mat resize(cv.Mat image, double scale) {
  final dstWidth = (image.width * scale).round();
  final dstHeight = (image.height * scale).round();

  return cv.resize(
    image,
    (dstWidth, dstHeight),
    interpolation: cv.INTER_LINEAR, // 双线性插值
  );
}
