import 'package:assistant/win32/key_listen.dart';
import 'package:assistant/win32/toast.dart';

import '../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../config/auto_tp_config.dart';
import '../config/hotkey_config.dart';
import '../constants/script_type.dart';
import '../executor/route_executor.dart';
import '../util/tpc.dart';
import 'mouse_listen.dart';

/// 键鼠监听回调
void keyMouseListen(name, down) {
  listenAll(name, down);

  print('name: $name, down: $down');

  if (WindowsApp.recordModel.isRecording) {
    if (WindowsApp.scriptEditorModel.selectedScriptType == autoTp) {
      recordRoute(name, down);
    } else {
      recordScript(name, down);
    }
  }

  if (!down) {
    return;
  }

  if (WindowsApp.recordModel.isRecording) {
    if (WindowsApp.scriptEditorModel.selectedScriptType == autoTp) {
      // 获取当前鼠标位置
      List<int> coords = KeyMouseUtil.logicalPos(KeyMouseUtil.getMousePosOfWindow());
      recordTpc(name, down, coords);
    }
  }

  // 判断是否是鼠标左键单击
  if (foodRecording && name == 'left_button' && down) {
    List<int> point = KeyMouseUtil.getMousePosOfWindow();
    if (point[0] == -1 || point[1] == -1) {
      return;
    }
    List<int> virtualPos = KeyMouseUtil.logicalPos(point);
    var text = '${virtualPos[0]}, ${virtualPos[1]}';
    AutoTpConfig.to.addFoodPos(text);
    WindowsApp.autoTpModel.fresh();
    showToast('已记录坐标：$text');
  }

  if (name == HotkeyConfig.to.getHalfTp() && down) {
    tpc();
  }

  if (name == HotkeyConfig.to.getTpNext() && down) {
    RouteExecutor.tpNext(false);
  }
}
