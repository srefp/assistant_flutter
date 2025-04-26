import 'package:fluent_ui/fluent_ui.dart';
import 'package:win32/win32.dart';

import '../app/windows_app.dart';
import '../components/win_text.dart';
import '../win32/mouse_listen.dart';

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
      showDialog(
          context: context,
          builder: (context) => ContentDialog(
                title: WinText('错误'),
                content: SizedBox(
                  height: 50,
                  child: Column(
                    children: [
                      WinText('耕地机未开启，无法录制脚本。'),
                    ],
                  ),
                ),
                actions: [
                  FilledButton(
                    child: const WinText('确定'),
                    onPressed: () {
                      Navigator.pop(context); // 关闭模态框
                    },
                  ),
                ],
              ));
      return;
    }

    isRecording = true;

    recordCurrentTime = DateTime.now();
    WindowsApp.logModel.info('开始录制...');
    notifyListeners();
  }

  /// 停止录制
  void stopRecord() {
    // 停止键盘监听
    isRecording = false;

    WindowsApp.logModel.appendDelay(getDelay());
    WindowsApp.logModel.output();
    WindowsApp.logModel.info('停止录制');
    notifyListeners();
  }

  /// 关闭鼠标监听
  void stopMouseHook() {
    if (mouseHook != 0) {
      UnhookWindowsHookEx(mouseHook);
      mouseHook = 0;
    }
  }
}
