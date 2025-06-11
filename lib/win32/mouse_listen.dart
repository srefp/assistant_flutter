import 'dart:ffi';

import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/config/hotkey_config.dart';
import 'package:assistant/constants/script_type.dart';
import 'package:assistant/win32/key_mouse_listen.dart';
import 'package:hid_listener/hid_listener.dart';

import '../app/windows_app.dart';
import '../manager/screen_manager.dart';
import '../notifier/log_model.dart';

typedef HookProc = int Function(int, int, int);
typedef ListenProc = int Function(Pointer);

String getMouseButtonName(MouseButtonEventType type) {
  switch (type) {
    case MouseButtonEventType.leftButtonDown:
      return 'left_button';
    case MouseButtonEventType.leftButtonUp:
      return 'left_button';
    case MouseButtonEventType.rightButtonDown:
      return 'right_button';
    case MouseButtonEventType.rightButtonUp:
      return 'right_button';
    case MouseButtonEventType.x1ButtonDown:
      return 'xbutton1';
    case MouseButtonEventType.x1ButtonUp:
      return 'xbutton1';
    case MouseButtonEventType.x2ButtonDown:
      return 'xbutton2';
    case MouseButtonEventType.x2ButtonUp:
      return 'xbutton2';
    case MouseButtonEventType.middleButtonDown:
      return 'middle_button';
    case MouseButtonEventType.middleButtonUp:
      return 'middle_button';
  }
}

bool getMouseButtonDown(MouseButtonEventType type) {
  switch (type) {
    case MouseButtonEventType.leftButtonDown:
      return true;
    case MouseButtonEventType.leftButtonUp:
      return false;
    case MouseButtonEventType.rightButtonDown:
      return true;
    case MouseButtonEventType.rightButtonUp:
      return false;
    case MouseButtonEventType.x1ButtonDown:
      return true;
    case MouseButtonEventType.x1ButtonUp:
      return false;
    case MouseButtonEventType.x2ButtonDown:
      return true;
    case MouseButtonEventType.x2ButtonUp:
      return false;
    case MouseButtonEventType.middleButtonDown:
      return true;
    case MouseButtonEventType.middleButtonUp:
      return false;
  }
}

void mouseListener(MouseEvent event) {
  if (event is MouseMoveEvent) {
    return;
  }

  if (!WindowsApp.autoTpModel.active()) {
    return;
  }

  if (event is MouseButtonEvent) {
    String mouseName = getMouseButtonName(event.type);
    bool down = getMouseButtonDown(event.type);

    keyMouseListen(mouseName, down);

    List<int> coords = KeyMouseUtil.logicalPos([event.x, event.y]);

    if (WindowsApp.recordModel.isRecording) {
      if (WindowsApp.scriptEditorModel.selectedScriptType == autoTp) {
        recordRouteMouse(event, coords);
      } else {
        recordScriptMouse(event, coords);
      }
    }
  }
}

void recordTpc(String name, bool down, List<int> coords) {
  if (name == HotkeyConfig.to.getHalfTp()) {
    WindowsApp.logModel.appendOperation(Operation(
        func: "tpc", template: "tpc([${coords[0]}, ${coords[1]}], 0);"));

    WindowsApp.logModel.outputAsRoute();
  }
}

void recordRouteMouse(MouseButtonEvent event, List<int> coords) {
  int delay = WindowsApp.recordModel.getDelay();
  WindowsApp.logModel.appendDelay(delay);

  switch (event.type) {
    case MouseButtonEventType.leftButtonDown:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mDown',
          coords: coords,
          template: 'mDown([${coords[0]}, ${coords[1]}], %s);',
          prevDelay: delay));
      break;
    case MouseButtonEventType.leftButtonUp:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mUp',
          coords: coords,
          template: 'mUp([${coords[0]}, ${coords[1]}], %s);',
          prevDelay: delay));
      break;
    case MouseButtonEventType.rightButtonDown:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mDownRight',
          coords: coords,
          template: "mDown('right', '[${coords[0]}, ${coords[1]}], %s);",
          prevDelay: delay));
      break;
    case MouseButtonEventType.rightButtonUp:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mUpRight',
          coords: coords,
          template: "mUp('right', '[${coords[0]}, ${coords[1]}], %s);",
          prevDelay: delay));
      break;
    default:
      break;
    // case WM_MOUSEWHEEL:
    //   final mouseStruct = Pointer<MSLLHOOKSTRUCT>.fromAddress(lParam);
    //   final wheelDelta = HIWORD(mouseStruct.ref.mouseData);
    //   WindowsApp.logModel.appendOperation(Operation(
    //       func: 'wheel',
    //       template: "wheel(${wheelDelta > 32768 ? 1 : -1}, %s);",
    //       prevDelay: delay));
    //   break;
  }
}

void recordScriptMouse(MouseButtonEvent event, List<int> coords) {
  int delay = WindowsApp.recordModel.getDelay();

  WindowsApp.logModel.appendDelay(delay);
  WindowsApp.logModel.outputAsScript();

  switch (event.type) {
    case MouseButtonEventType.leftButtonDown:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mDown',
          coords: coords,
          template: 'mDown([${coords[0]}, ${coords[1]}], %s);',
          prevDelay: delay));
      break;
    case MouseButtonEventType.leftButtonUp:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mUp',
          coords: coords,
          template: 'mUp([${coords[0]}, ${coords[1]}], %s);',
          prevDelay: delay));
      break;
    case MouseButtonEventType.rightButtonDown:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mDownRight',
          coords: coords,
          template: "mDown('right', '[${coords[0]}, ${coords[1]}], %s);",
          prevDelay: delay));
      break;
    case MouseButtonEventType.rightButtonUp:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mUpRight',
          coords: coords,
          template: "mUp('right', '[${coords[0]}, ${coords[1]}], %s);",
          prevDelay: delay));
      break;
    default:
      break;
  }
}
