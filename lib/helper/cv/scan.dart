import 'package:assistant/helper/cv/cv.dart';
import 'package:assistant/helper/data_converter.dart';
import 'package:assistant/helper/js/helper_register.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../../app/config/auto_tp_config.dart';
import '../../app/dao/pic_record_db.dart';
import '../../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/system_control.dart';

bool detectOpen = true;

const matchThreshold = 0.2;

bool mapOpened = false;
Future? tpDetectFuture;
bool tpDetectRunning = false;
int tpDetectCount = 0;
const tpDetectTotal = 20;

/// 检测传送
void startTpDetect() async {
  if (!AutoTpConfig.to.isTpDetectEnabled()) {
    return;
  }

  // debugPrint('开始检测传送按钮');
  tpDetectRunning = true;
  tpDetectCount = 0;
  final tpDetectArea = AutoTpConfig.to.getIntTpDetectArea();

  tpDetectFuture ??= Future.doWhile(() async {
    await Future.delayed(
        Duration(milliseconds: AutoTpConfig.to.getTpDetectInterval()));

    if (!WindowsApp.autoTpModel.active()) {
      return true;
    }

    // debugPrint('检测中...');

    final startTime = DateTime.now();
    final res = await findPicture([tpDetectArea, 'bzd-confirm']);
    final endTime = DateTime.now();
    debugPrint('检测传送按钮耗时：${endTime.difference(startTime).inMilliseconds}ms');

    debugPrint('检测传送按钮：${res[0]}');
    if (res[0] >= AutoTpConfig.to.getTpDetectThreshold()) {
      // debugPrint('检测到传送按钮');

      await KeyMouseUtil.clickAtPoint(convertDynamicListToIntList(res[1]), 100);
      stopTpDetect();
    }

    final shouldRunning = tpDetectRunning && tpDetectCount++ < tpDetectTotal;
    if (!shouldRunning) {
      stopTpDetect();
      startWorldDetect(worldDetectTotal: 30);
    }
    return shouldRunning;
  });
}

void stopTpDetect() {
  // debugPrint('停止检测传送按钮');
  tpDetectRunning = false;
  tpDetectFuture = null;
}

Future? worldDetectFuture;
bool worldDetectRunning = false;
int worldDetectCount = 0;

/// 检测大世界
void startWorldDetect({int worldDetectTotal = 10}) {
  if (!AutoTpConfig.to.isTpDetectEnabled()) {
    return;
  }

  worldDetectRunning = true;
  worldDetectCount = 0;
  final worldDetectArea = AutoTpConfig.to.getIntWorldDetectArea();

  worldDetectFuture ??= Future.doWhile(() async {
    await Future.delayed(
        Duration(milliseconds: AutoTpConfig.to.getWorldDetectInterval()));

    if (!WindowsApp.autoTpModel.active()) {
      return true;
    }

    final res = await findPicture([worldDetectArea, 'bzd-world']);

    // debugPrint('检测大世界头像：${res[0]}');
    if (res[0] >= AutoTpConfig.to.getWorldDetectThreshold()) {
      // debugPrint('检测到大世界头像');
      mapOpened = false;
    } else {
      mapOpened = true;
    }

    final shouldRunning =
        worldDetectRunning && worldDetectCount++ < worldDetectTotal;
    if (!shouldRunning) {
      stopWorldDetect();
    }
    return shouldRunning;
  });
}

stopWorldDetect() {
  worldDetectRunning = false;
  worldDetectFuture = null;
}

Future<void> detectWorldRole() async {
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
