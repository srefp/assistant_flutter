import 'package:assistant/win32/models.dart';
import 'package:assistant/win32/task_manager.dart';

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

void main() {
  // 要查找的窗口名称
  List<String> targetWindowTitle = ["Notepad", "YuanShen", "GenshinImpact", "Genshin Impact Cloud Game"];
  // 调用查找函数
  Task? task;
  for (var value in targetWindowTitle) {
    task = findWindowByTitle(value);

    if (task != null) {
      break;
    }
  }
  if (task != null) {
    print('找到窗口: ${task.pid} ${task.mainWindowHandle} ${task.name}');
  } else {
    print('未找到窗口');
  }
}
