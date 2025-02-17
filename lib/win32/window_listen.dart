import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

// 定义窗口过程回调函数
int windowProc(int hwnd, int msg, int wParam, int lParam) {
  switch (msg) {
    case WM_MOVE:
      // 获取窗口位置
      final rect = calloc<RECT>();
      if (GetWindowRect(hwnd, rect) == TRUE) {
        final left = rect.ref.left;
        final top = rect.ref.top;
        final right = rect.ref.right;
        final bottom = rect.ref.bottom;
        final width = right - left;
        final height = bottom - top;
        print('窗口位置: ($left, $top), 大小: ($width, $height)');
      }
      break;
    default:
      return DefWindowProc(hwnd, msg, wParam, lParam);
  }
  return 0;
}

// void main() {
//   // 初始化 COM 库
//   CoInitializeEx(nullptr, COINIT.COINIT_MULTITHREADED);
//
//   // 注册窗口类
//   final wndClass = WNDCLASS()
//     ..style = CS_HREDRAW | CS_VREDRAW
//     ..lpfnWndProc = Pointer.fromFunction<WNDPROC>(windowProc)
//     ..hInstance = GetModuleHandle(nullptr)
//     ..hCursor = LoadCursor(nullptr, IDC_ARROW)
//     ..lpszClassName = 'MyWindowClass';
//
//   RegisterClass(wndClass);
//
//   // 创建窗口
//   final hwnd = CreateWindowEx(
//     0,
//     'MyWindowClass',
//     'Window Monitor',
//     WS_OVERLAPPEDWINDOW,
//     CW_USEDEFAULT,
//     CW_USEDEFAULT,
//     800,
//     600,
//     nullptr,
//     nullptr,
//     GetModuleHandle(nullptr),
//     nullptr,
//   );
//
//   // 显示窗口
//   ShowWindow(hwnd, SW_SHOWNORMAL);
//   UpdateWindow(hwnd);
//
//   // 消息循环
//   final msg = MSG.allocate();
//   while (GetMessage(msg, nullptr, 0, 0) != 0) {
//     TranslateMessage(msg);
//     DispatchMessage(msg);
//   }
//
//   // 释放 COM 库
//   CoUninitialize();
// }

// 定义回调函数，用于 EnumWindows 枚举窗口
int enumWindowsCallback(int hwnd, int lParam) {
  final titleLength = GetWindowTextLength(hwnd);
  if (titleLength > 0) {
    final titlePtr = calloc<Utf16>(titleLength + 1);
    GetWindowText(hwnd, titlePtr, titleLength + 1);
    final title = titlePtr.toDartString();
    calloc.free(titlePtr);

    // 获取要查找的窗口名
    final targetTitlePtr = Pointer<Utf16>.fromAddress(lParam);
    final targetTitle = targetTitlePtr.toDartString();

    if (title == targetTitle) {
      // 找到匹配的窗口，打印窗口句柄
      print('找到窗口，句柄: $hwnd');
      return FALSE; // 停止枚举
    }
  }
  return TRUE; // 继续枚举
}

void main() {
  // 初始化 COM 库
  CoInitializeEx(nullptr, COINIT.COINIT_MULTITHREADED);

  // 要查找的窗口名
  final targetWindowTitle = '目标窗口名';
  // 修改为使用 toNativeUtf16 后转换为 Uint16 指针
  final targetWindowTitlePtr = targetWindowTitle.toNativeUtf16().cast<Uint16>();

  // 枚举所有顶级窗口
  EnumWindows(
    Pointer.fromFunction<WNDENUMPROC>(enumWindowsCallback, TRUE), // 添加异常返回值
    targetWindowTitlePtr.cast().address,
  );

  calloc.free(targetWindowTitlePtr);

  // 释放 COM 库
  CoUninitialize();
}
