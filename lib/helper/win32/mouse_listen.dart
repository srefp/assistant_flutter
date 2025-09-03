import 'dart:ffi';

import '../../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../key_mouse/event_type.dart';
import '../key_mouse/mouse_event.dart';
import 'key_mouse_listen.dart';

typedef HookProc = int Function(int, int, int);
typedef ListenProc = int Function(Pointer);

void mouseListener(MouseEvent event) {
  if (!WindowsApp.autoTpModel.active()) {
    return;
  }

  // print('event: ${event.name}, down: ${event.down} x: ${event.x}, y: ${event.y} type: ${event.type}');
  String mouseName = event.name;
  bool down = event.down;

  List<int> coords = KeyMouseUtil.logicalPos([event.x, event.y]);

  keyMouseListen(EventType.mouse, mouseName, down, coords, mouseEvent: event);
}
