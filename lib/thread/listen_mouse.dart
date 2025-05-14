// 在文件顶部添加以下导入
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../app/windows_app.dart';
import '../constants/script_type.dart';
import '../manager/screen_manager.dart';
import '../util/hotkey_util.dart';
import '../win32/mouse_listen.dart';

late final Isolate isolate;
final receivePort = ReceivePort();

void startKeyMouseListen() async {
  receivePort.listen((message) {
    if (message is Map) {
      final mouseStruct =
          Pointer<MSLLHOOKSTRUCT>.fromAddress(message['lParam']);

      // 业务逻辑处理（与原逻辑一致）
      if (WindowsApp.autoTpModel.isRunning &&
          ScreenManager.instance.isGameActive()) {
        listenMouse(mouseStruct, message['wParam'], message['lParam']);
      }
      if (WindowsApp.recordModel.isRecording) {
        WindowsApp.scriptEditorModel.selectedScriptType == autoTp
            ? recordRoute(mouseStruct, message['wParam'], message['lParam'])
            : recordScript(mouseStruct, message['wParam'], message['lParam']);
      }
    }
  });

  isolate = await Isolate.spawn((sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    int mouseHook = 0;
    final hookProcPointer = setCallback((nCode, wParam, lParam) {
      final result = CallNextHookEx(mouseHook, nCode, wParam, lParam);
      Future.microtask(() {
        if (nCode == HC_ACTION) {
          // 仅传递必要数据到隔离
          sendPort.send({
            'type': 'mouse',
            'wParam': wParam,
            'lParam': lParam,
            'time': DateTime.now().millisecondsSinceEpoch
          });
        }
      });
      return result;
    });

    // 开启键鼠监听
    final hModule = GetModuleHandle(nullptr);

    mouseHook = SetWindowsHookEx(
      WINDOWS_HOOK_ID.WH_MOUSE_LL, // 改为鼠标钩子类型
      hookProcPointer,
      hModule,
      0,
    );

    final msg = calloc<MSG>();
    while (GetMessage(msg, NULL, 0, 0) != 0) {
      TranslateMessage(msg);
      DispatchMessage(msg);
    }
    free(msg);

    print('移除了钩子');

    UnhookWindowsHookEx(mouseHook);
  }, receivePort.sendPort);
}
