class TaskContext {
  static final TaskContext _instance = TaskContext._internal();

  TaskContext._internal();

  static instance() {
    return _instance;
  }

  int gameHandle = 0;

  setGameHandle(int handle) {
    gameHandle = handle;
  }
}
