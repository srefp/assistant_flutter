import 'dart:ffi';

import 'package:assistant/helper/isolate/win32_event_listen.dart';
import 'package:assistant/helper/screen/screen_manager.dart';
import 'package:assistant/helper/win32/toast.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';

import '../../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../key_mouse/event_type.dart';
import '../key_mouse/mouse_event.dart';
import 'key_mouse_listen.dart';

typedef HookProc = int Function(int, int, int);
typedef ListenProc = int Function(Pointer);

bool gettingWindowHandle = false;

void mouseListener(MouseEvent event) async {
  if (gettingWindowHandle &&
      event.name == 'left_button' &&
      !event.down &&
      !(await windowManager.isFocused())) {
    gettingWindowHandle = false;

    // 获取窗口句柄
    ScreenManager.instance.foregroundWindowHandle = GetForegroundWindow();
    showToast('获取到窗口句柄: ${ScreenManager.instance.foregroundWindowHandle}');
    WindowsApp.autoTpModel.start();
  }

  if (!WindowsApp.autoTpModel.active()) {
    return;
  }

  // print('event: ${event.name}, down: ${event.down} x: ${event.x}, y: ${event.y} type: ${event.type}');
  String mouseName = event.name;
  bool down = event.down;

  List<int> coords = KeyMouseUtil.logicalPos([event.x, event.y]);

  keyMouseListen(EventType.mouse, mouseName, down, coords, mouseEvent: event);
}
