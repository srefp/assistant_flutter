import 'package:fluent_ui/fluent_ui.dart';

import '../manager/screen_manager.dart';
import '../model/tp_point.dart';
import '../win32/key_listen.dart';
import '../win32/mouse_listen.dart';
import '../win32/window.dart';

class AutoTpModel extends ChangeNotifier {
  String? selectedDir;
  String? selectedFile;
  int currentRouteIndex = 0;
  List<TpPoint> tpPoints = [];
  bool isRunning = false;

  void setSelectedDir(String dir) {
    selectedDir = dir;
    notifyListeners();
  }

  void setSelectedFile(String file) {
    selectedFile = file;
    notifyListeners();
  }

  void setCurrentRouteIndex(int index) {
    currentRouteIndex = index;
    notifyListeners();
  }

  void start() {
    isRunning = true;
    startKeyboardHook();
    startMouseHook();
    ScreenManager.instance.refreshWindowHandle();
    int? hWnd = ScreenManager.instance.hWnd;
    if (hWnd != null) {
      setForegroundWindow(hWnd);
    }

    notifyListeners();
  }

  void stop() {
    isRunning = false;
    stopKeyboardHook();
    stopMouseHook();

    notifyListeners();
  }
}
