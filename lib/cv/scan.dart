import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/auto_gui/system_control.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/cv/cv.dart';
import 'package:assistant/db/pic_record_db.dart';
import 'package:flutter/services.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../app/windows_app.dart';

void findImageWithMask(templatePath, sourcePath) {
  final templateImage = cv.imread(templatePath, flags: cv.IMREAD_COLOR);
  final sourceImage = cv.imread(sourcePath, flags: cv.IMREAD_COLOR);

  // 转换为灰度图
  final templateGray = cv.cvtColor(templateImage, cv.COLOR_BGR2GRAY);
  final sourceGray = cv.cvtColor(sourceImage, cv.COLOR_BGR2GRAY);

  //
}

bool detectOpen = true;

const matchThreshold = 0.9;

void detectWorldRole() async {
  // await initializePics();
  if (!detectOpen) {
    return;
  }

  print('开始检测世界角色');

  await Future.doWhile(() async {
    // 1s的启动时间
    await Future.delayed(const Duration(seconds: 1));
    while (AutoTpConfig.to.isSmartTpEnabled()) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!WindowsApp.autoTpModel.active()) {
        continue;
      }

      // 检测世界角色
      var res = await GamePicInfo.to.world.scan();
      print('检测世界角色：${res.maxMatchValue}');
      if (res.maxMatchValue >= matchThreshold) {
        print('大世界');
      }
    }
    return true;
  });
}

class GamePicInfo {
  static final to = GamePicInfo();
  final PicItem world;
  final PicItem anchorConfirm;

  GamePicInfo()
      : world =
            PicItem(AutoTpConfig.keyWorldRect, AutoTpConfig.to.getWorldRect()),
        anchorConfirm = PicItem(
            AutoTpConfig.keyAnchorRect, AutoTpConfig.to.getAnchorRect());
}

class PicItem {
  final String key;
  final ScreenRect rect;

  PicItem(this.key, rect) : rect = KeyMouseUtil.convertToPhysicalRect(rect);

  Future<ScanResult> scan() async {
    final capture = captureImageWindows(rect);

    var imageItem = picRecordMap[key];
    if (imageItem == null) {
      return ScanResult(-1, cv.Point(0, 0));
    }

    final encodedImage = await encodeImage(capture);
    print('encodedImage: data:image/png;base64,$encodedImage');

    final encodedTemplate = await encodeImage(imageItem.mat!);
    print('encodedTemplate: data:image/png;base64,$encodedTemplate');

    final image = imageItem.mat!;
    final result = cv.matchTemplate(capture, image, cv.TM_CCOEFF_NORMED);
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
