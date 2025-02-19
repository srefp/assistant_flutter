import 'package:flutter_auto_gui_windows/flutter_auto_gui_windows.dart';

final _api = FlutterAutoGuiWindows();

class Keyboard {
  Future<void> keyDown(String key) async {
    await _api.keyDown(key: key);
  }

  Future<void> keyUp(String key) async {
    await _api.keyUp(key: key);
  }

  Future<void> keyPress(String key)  async {
    await _api.press(key: key);
  }
}