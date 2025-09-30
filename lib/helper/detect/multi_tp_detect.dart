import 'package:assistant/helper/detect/tp_detect.dart';

import '../../app/config/auto_tp_config.dart';
import '../../app/dao/pic_record_db.dart';
import '../../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/system_control.dart';
import '../cv/cv.dart';
import '../data_converter.dart';
import '../js/helper_register.dart';
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

    final multiTpDetectFutureList = multiTpDetectKeys.map((key) {
      bool mask = key.startsWith('bzd-multi-instance');
      return findPictureWithMultiLocation([
        multiTpDetectArea,
        key,
        AutoTpConfig.to.getMultiTpDetectThreshold(),
        image,
        mask,
      ]);
    }).toList();

    final multiRes = await Future.wait(multiTpDetectFutureList);

    // 合并multiRes
    final res = <List<int>>[];

    for (var e in multiRes) {
      for (var p in e) {
        res.add(p);
      }
    }

    final endTime = DateTime.now();
    appLog.info('检测多选按钮耗时：${endTime.difference(startTime).inMilliseconds}ms');

    appLog.info('多选检测传送按钮：$res');
    if (res.isNotEmpty) {
      // 找到纵坐标最小的点
      final minY = res.map((e) => e[1]).reduce((a, b) => a < b ? a : b);
      final minYPoint = res.firstWhere((e) => e[1] == minY);

      await Future.delayed(
          Duration(milliseconds: AutoTpConfig.to.getDetectMultiClickDelay()));
      await KeyMouseUtil.clickAtPoint(
          convertDynamicListToIntList(minYPoint), 0);
      multiTpDetectRunning = false;
      startTpDetect();
    }

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
