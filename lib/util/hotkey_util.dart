import 'dart:ffi';

import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/util/tpc.dart';
import 'package:assistant/win32/key_listen.dart';
import 'package:assistant/win32/toast.dart';
import 'package:win32/win32.dart';

import '../app/windows_app.dart';
import '../config/hotkey_config.dart';
import '../screens/virtual_screen.dart';
import '../win32/mouse_listen.dart';

/// 监听鼠标
void listenMouse(Pointer<MSLLHOOKSTRUCT> mouseStruct, int wParam, int lParam) {
  final mouseData = mouseStruct.ref.mouseData;

  // 判断是否是鼠标左键单击
  if (foodRecording && wParam == WM_LBUTTONDOWN) {
    List<int> point = KeyMouseUtil.getMousePos();
    List<int> virtualPos = getVirtualPos(point);
    var text = '${virtualPos[0]}, ${virtualPos[1]}';
    AutoTpConfig.to.addFoodPos(text);
    WindowsApp.autoTpModel.fresh();
    showToast('已记录坐标：$text');
  }

  if (wParam == WM_XBUTTONDOWN) {
    final xButton = (mouseData >> 16) & 0xFFFF;
    final xButtonName = xButton == xbutton1 ? 'xbutton1' : 'xbutton2';

    if (xButtonName == HotkeyConfig.to.getHalfTp()) {
      tpc();
    }
  }
}
