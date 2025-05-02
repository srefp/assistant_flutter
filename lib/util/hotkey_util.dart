import 'dart:ffi';

import 'package:assistant/util/tpc.dart';
import 'package:win32/win32.dart';

import '../config/hotkey_config.dart';
import '../win32/mouse_listen.dart';

/// 监听鼠标
void listenMouse(Pointer<MSLLHOOKSTRUCT> mouseStruct, int wParam, int lParam) {
  final mouseData = mouseStruct.ref.mouseData;
  if (wParam == WM_XBUTTONDOWN) {
    final xButton = (mouseData >> 16) & 0xFFFF;
    final xButtonName = xButton == xbutton1 ? 'xbutton1' : 'xbutton2';

    if (xButtonName == HotkeyConfig.to.getHalfTp()) {
      tpc();
    }
  }
}