/// A Windows task with its icon, name, PID, and description.
class Task {
  Task({
    required this.name,
    required this.pid,
    this.hWnd,
    this.windowName,
  });

  /// The name of the task.
  final String name;

  /// The PID (Process ID) of the task.
  final int pid;

  /// The hWnd
  int? hWnd;

  /// The window name
  String? windowName;

  @override
  toString() {
    return 'Task(name: $name, pid: $pid, hWnd: $hWnd, windowName: $windowName)';
  }
}
