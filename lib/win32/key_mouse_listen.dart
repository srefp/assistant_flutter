import 'dart:async';

import 'package:assistant/key_mouse/event_type.dart';
import 'package:assistant/key_mouse/keyboard_event.dart';
import 'package:assistant/key_mouse/mouse_event.dart';
import 'package:assistant/util/js/js_executor.dart';
import 'package:assistant/win32/key_listen.dart';
import 'package:assistant/win32/toast.dart';

import '../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../config/auto_tp_config.dart';
import '../constants/macro_trigger_type.dart';
import '../constants/profile_status.dart';
import '../key_mouse/mouse_button.dart';
import '../util/cv/cv_helper.dart';

bool mapping = true;
bool clickEntry = true;
const stopScript = 'stopScript();';

/// 全局标志：脚本结束后通知dart将该标志置为false
bool macroRunning = false;

/// 键鼠监听回调
void keyMouseListen(
    EventType eventType, String name, bool down, List<int> coords,
    {KeyboardEvent? keyEvent, MouseEvent? mouseEvent}) async {
  listenAll(name, down);

  // 记录截图开始位置
  if (recordMouseDownPos && eventType == EventType.mouse && down) {
    mouseDownPos = KeyMouseUtil.physicalPos(coords);
    recordMouseDownPos = false;
    recordMouseUpPos = true;
  }

  // 记录截图结束位置
  if (recordMouseUpPos && eventType == EventType.mouse && !down) {
    mouseUpPos = KeyMouseUtil.physicalPos(coords);
    recordMouseUpPos = false;
  }

  WindowsApp.logModel.record(eventType, name, down, coords, mouseEvent);

  for (var macro in WindowsApp.macroModel.macroList) {
    if (macro.status == ProfileStatus.active && macro.triggerKey == name) {
      if (down && macro.triggerType == MacroTriggerType.down) {
        runScript(macro.script, stoppable: true);
        return;
      } else if (down && macro.triggerType == MacroTriggerType.downStoppable) {
        if (macro.running) {
          await runScript(stopScript);
          macro.running = false;
          return;
        } else {
          macro.running = true;
          await runScript(macro.script, stoppable: true);
          macro.running = false;
          return;
        }
      } else if (!down && macro.triggerType == MacroTriggerType.up) {
        runScript(macro.script, stoppable: true);
        return;
      } else if (macro.triggerType == MacroTriggerType.longDownCycle) {
        if (down) {
          macro.loopRunning = true;
          macro.macroFuture ??= Future.doWhile(() async {
            try {
              await runScript(macro.script, stoppable: true);
            } catch (e) {
              macro.loopRunning = false;
              macro.macroFuture = null;
            }
            return macro.loopRunning && WindowsApp.autoTpModel.active();
          });
        } else {
          await runScript(stopScript);
          macro.loopRunning = false;
          macro.macroFuture = null;
        }
      } else if (macro.triggerType == MacroTriggerType.toggle) {
        if (down) {
          if (!macro.loopRunning) {
            if (!macro.canStart) {
              return;
            }
            print('开始运行');
            macro.loopRunning = true;
            macro.macroFuture ??= Future.doWhile(() async {
              try {
                print('执行脚本');
                await runScript(macro.script, stoppable: true);
              } catch (e) {
                macro.loopRunning = false;
                macro.macroFuture = null;
              }
              return macro.loopRunning && WindowsApp.autoTpModel.active();
            });
          } else {
            if (macro.canStop) {
              print('结束运行');
              await runScript(stopScript);
              macro.canStop = false;
              macro.canStart = false;
              macro.loopRunning = false;
              macro.macroFuture = null;
            }
          }
        } else {
          if (macro.loopRunning) {
            macro.canStop = true;
          } else {
            macro.canStart = true;
          }
        }
      } else if (macro.triggerType == MacroTriggerType.doubleDown) {
        if (down) {
          if (macro.canRunFor2) {
            macro.canRunFor2 = false;
            await runScript(macro.script, stoppable: true);
          } else {
            macro.canRunFor2 = true;
            Future.delayed(Duration(milliseconds: 350)).then((value) {
              macro.canRunFor2 = false;
            });
          }
        }
      } else if (macro.triggerType == MacroTriggerType.longDown) {
        if (down) {
          if (!macro.canRunForLong) {
            return;
          }
          if (macro.longPressStartTime == 0) {
            macro.longPressStartTime = DateTime.now().millisecondsSinceEpoch;
          } else if (DateTime.now().millisecondsSinceEpoch -
                  macro.longPressStartTime >
              1000) {
            macro.longPressStartTime = 0;
            macro.canRunForLong = false;
            await runScript(macro.script, stoppable: true);
          }
        } else {
          macro.longPressStartTime = 0;
          macro.canRunForLong = true;
        }
      }
    }
  }

  if (!down) {
    return;
  }

  if (name == leftButton && down) {
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
}
