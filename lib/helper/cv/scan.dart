import 'package:assistant/helper/cv/cv.dart';
import 'package:assistant/helper/data_converter.dart';
import 'package:assistant/helper/js/helper_register.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../../app/config/auto_tp_config.dart';
import '../../app/dao/pic_record_db.dart';
import '../../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/system_control.dart';
import '../log/log_util.dart';

Future? multiTpDetectFuture;
bool multiTpDetectRunning = false;
int multiTpDetectCount = 0;
const multiTpDetectTotal = 20;

/// 多选检测
void startMultiTpDetect() async {
  if (!AutoTpConfig.to.isMultiTpDetectEnabled() &&
      multiTpDetectFuture != null) {
    return;
  }

  // 重新缩放图片
  SystemControl.refreshRect();
  resizePicRecord(SystemControl.rect.height);

  appLog.info('开始多选检测传送按钮');
  multiTpDetectRunning = true;
  multiTpDetectCount = 0;
  final multiTpDetectArea = AutoTpConfig.to.getIntMultiTpDetectArea();

  await Future.delayed(Duration(milliseconds: 200));

  // 查询图片中所有以 bzd-multi 开图的key
  final multiTpDetectKeys =
      picRecordMap.keys.where((key) => key.startsWith('bzd-multi')).toList();

  appLog.info('所有多选模板key：$multiTpDetectKeys');

  multiTpDetectFuture ??= Future.doWhile(() async {
    await Future.delayed(
        Duration(milliseconds: AutoTpConfig.to.getMultiTpDetectInterval()));

    if (!WindowsApp.autoTpModel.active()) {
      return true;
    }

    final startTime = DateTime.now();

    final rect = multiTpDetectArea;
    final leftTop = KeyMouseUtil.physicalPos([rect[0], rect[1]]);
    final rightBottom = KeyMouseUtil.physicalPos([rect[2], rect[3]]);
    final image = captureImageWindows(
        ScreenRect(leftTop[0], leftTop[1], rightBottom[0], rightBottom[1]));

    final multiTpDetectFutureList = multiTpDetectKeys
        .map((key) => findPictureWithMultiLocation([
              multiTpDetectArea,
              key,
              AutoTpConfig.to.getMultiTpDetectThreshold(),
              image,
            ]))
        .toList();

    final multiRes = await Future.wait(multiTpDetectFutureList);

    // 合并multiRes
    final res = <List<int>>[];

    for (var e in multiRes) {
      for (var p in e) {
        res.add(p);
      }
    }

    appLog.info('多选检测传送按钮：$res');
    if (res.isNotEmpty) {
      // 找到纵坐标最小的点
      final minY = res.map((e) => e[1]).reduce((a, b) => a < b ? a : b);
      final minYPoint = res.firstWhere((e) => e[1] == minY);

      await Future.delayed(Duration(milliseconds: 150));
      await KeyMouseUtil.clickAtPoint(
          convertDynamicListToIntList(minYPoint), 100);
      multiTpDetectRunning = false;
      startTpDetect();
    }

    final endTime = DateTime.now();
    appLog.info('检测多选按钮耗时：${endTime.difference(startTime).inMilliseconds}ms');

    final shouldRunning =
        multiTpDetectRunning && multiTpDetectCount++ < multiTpDetectTotal;
    if (!shouldRunning) {
      stopMultiTpDetect();
    }
    return shouldRunning;
  });
}

stopMultiTpDetect() {
  appLog.info('停止多选检测传送按钮');
  multiTpDetectRunning = false;
  multiTpDetectFuture = null;
}

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

  // 重新缩放图片
  SystemControl.refreshRect();
  resizePicRecord(SystemControl.rect.height);

  appLog.info('开始检测传送按钮');
  tpDetectRunning = true;
  tpDetectCount = 0;
  final tpDetectArea = AutoTpConfig.to.getIntTpDetectArea();

  tpDetectFuture ??= Future.doWhile(() async {
    await Future.delayed(
        Duration(milliseconds: AutoTpConfig.to.getTpDetectInterval()));

    if (!WindowsApp.autoTpModel.active()) {
      return true;
    }

    appLog.info('传送按钮循环检测中...');

    final startTime = DateTime.now();
    final res = await findPicture([tpDetectArea, 'bzd-confirm']);
    final endTime = DateTime.now();
    appLog.info('检测传送按钮耗时：${endTime.difference(startTime).inMilliseconds}ms');

    appLog.info('检测传送按钮：${res[0]}');
    if (res[0] >= AutoTpConfig.to.getTpDetectThreshold()) {
      appLog.info('检测到传送按钮');

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
  appLog.info('停止检测传送按钮');
  tpDetectRunning = false;
  tpDetectFuture = null;
}

Future? worldDetectFuture;
bool worldDetectRunning = false;
int worldDetectCount = 0;

/// 检测大世界
void startWorldDetect({int worldDetectTotal = 10}) {
  if (!AutoTpConfig.to.isWorldDetectEnabled()) {
    return;
  }

  // 重新缩放图片
  SystemControl.refreshRect();
  resizePicRecord(SystemControl.rect.height);

  worldDetectRunning = true;
  worldDetectCount = 0;
  bool prevMapOpened = mapOpened;
  final worldDetectArea = AutoTpConfig.to.getIntWorldDetectArea();

  worldDetectFuture ??= Future.doWhile(() async {
    await Future.delayed(
        Duration(milliseconds: AutoTpConfig.to.getWorldDetectInterval()));

    if (!WindowsApp.autoTpModel.active()) {
      return true;
    }

    final res = await findPicture([worldDetectArea, 'bzd-world']);

    appLog.info('检测大世界头像：${res[0]}');
    if (res[0] >= AutoTpConfig.to.getWorldDetectThreshold()) {
      appLog.info('检测到大世界头像');
      mapOpened = false;
    } else {
      mapOpened = true;
    }

    final shouldRunning = prevMapOpened == mapOpened &&
        worldDetectRunning &&
        worldDetectCount++ < worldDetectTotal;
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

const matchThreshold = 0.2;

Future<void> detectWorldRole() async {
  appLog.info('开始检测世界角色');

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
      appLog.info('检测世界角色：${res.maxMatchValue}');
      if (res.maxMatchValue >= matchThreshold) {
        appLog.info('大世界');
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
