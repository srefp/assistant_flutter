import 'package:assistant/app/windows_app.dart';
import 'package:assistant/helper/js/js_executor.dart';
import 'package:assistant/helper/script_parser.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_auto_gui/flutter_auto_gui.dart';

import '../../app/config/auto_tp_config.dart';
import '../../app/config/process_key_config.dart';
import '../../component/dialog.dart';
import '../../component/text/win_text.dart';
import '../auto_gui/operations.dart';
import '../win32/toast.dart';

class RouteExecutor {
  static bool tpForbidden = false;
  static AutoTpConfig config = AutoTpConfig.to;

  static void toPrev() {
    var tpPoints = WindowsApp.scriptEditorModel.tpPoints;

    if (config.getRouteIndex() > 1 &&
        config.getRouteIndex() <= tpPoints.length) {
      config.save(AutoTpConfig.keyRouteIndex, config.getRouteIndex() - 1);
    }

    // 刷新当前位置
    final curPos = tpPoints[config.getRouteIndex() - 1].name ??
        '点位${config.getRouteIndex()}';
    WindowsApp.scriptEditorModel.selectPos(curPos);
  }

  static void toByName(String name) {
    var tpPoints = WindowsApp.scriptEditorModel.tpPoints;
    for (var i = 0; i < tpPoints.length; i++) {
      if (tpPoints[i].name == name) {
        config.save(AutoTpConfig.keyRouteIndex, i + 1);
        break;
      }
    }
  }

  static void toNext() {
    var tpPoints = WindowsApp.scriptEditorModel.tpPoints;

    if (config.getRouteIndex() >= 0 &&
        config.getRouteIndex() < tpPoints.length) {
      config.save(AutoTpConfig.keyRouteIndex, config.getRouteIndex() + 1);
    }

    // 刷新当前位置
    final curPos = tpPoints[config.getRouteIndex() - 1].name ??
        '点位${config.getRouteIndex()}';
    WindowsApp.scriptEditorModel.selectPos(curPos);
  }

  static Future<void> tpNext(bool qm) async {
    if (!config.isAutoTpEnabled()) {
      return;
    }

    if (tpForbidden) {
      return;
    }

    tpForbidden = true;

    try {
      var tpPoints = WindowsApp.scriptEditorModel.tpPoints;
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
        WindowsApp.scriptEditorModel.selectPos(curPos);
      } else {
        showToast('当前路线已结束！');
      }
    } catch (e) {
      dialog(
        title: '脚本执行出错',
        child: SizedBox(
          height: 200,
          child: ListView(
            children: [
              WinText(e.toString()),
            ],
          ),
        ),
      );
    } finally {
      Future.delayed(Duration(milliseconds: AutoTpConfig.to.getTpCooldown()),
          () {
        tpForbidden = false;
      });
    }
  }

  static Future<void> executeStep(BlockItem tpPoint, bool qmParam) async {
    if (qmParam) {
      await api.keyDown(key: ProcessKeyConfig.to.getForwardKey());
      await api.keyUp(key: ProcessKeyConfig.to.getForwardKey());
      if (AutoTpConfig.to.isQmDash()) {
        await api.click(button: MouseButton.right);
      }
      await Future.delayed(
          Duration(milliseconds: AutoTpConfig.to.getQmDashDelay()));
      await api.keyDown(key: ProcessKeyConfig.to.getQKey());
      await api.keyUp(key: ProcessKeyConfig.to.getQKey());
      await Future.delayed(
          Duration(milliseconds: AutoTpConfig.to.getQmQDelay()));
    }
    await runScript(tpPoint.code);
  }
}
