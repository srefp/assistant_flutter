import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'models.dart';

/// Provides functionality for managing Windows tasks, including:
/// - Enumerating running tasks
/// - Running a new task
/// - Terminating a running task
abstract class TaskManager {
  /// Runs a new task from the specified [path].
  ///
  /// Returns `true` if the task was successfully started; otherwise, `false`.
  static bool run(String path) {
    final lpFile = path.toNativeUtf16();
    final result = ShellExecute(
      0,
      'open'.toNativeUtf16(),
      lpFile,
      nullptr,
      nullptr,
      SHOW_WINDOW_CMD.SW_SHOWNORMAL,
    );
    free(lpFile);
    return result > 32;
  }

  /// Retrieves a list of currently running tasks.
  ///
  /// Returns `null` if retrieval failed.
  static List<Task>? get tasks {
    return using((arena) {
      final tasks = <Task>[];

      final buffer = arena<Uint32>(1024);
      final cbNeeded = arena<Uint32>();

      if (EnumProcesses(buffer, sizeOf<Uint32>() * 1024, cbNeeded) == FALSE) {
        return null;
      }

      final processCount = cbNeeded.value ~/ sizeOf<Uint32>();
      final processIds = buffer.asTypedList(processCount);

      for (final pid in processIds) {
        final hProcess = OpenProcess(
          PROCESS_ACCESS_RIGHTS.PROCESS_QUERY_INFORMATION,
          FALSE,
          pid,
        );

        final queryFunc = DynamicLibrary.process().lookupFunction<
            Int32 Function(IntPtr hProcess, Uint32 dwFlags, Pointer<Utf16> lpExeName, Pointer<DWORD> lpdwSize),
            int Function(int hProcess, int dwFlags, Pointer<Utf16> lpExeName, Pointer<DWORD> lpdwSize)
        >('QueryFullProcessImageNameW');

        final buffer = arena<WCHAR>(MAX_PATH).cast<Utf16>();
        final size = arena<DWORD>()..value = MAX_PATH;

        final success = queryFunc(
          hProcess,
          0,
          buffer,
          size,
        );

        String? processName;
        if (success == 1) {
          final fullPath = buffer.toDartString();
          processName = fullPath.split(r'\').last;

          final task = Task(
            name: processName,
            pid: pid,
          );
          tasks.add(task);
        }

        CloseHandle(hProcess);
      }

      return tasks;
    });
  }

  static int? getMainHandle(int pid) {
    int? mainHandle;

    int enumWindowsProc(int hWnd, int lParam) {
      final pidPtr = calloc<Uint32>();
      GetWindowThreadProcessId(hWnd, pidPtr);
      calloc.free(pidPtr);

      if (pidPtr.value == pid) {
        if (GetParent(hWnd) == NULL && IsWindowVisible(hWnd) != FALSE) {
          mainHandle = hWnd;
          return TRUE;
        }
      }

      return TRUE;
    }

    final lpEnumFunc = NativeCallable<WNDENUMPROC>.isolateLocal(
      enumWindowsProc,
      exceptionalReturn: 0,
    );
    EnumWindows(lpEnumFunc.nativeFunction, 0);
    lpEnumFunc.close();
    return mainHandle;
  }

  /// Terminates a running task with the given [pid].
  ///
  /// Returns `true` if the task was successfully terminated; otherwise,
  /// `false`.
  static bool terminate(int pid) {
    final handle =
        OpenProcess(PROCESS_ACCESS_RIGHTS.PROCESS_TERMINATE, FALSE, pid);
    if (handle == NULL) return false;

    try {
      return TerminateProcess(handle, 0) == TRUE;
    } finally {
      CloseHandle(handle);
    }
  }
}
