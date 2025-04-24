import 'package:fluent_ui/fluent_ui.dart';
import 'package:win32/win32.dart';

import '../app/windows_app.dart';
import '../win32/key_listen.dart';
import '../win32/mouse_listen.dart';

class ScriptRecordModel extends ChangeNotifier {

  bool isRecording = false;

  /// 录制开始时间
  DateTime recordCurrentTime = DateTime.now();

  getDelay() {
    final int delay = DateTime.now().difference(recordCurrentTime).inMilliseconds;
    recordCurrentTime = DateTime.now();
    return delay;
  }

  /// 开始录制
  void startRecord() {
    isRecording = true;
    startKeyboardHook();
    startMouseHook();

    recordCurrentTime = DateTime.now();
    WindowsApp.logModel.info('开始录制...');
    notifyListeners();
  }

  /// 停止录制
  void stopRecord() {
    // 停止键盘监听
    isRecording = false;
    stopKeyboardHook();
    stopMouseHook();

    WindowsApp.logModel.appendDelay(getDelay());
    WindowsApp.logModel.output();
    WindowsApp.logModel.info('停止录制');
    notifyListeners();
  }

  /// 关闭键盘监听
  void stopKeyboardHook() {
    if (keyboardHook != 0) {
      UnhookWindowsHookEx(keyboardHook);
      keyboardHook = 0;
    }
  }

  /// 关闭鼠标监听
  void stopMouseHook() {
    if (mouseHook != 0) {
      UnhookWindowsHookEx(mouseHook);
      mouseHook = 0;
    }
  }
}