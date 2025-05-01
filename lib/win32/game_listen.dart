import 'package:assistant/app/windows_app.dart';

import '../manager/screen_manager.dart';

bool detecting = false;

detectWindow() {
  if (detecting) {
    return;
  }

  detecting = true;
  Future.doWhile(() async {
    await Future.delayed(const Duration(milliseconds: 50));

    // 不断更新和检测窗口
    if (!WindowsApp.autoTpModel.isRunning) {
      detecting = false;
    }
    if (ScreenManager.instance.isWindowExist()) {
      ScreenManager.instance.refreshWindowHandle();
      if (!ScreenManager.instance.isWindowExist()) {
        detecting = false;
      }
    }
    return detecting;
  });
}
