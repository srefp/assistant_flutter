import 'package:assistant/config/auto_tp_config.dart';
import 'package:win32/win32.dart';

import '../win32/models.dart';
import '../win32/task_manager.dart';

class ScreenManager {
  static ScreenManager? _instance;

  static ScreenManager get instance {
    _instance ??= ScreenManager._internal();
    return _instance!;
  }

  ScreenManager._internal();

  int hWnd = 0;

  /// 判断窗口是否存在
  bool isWindowExist() {
    return hWnd != 0;
  }

  refreshWindowHandle() {
    final tasks = TaskManager.tasks;
    hWnd = findWindowHandle(tasks);
  }

  /// 判断游戏窗口是否置顶
  bool isGameActive() {
    var hWnd = GetForegroundWindow();
    return hWnd == ScreenManager.instance.hWnd;
  }

  int findWindowHandle(final List<Task>? tasks) {
    Task? task;
    for (var value in AutoTpConfig.to.windowTitles) {
      task = findWindowByTitle(value, tasks);

      if (task != null) {
        break;
      }
    }

    if (task == null) {
      return 0;
    }

    int? mainHandle = TaskManager.getMainHandle(task.pid);
    return mainHandle ?? 0;
  }

  // 根据进程名称查找窗口句柄
  Task? findWindowByTitle(String windowTitle, final List<Task>? currentTasks) {
    final tasks = currentTasks ?? [];
    for (Task task in tasks) {
      if (task.name.contains(windowTitle)) {
        return task;
      }
    }
    return null;
  }
}
