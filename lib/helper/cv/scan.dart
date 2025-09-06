import 'package:assistant/helper/cv/cv.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../../app/config/auto_tp_config.dart';
import '../../app/dao/pic_record_db.dart';
import '../../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/system_control.dart';

bool detectOpen = false;

const matchThreshold = 0.2;

void detectWorldRole() async {
  if (!detectOpen) {
    return;
  }

  debugPrint('开始检测世界角色');

  await Future.doWhile(() async {
    // 1s的启动时间
    await Future.delayed(const Duration(seconds: 1));
    while (AutoTpConfig.to.isSmartTpEnabled()) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!WindowsApp.autoTpModel.active()) {
        continue;
      }

      // 检测世界角色
      var res = await ProcessPicInfo.to.world.scan();
      debugPrint('检测世界角色：${res.maxMatchValue}');
      if (res.maxMatchValue >= matchThreshold) {
        debugPrint('大世界');
      }
    }
    return true;
  });
}

class ProcessPicInfo {
  static final to = ProcessPicInfo();
  final PicItem world;
  final PicItem anchorConfirm;

  ProcessPicInfo()
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

class ScanResult {
  final double maxMatchValue;
  final cv.Point maxMatchLocation;

  ScanResult(this.maxMatchValue, this.maxMatchLocation);
}
