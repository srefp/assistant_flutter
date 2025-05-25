import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/util/tpc.dart';
import 'package:assistant/win32/key_listen.dart';
import 'package:assistant/win32/toast.dart';
import 'package:hid_listener/hid_listener.dart';

import '../app/windows_app.dart';

/// 监听鼠标
void listenMouse(MouseButtonEvent event) {
  // 判断是否是鼠标左键单击
  if (foodRecording && event.type == MouseButtonEventType.leftButtonDown) {
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

  if (event.type == MouseButtonEventType.x2ButtonDown) {
      tpc();
  }

  // if (xButtonName == HotkeyConfig.to.getTpNext()) {
  //   RouteExecutor.tpNext(false);
  // }
}
