import 'package:assistant/app/windows_app.dart';
import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/auto_gui/keyboard.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/config/game_key_config.dart';
import 'package:assistant/util/js_executor.dart';
import 'package:assistant/util/script_parser.dart';
import 'package:assistant/win32/toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_auto_gui/flutter_auto_gui.dart';

class RouteExecutor {
  static bool tpForbidden = false;
  static AutoTpConfig config = AutoTpConfig.to;

  static Future<void> tpNext(bool qm) async {
    if (!config.isAutoTpEnabled()) {
      return;
    }

    if (tpForbidden) {
      return;
    }

    tpForbidden = true;

    try {
      var tpPoints = WindowsApp.autoTpModel.tpPoints;
      if (config.isContinuousMode()) {
        var prevRouteIndex = config.getRouteIndex();
        config.save(
            AutoTpConfig.keyRouteIndex, prevRouteIndex % tpPoints.length);
        if (prevRouteIndex != 0 && config.getRouteIndex() == 0) {
          config.save(AutoTpConfig.keyRouteIndex, 1);
        }
      }

      if (config.getRouteIndex() >= 0 &&
          config.getRouteIndex() <= tpPoints.length) {
        config.save(AutoTpConfig.keyRouteIndex, config.getRouteIndex() + 1);
      }

      if (config.getRouteIndex() >= 0 &&
          config.getRouteIndex() <= tpPoints.length) {
        await executeStep(tpPoints[config.getRouteIndex() - 1], qm);

        // 刷新当前位置
        final curPos = tpPoints[config.getRouteIndex() - 1].name ??
            '点位${config.getRouteIndex()}';
        WindowsApp.autoTpModel.selectPos(curPos);
      } else {
        showToast('当前路线已结束！');
      }
    } catch (e) {
      showToast('脚本执行出错了');
    } finally {
      Future.delayed(Duration(milliseconds: AutoTpConfig.to.getTpCooldown()),
          () {
        tpForbidden = false;
      });
    }
  }

  static Future<void> executeStep(BlockItem tpPoint, bool qmParam) async {
    if (qmParam) {
      await api.keyDown(key: GameKeyConfig.to.getForwardKey());
      await api.keyUp(key: GameKeyConfig.to.getForwardKey());
      if (AutoTpConfig.to.isQmDash()) {
        await api.click(button: MouseButton.right);
      }
      await Future.delayed(Duration(milliseconds: AutoTpConfig.to.getQmDashDelay()));
      await api.keyDown(key: GameKeyConfig.to.getQKey());
      await api.keyUp(key: GameKeyConfig.to.getQKey());
      await Future.delayed(Duration(milliseconds: AutoTpConfig.to.getQmQDelay()));
    }
    await runScript(tpPoint.code);
  }
}
