class TaskContext {
  static final TaskContext _instance = TaskContext._internal();

  TaskContext._internal();

  static instance() {
    return _instance;
  }

  int processHandle = 0;

  setProcessHandle(int handle) {
    processHandle = handle;
  }
}
