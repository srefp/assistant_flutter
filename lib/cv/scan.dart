import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/auto_gui/system_control.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/cv/cv.dart';
import 'package:flutter/services.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../app/windows_app.dart';
import '../manager/screen_manager.dart';

void findImageWithMask(templatePath, sourcePath) {
  final templateImage = cv.imread(templatePath, flags: cv.IMREAD_COLOR);
  final sourceImage = cv.imread(sourcePath, flags: cv.IMREAD_COLOR);

  // 转换为灰度图
  final templateGray = cv.cvtColor(templateImage, cv.COLOR_BGR2GRAY);
  final sourceGray = cv.cvtColor(sourceImage, cv.COLOR_BGR2GRAY);

  //
}

bool detectOpen = false;

void detectWorldRole() async {
  // await initializePics();
  if (!detectOpen) {
    return;
  }

  await Future.doWhile(() async {
    // 1s的启动时间
    await Future.delayed(const Duration(seconds: 1));
    while (AutoTpConfig.to.isSmartTpEnabled()) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!WindowsApp.autoTpModel.isRunning ||
          !ScreenManager.instance.isGameActive()) {
        continue;
      }

      print('检测中...');

      var rect = AutoTpConfig.to.getWorldScreenRect();
      print(
          'init rect: ${rect.left} ${rect.top} ${rect.right} ${rect.bottom} ${rect.width} ${rect.height}');

      // 检测世界角色
      var res = GamePicInfo.to.character.scan();
      print('res: ${res.maxMatchValue} ${res.maxMatchLocation}');
    }
    return true;
  });
}

class GamePicInfo {
  static final to = GamePicInfo();
  final PicItem character;

  GamePicInfo()
      : character = PicItem(
            'character',
            cv.imread('assets/pics/character.png', flags: cv.IMREAD_COLOR),
            AutoTpConfig.to.getWorldScreenRect());
}

class PicItem {
  final String fileName;
  final cv.Mat image;
  final ScreenRect rect;

  PicItem(this.fileName, this.image, rect)
      : rect = KeyMouseUtil.convertToPhysicalRect(rect);

  ScanResult scan() {
    print(
        'rect: ${rect.left} ${rect.top} ${rect.right} ${rect.bottom} ${rect.width} ${rect.height}');
    final capture = captureImageWindows(rect);
    print('capture: ${capture.width} ${capture.height}');

    final result = cv.matchTemplate(
        capture,
        cv.imread('assets/pics/character.png', flags: cv.IMREAD_COLOR),
        cv.TM_CCOEFF_NORMED);
    final minMaxLoc = cv.minMaxLoc(result);
    return ScanResult(minMaxLoc.$1, minMaxLoc.$3);
  }
}

Future<void> initializePics() async {
  final pics = ['1', '2', '3', '4', '6', '8', 'dashijie'];
  final picsPath = pics.map((e) => 'assets/pics/$e.png').toList();
  for (final path in picsPath) {
    // 加载图片字节数据
    final byteData = await rootBundle.load(path);
    // 转换为Uint8List格式
    final bytes = byteData.buffer.asUint8List();
    // 使用OpenCV解码图片
    final image = cv.imdecode(bytes, cv.IMREAD_COLOR);
    // ... 后续处理解码后的image对象 ...
  }
}

class ScanResult {
  final double maxMatchValue;
  final cv.Point maxMatchLocation;

  ScanResult(this.maxMatchValue, this.maxMatchLocation);
}
