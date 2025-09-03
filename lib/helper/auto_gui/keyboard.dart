import 'operations.dart';

class Keyboard {
  Future<void> keyDown(String key) async {
    await api.keyDown(key: key);
  }

  Future<void> keyUp(String key) async {
    await api.keyUp(key: key);
  }

  Future<void> keyPress(String key) async {
    await api.press(key: key);
  }
}
