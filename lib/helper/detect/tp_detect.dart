import 'package:assistant/helper/detect/world_detect.dart';

import '../../app/config/auto_tp_config.dart';
import '../../app/config/hotkey_config.dart';
import '../../app/dao/pic_record_db.dart';
import '../../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/system_control.dart';
import '../data_converter.dart';
import '../js/helper_register.dart';
import '../log/log_util.dart';
import 'multi_tp_detect.dart';

bool mapOpened = false;
Future? tpDetectFuture;
bool tpDetectRunning = false;
int tpDetectCount = 0;
const tpDetectTotal = 20;

/// 检测传送
void startTpDetect() async {
  if (!HotkeyConfig.to.isAllTpDetectEnabled() ||
      !AutoTpConfig.to.isTpDetectEnabled()) {
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
      stopMultiTpDetect();
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
