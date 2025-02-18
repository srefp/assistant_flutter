/// A Windows task with its icon, name, PID, and description.
class Task {
  const Task({
    required this.name,
    required this.pid,
  });

  /// The name of the task.
  final String name;

  /// The PID (Process ID) of the task.
  final int pid;
}
