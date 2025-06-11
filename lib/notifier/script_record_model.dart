import 'package:fluent_ui/fluent_ui.dart';

import '../app/windows_app.dart';
import '../manager/screen_manager.dart';
import '../win32/window.dart';

class ScriptRecordModel extends ChangeNotifier {
  bool isRecording = false;

  /// 录制开始时间
  DateTime recordCurrentTime = DateTime.now();

  getDelay() {
    final int delay =
        DateTime.now().difference(recordCurrentTime).inMilliseconds;
    recordCurrentTime = DateTime.now();
    return delay;
  }

  /// 开始录制
  void startRecord(BuildContext context) {
    if (!WindowsApp.autoTpModel.isRunning) {
      bool started = WindowsApp.autoTpModel.start();
      if (!started) {
        return;
      }
    }

    ScreenManager.instance.refreshWindowHandle();
    int? hWnd = ScreenManager.instance.hWnd;
    if (hWnd != 0) {
      setForegroundWindow(hWnd);
    }

    isRecording = true;

    recordCurrentTime = DateTime.now();
    notifyListeners();
  }

  /// 停止录制
  void stopRecord() {
    // 停止键盘监听
    isRecording = false;

    WindowsApp.logModel.appendDelay(getDelay());
    WindowsApp.logModel.output();
    notifyListeners();
  }
}
