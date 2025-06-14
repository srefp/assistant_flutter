import 'dart:ffi';

import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/config/hotkey_config.dart';
import 'package:assistant/key_mouse/mouse_event.dart';
import 'package:assistant/win32/key_mouse_listen.dart';

import '../app/windows_app.dart';
import '../notifier/log_model.dart';

typedef HookProc = int Function(int, int, int);
typedef ListenProc = int Function(Pointer);

void mouseListener(MouseEvent event) {
  if (!WindowsApp.autoTpModel.active()) {
    return;
  }

  print('event: ${event.name}, down: ${event.down} x: ${event.x}, y: ${event.y} type: ${event.type}');
  String mouseName = event.name;
  bool down = event.down;

  keyMouseListen(mouseName, down);

  List<int> coords = KeyMouseUtil.logicalPos([event.x, event.y]);

  if (WindowsApp.recordModel.isRecording) {
    recordMouse(event, coords);
  }
}

void recordTpc(String name, bool down, List<int> coords) {
  if (name == HotkeyConfig.to.getHalfTp()) {
    WindowsApp.logModel.appendOperation(Operation(
        func: "tpc", template: "tpc([${coords[0]}, ${coords[1]}], 0);"));

    WindowsApp.logModel.outputAsRoute();
  }
}

void recordMouse(MouseEvent event, List<int> coords) {
  int delay = WindowsApp.recordModel.getDelay();
  WindowsApp.logModel.appendDelay(delay);

  switch (event.type) {
    case MouseEventType.leftButtonDown:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mDown',
          coords: coords,
          template: 'mDown([${coords[0]}, ${coords[1]}], %s);',
          prevDelay: delay));
      break;
    case MouseEventType.leftButtonUp:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mUp',
          coords: coords,
          template: 'mUp([${coords[0]}, ${coords[1]}], %s);',
          prevDelay: delay));
      break;
    case MouseEventType.rightButtonDown:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mDownRight',
          coords: coords,
          template: "mDown('right', '[${coords[0]}, ${coords[1]}], %s);",
          prevDelay: delay));
      break;
    case MouseEventType.rightButtonUp:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mUpRight',
          coords: coords,
          template: "mUp('right', '[${coords[0]}, ${coords[1]}], %s);",
          prevDelay: delay));
      break;
    case MouseEventType.wheelUp:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'wheel', template: "wheel(1, %s);", prevDelay: delay));
      break;
    case MouseEventType.wheelDown:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'wheel', template: "wheel(-1, %s);", prevDelay: delay));
      break;
    default:
      break;
  }
}
