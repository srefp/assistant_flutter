import 'dart:async';

import 'package:assistant/util/js_executor.dart';
import 'package:assistant/win32/key_listen.dart';
import 'package:assistant/win32/toast.dart';

import '../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../config/auto_tp_config.dart';
import '../config/hotkey_config.dart';
import '../constants/macro_trigger_type.dart';
import '../constants/profile_status.dart';
import '../constants/script_type.dart';
import '../executor/route_executor.dart';
import '../util/tpc.dart';
import 'mouse_listen.dart';

bool mapping = true;
bool clickEntry = true;

/// 键鼠监听回调
void keyMouseListen(name, down) async {
  listenAll(name, down);

  if (WindowsApp.recordModel.isRecording) {
    if (WindowsApp.scriptEditorModel.selectedScriptType == autoTp) {
      recordRoute(name, down);
    } else {
      recordScript(name, down);
    }
  }

  for (var macro in WindowsApp.macroModel.macroList) {
    if (macro.status == ProfileStatus.active && macro.triggerKey == name) {
      if (down && macro.triggerType == MacroTriggerType.down) {
        runScript(macro.script);
        return;
      } else if (!down && macro.triggerType == MacroTriggerType.up) {
        runScript(macro.script);
        return;
      } else if (macro.triggerType == MacroTriggerType.longDownCycle) {
        if (down) {
          macro.loopRunning = true;
          macro.macroFuture ??= Future.doWhile(() async {
            try {
              await runScript(macro.script);
            } catch (e) {
              macro.loopRunning = false;
              macro.macroFuture = null;
            }
            return macro.loopRunning && WindowsApp.autoTpModel.active();
          });
        } else {
          macro.loopRunning = false;
          macro.macroFuture = null;
        }
      } else if (macro.triggerType == MacroTriggerType.toggle) {
        if (down) {
          if (!macro.loopRunning) {
            print('开始运行');
            macro.loopRunning = true;
            macro.macroFuture ??= Future.doWhile(() async {
              try {
                print('执行脚本');
                await runScript(macro.script);
              } catch (e) {
                macro.loopRunning = false;
                macro.macroFuture = null;
              }
              return macro.loopRunning && WindowsApp.autoTpModel.active();
            });
          } else {
            if (macro.canStop) {
              print('结束运行');
              macro.canStop = false;
              macro.loopRunning = false;
              macro.macroFuture = null;
            }
          }
        } else {
          if (macro.loopRunning) {
            macro.canStop = true;
          }
        }
      }
    }
  }

  if (!down) {
    return;
  }

  if (WindowsApp.recordModel.isRecording) {
    if (WindowsApp.scriptEditorModel.selectedScriptType == autoTp) {
      // 获取当前鼠标位置
      List<int> coords =
          KeyMouseUtil.logicalPos(KeyMouseUtil.getMousePosOfWindow());
      recordTpc(name, down, coords);
    }
  }

  if (name == 'left_button' && down) {
    // 判断是否是鼠标左键单击
    if (foodRecording) {
      List<int> point = KeyMouseUtil.getMousePosOfWindow();
      if (point[0] == -1 || point[1] == -1) {
        return;
      }
      List<int> virtualPos = KeyMouseUtil.logicalPos(point);
      var text = '${virtualPos[0]}, ${virtualPos[1]}';
      AutoTpConfig.to.addFoodPos(text);
      WindowsApp.autoTpModel.fresh();
      showToast('已记录坐标：$text');
    } else if (mapping && clickEntry) {
      //   clickEntry = false;
      //   // 双击
      //   var currentPos = await api.position();
      //
      //   var now = DateTime.now();
      //   print('开始检测锚点');
      //   while (DateTime.now().difference(now).inMilliseconds < 350) {
      //     var res = await GamePicInfo.to.anchorConfirm.scan();
      //     print('确认锚点：${res.maxMatchValue}');
      //     if (res.maxMatchValue >= matchThreshold) {
      //       print('点击123789');
      //       await KeyMouseUtil.clickAtPoint(
      //           GamePosConfig.to.getConfirmPosIntList(), 0);
      //       await Future.delayed(Duration(milliseconds: 100));
      //       api.moveTo(point: currentPos!);
      //       break;
      //     }
      //   }
      //   Future.delayed(Duration(milliseconds: 350)).then((value) => clickEntry = true);
    }
  }

  if (name == HotkeyConfig.to.getHalfTp() && down) {
    executeTpc();
  } else if (name == HotkeyConfig.to.getQmTpNext() && down) {
    RouteExecutor.tpNext(true);
  } else if (name == HotkeyConfig.to.getTpNext() && down) {
    RouteExecutor.tpNext(false);
  }
}
