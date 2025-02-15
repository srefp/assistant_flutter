import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

// 定义定时器 ID
const TIMER_ID = 1;

Future<void> showToast(String message, {int delay = 3000}) async {
  // 获取当前鼠标位置
  final point = calloc<POINT>();
  GetCursorPos(point);
  final x = point.ref.x; // 修正获取 x 坐标的方式
  final y = point.ref.y; // 修正获取 y 坐标的方式

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
  final wc = calloc<WNDCLASS>(); // 使用 calloc 分配内存
  wc.ref.style = WNDCLASS_STYLES.CS_HREDRAW | WNDCLASS_STYLES.CS_VREDRAW; // 使用新的常量
  wc.ref.lpfnWndProc = Pointer.fromFunction(windowProcedure, 0); // 添加异常返回值
  wc.ref.hInstance = hInstance;
  wc.ref.hCursor = LoadCursor(NULL, IDC_ARROW);
  wc.ref.lpszClassName = TEXT('MousePositionWindow');

  RegisterClass(wc);

  // 创建窗口
  final hWnd = CreateWindow(
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
    message.toNativeUtf16().cast(), // 传递 message
  );

  // 显示窗口
  ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_SHOWNORMAL);
  // 将窗口置于最顶层
  SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SET_WINDOW_POS_FLAGS.SWP_NOMOVE | SET_WINDOW_POS_FLAGS.SWP_NOSIZE);
  UpdateWindow(hWnd);

  // 设置定时器
  SetTimer(hWnd, TIMER_ID, delay, nullptr);

  // 消息循环
  final msg = calloc<MSG>();
  while (GetMessage(msg, NULL, 0, 0) != 0) {
    TranslateMessage(msg);
    DispatchMessage(msg);
  }

  calloc.free(msg); // 释放内存
  calloc.free(wc); // 释放内存
  calloc.free(point); // 释放内存
}

String? message;

// 窗口过程函数
int windowProcedure(int hWnd, int msg, int wParam, int lParam) {

  switch (msg) {
    case WM_CREATE:
      final createStruct = Pointer.fromAddress(lParam).cast<CREATESTRUCT>();
      message = createStruct.ref.lpCreateParams.cast<Utf16>().toDartString();
    case WM_DESTROY:
      PostQuitMessage(0);
      return 0;
    case WM_TIMER:
      if (wParam == TIMER_ID) {
        // 定时器触发，关闭窗口
        DestroyWindow(hWnd);
      }
    case WM_PAINT:
      final ps = calloc<PAINTSTRUCT>();
      final hdc = BeginPaint(hWnd, ps);

      // 加载字体文件
      final fontPath = 'assets/font/MiSans-Regular.ttf'; // 假设字体文件名为 MiSans.ttf
      final fontCount = AddFontResourceEx(TEXT(fontPath), 0x10, nullptr);
      if (fontCount == 0) {
        throw Exception('字体加载失败');
      }

      // 分配并初始化 LOGFONT 结构
      final logFont = calloc<LOGFONT>();

      // 设置字体属性
      logFont.ref
        ..lfHeight = -24 // 字体高度（负数表示逻辑单位高度）
        ..lfWidth = 0    // 宽度（0 表示自动计算宽高比）
        ..lfEscapement = 0 // 文本倾斜角度（0.1度单位）
        ..lfOrientation = 0
        ..lfItalic = FALSE   // 是否斜体
        ..lfUnderline = FALSE
        ..lfStrikeOut = FALSE
        ..lfCharSet = FONT_CHARSET.DEFAULT_CHARSET; // 字符集
      logFont.ref.lfFaceName = 'MiSans'; // 设置字体名称
      // 创建字体
      final hFont = CreateFontIndirect(logFont);
      free(logFont); // 释放 LOGFONT 内存

      if (hFont == NULL) {
        throw Exception('字体创建失败');
      }

      // 选择字体
      SelectObject(hdc, hFont);

      print('message3: $message');

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
      return 0;
  }
  return DefWindowProc(hWnd, msg, wParam, lParam);
}


void main() {
  showToast('');
}