import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

// 定义定时器 ID
const timerId = 1;

Future<void> showToast(String message, {int delay = 3000}) async {
  // 获取当前鼠标位置
  final point = calloc<POINT>();
  GetCursorPos(point);
  final x = point.ref.x;
  final y = point.ref.y;

  // 获取屏幕分辨率
  final screenWidth = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CXSCREEN);
  final screenHeight = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CYSCREEN);

  // 窗口的宽度和高度
  const windowWidth = 200;
  const windowHeight = 100;

  // 计算窗口的位置
  var windowX = x;
  var windowY = y;

  // 如果鼠标在右下角，调整窗口位置到鼠标左上方
  if (x + windowWidth > screenWidth) {
    windowX = x - windowWidth;
  }
  if (y + windowHeight > screenHeight) {
    windowY = y - windowHeight;
  }

  // 注册窗口类
  final hInstance = GetModuleHandle(nullptr);
  final wc = calloc<WNDCLASS>();
  wc.ref.style = WNDCLASS_STYLES.CS_HREDRAW | WNDCLASS_STYLES.CS_VREDRAW;
  wc.ref.lpfnWndProc = Pointer.fromFunction(windowProcedure, 0);
  wc.ref.hInstance = hInstance;
  wc.ref.hCursor = LoadCursor(NULL, IDC_ARROW);
  wc.ref.lpszClassName = TEXT('MousePositionWindow');

  // 尝试注销之前的窗口类
  UnregisterClass(TEXT('MousePositionWindow'), hInstance);
  RegisterClass(wc);

  // 创建窗口
  final hWnd = CreateWindowEx(
    WINDOW_EX_STYLE.WS_EX_TOOLWINDOW,
    TEXT('MousePositionWindow'),
    TEXT('Mouse Position'),
    WINDOW_STYLE.WS_POPUP,
    windowX,
    windowY,
    windowWidth,
    windowHeight,
    NULL,
    NULL,
    hInstance,
    message.toNativeUtf16().cast(),
  );

  // 显示窗口
  ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_SHOWNORMAL);
  // 将窗口置于最顶层
  SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SET_WINDOW_POS_FLAGS.SWP_NOMOVE | SET_WINDOW_POS_FLAGS.SWP_NOSIZE);
  UpdateWindow(hWnd);

  // 设置定时器
  SetTimer(hWnd, timerId, delay, nullptr);

  // 异步消息循环
  final msg = calloc<MSG>();

  try {
    // 异步等待窗口关闭
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));

      while (PeekMessage(msg, NULL, 0, 0, PEEK_MESSAGE_REMOVE_TYPE.PM_REMOVE) != 0) {
        TranslateMessage(msg);
        DispatchMessage(msg);
      }

      // 手动设置鼠标光标为正常箭头
      SetCursor(LoadCursor(NULL, IDC_ARROW));
      return IsWindow(hWnd) != 0;
    });
  } finally {
    // 确保资源在任何情况下都被释放
    if (IsWindow(hWnd) != 0) {
      DestroyWindow(hWnd);
    }
    KillTimer(hWnd, timerId);
    calloc.free(msg);
    calloc.free(wc);
    calloc.free(point);
  }
}

String? message;

// 窗口过程函数
int windowProcedure(int hWnd, int msg, int wParam, int lParam) {
  if (msg == WM_CREATE) {
    final createStruct = Pointer.fromAddress(lParam).cast<CREATESTRUCT>();
    message = createStruct.ref.lpCreateParams.cast<Utf16>().toDartString();
  }
  switch (msg) {
    case WM_DESTROY:
      PostQuitMessage(0);
      return 0;
    case WM_TIMER:
      if (wParam == timerId) {
        // 定时器触发，关闭窗口
        if (DestroyWindow(hWnd) == 0) {
          throw Exception('窗口销毁失败');
        }
        // 销毁定时器
        KillTimer(hWnd, timerId);
      }
      return 0;
    case WM_PAINT:
      final ps = calloc<PAINTSTRUCT>();
      final hdc = BeginPaint(hWnd, ps);

      // 加载字体文件
      final fontPath = 'assets/font/MiSans-Regular.ttf';
      final fontCount = AddFontResourceEx(TEXT(fontPath), 0x10, nullptr);
      if (fontCount == 0) {
        throw Exception('字体加载失败');
      }

      final logFont = calloc<LOGFONT>();

      // 设置字体属性
      logFont.ref
        ..lfHeight = -24
        ..lfWidth = 0
        ..lfEscapement = 0
        ..lfOrientation = 0
        ..lfItalic = FALSE
        ..lfUnderline = FALSE
        ..lfStrikeOut = FALSE
        ..lfCharSet = FONT_CHARSET.DEFAULT_CHARSET;
      logFont.ref.lfFaceName = 'MiSans';
      // 创建字体
      final hFont = CreateFontIndirect(logFont);
      free(logFont);

      if (hFont == NULL) {
        throw Exception('字体创建失败');
      }

      // 选择字体
      SelectObject(hdc, hFont);

      // 显示鼠标位置信息
      final text = ' $message ';

      // 计算文本的大小
      final rect = calloc<RECT>();
      DrawText(hdc, TEXT(text), -1, rect, DRAW_TEXT_FORMAT.DT_CALCRECT);
      final textWidth = rect.ref.right - rect.ref.left;
      final textHeight = rect.ref.bottom - rect.ref.top;

      // 调整窗口大小以适应文本
      SetWindowPos(hWnd, NULL, 0, 0, textWidth + 20, textHeight + 20, SET_WINDOW_POS_FLAGS.SWP_NOMOVE | SET_WINDOW_POS_FLAGS.SWP_NOZORDER);

      TextOut(hdc, 10, 10, TEXT(text), text.length);

      EndPaint(hWnd, ps);
      calloc.free(ps);

      // 删除字体对象
      DeleteObject(hFont);

      return 0;
  }
  return DefWindowProc(hWnd, msg, wParam, lParam);
}
