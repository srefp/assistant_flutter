import 'dart:io';

import 'package:window_manager/window_manager.dart';

/// 设置/取消 全屏
Future<void> setFullScreen(bool fullScreen) =>
    windowManager.setFullScreen(fullScreen);

String getTrayImagePath(String imageName) {
  return Platform.isWindows
      ? 'assets/image/$imageName.ico'
      : 'assets/image/$imageName.png';
}

String getImagePath(String imageName) {
  return Platform.isWindows
      ? 'assets/image/$imageName.bmp'
      : 'assets/image/$imageName.png';
}
