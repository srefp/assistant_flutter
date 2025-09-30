import 'package:assistant/helper/detect/tp_detect.dart';

import '../../app/config/auto_tp_config.dart';
import '../../app/dao/pic_record_db.dart';
import '../../app/windows_app.dart';
import '../auto_gui/system_control.dart';
import '../js/helper_register.dart';
import '../log/log_util.dart';

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
