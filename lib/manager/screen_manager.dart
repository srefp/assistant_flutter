import '../constants/window.dart';
import '../win32/models.dart';
import '../win32/task_manager.dart';

class ScreenManager {
  static ScreenManager? _instance;

  static ScreenManager get instance {
    _instance ??= ScreenManager._internal();
    return _instance!;
  }

  ScreenManager._internal();

  int? hWnd;

  refreshWindowHandle() {
    hWnd = findWindowHandle();
  }

  int? findWindowHandle() {
    Task? task;
    for (var value in windowNames) {
      task = findWindowByTitle(value);

      if (task != null) {
        break;
      }
    }
    return task?.mainWindowHandle;
  }

  // 根据窗口名称查找窗口句柄
  Task? findWindowByTitle(String windowTitle) {
    // 调用 FindWindow 函数，第一个参数为类名（这里传 null 表示不指定类名），第二个参数为窗口名称
    final tasks = TaskManager.tasks ?? [];
    for (Task task in tasks) {
      if (task.name.contains(windowTitle)) {
        return task;
      }
    }
    return null;
  }
}
