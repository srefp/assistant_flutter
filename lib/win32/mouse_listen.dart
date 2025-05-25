import 'dart:ffi';

import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/constants/script_type.dart';
import 'package:hid_listener/hid_listener.dart';

import '../app/windows_app.dart';
import '../manager/screen_manager.dart';
import '../notifier/log_model.dart';
import '../util/hotkey_util.dart';

typedef HookProc = int Function(int, int, int);
typedef ListenProc = int Function(Pointer);

void mouseListener(MouseEvent event) {
  if (event is MouseMoveEvent) {
    return;
  }

  if (event is MouseButtonEvent) {
    if (WindowsApp.autoTpModel.isRunning && ScreenManager.instance.isGameActive()) {
      listenMouse(event);
    }

    if (WindowsApp.recordModel.isRecording) {
      if (WindowsApp.scriptEditorModel.selectedScriptType == autoTp) {
        recordRoute(event);
      } else {
        recordScript(event);
      }
    }
  }
}

void recordRoute(MouseButtonEvent event) {
  List<int> coords =
      KeyMouseUtil.logicalPos([event.x, event.y]);

  if (event.type == MouseButtonEventType.x2ButtonDown) {
    WindowsApp.logModel.appendOperation(Operation(
        func: "tpc",
        template: "tpc([${coords[0]}, ${coords[1]}], 0);"));

    WindowsApp.logModel.outputAsRoute();
  }

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

void recordScript(MouseButtonEvent event) {
  int delay = WindowsApp.recordModel.getDelay();

  WindowsApp.logModel.appendDelay(delay);
  WindowsApp.logModel.outputAsScript();

  List<int> coords =
  KeyMouseUtil.logicalPos([event.x, event.y]);

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
