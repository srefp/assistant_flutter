import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

Future<Uint8List> captureImage(GlobalKey key, Offset screenStart, Offset screenEnd) async {
      final RenderRepaintBoundary boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // 将屏幕坐标转换为 widget 局部坐标
      final RenderBox box = boundary as RenderBox;
      final Offset localStart = box.globalToLocal(screenStart);
      final Offset localEnd = box.globalToLocal(screenEnd);

      // 获取完整截图
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      // 裁剪指定区域
      final int startX = localStart.dx.toInt();
      final int startY = localStart.dy.toInt();
      final int width = (localEnd.dx - localStart.dx).toInt();
      final int height = (localEnd.dy - localStart.dy).toInt();

      // 创建裁剪后的字节缓冲区
      final Uint8List pixels = byteData!.buffer.asUint8List();
      final Uint8List cropped = Uint8List(width * height * 4);

      // 逐行复制像素数据
      for (int y = 0; y < height; y++) {
            final int srcStart = (startY + y) * image.width * 4 + startX * 4;
            final int dstStart = y * width * 4;
            cropped.setRange(dstStart, dstStart + width * 4,
                pixels.sublist(srcStart, srcStart + width * 4));
      }

      return cropped;
}