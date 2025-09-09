import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:easy_isolate/easy_isolate.dart';
import 'package:ffi/ffi.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:win32/win32.dart';

import '../../app/windows_app.dart';
import '../auto_gui/system_control.dart';
import '../screen/screen_manager.dart';
import '../win32/toast.dart';
import 'message_type.dart';

late SendPort toastSendPort;
final toastWorker = Worker();
int winEventHook = 0;
const startMessagePumpMessage = 0;
const stopMessagePumpMessage = 1;
int instanceHWnd = 0;

void startToastListen() {
  toastWorker.sendMessage(startMessagePumpMessage);
}

void stopToastListen() {
  toastWorker.sendMessage(stopMessagePumpMessage);
}

Future<void> runToastIsolate() async {
  if (!Platform.isWindows) return;

  await toastWorker.init(_toastMainHandler, _toastIsolateHandler);
}

void _toastMainHandler(dynamic message, SendPort isolateSendPort) {
  if (message == 'windowMove') {
    // 触发窗口移动后，重新计算窗口矩形
    SystemControl.refreshRect();
  } else if (message == 'windowClose') {
    ScreenManager.instance.task = null;
    // 触发窗口关闭后的处理
    WindowsApp.autoTpModel.stop();
  }
}

void _toastIsolateHandler(
    dynamic message, SendPort mainSendPort, SendErrorFunction onSendError) {
  toastSendPort = mainSendPort;
  if (message == startMessagePumpMessage) {
    startMessagePump();
    return;
  } else if (message == stopMessagePumpMessage) {
    stopListen();
    PostQuitMessage(0);
    debugPrint('消息泵监听结束');
    return;
  }

  final type = message['type'];
  if (type == toast) {
    showToastMethod(message['msg'], duration: message['duration']);
  } else if (type == startListenWindowLifeCycle) {
    instanceHWnd = message['hWnd'];
    listenWindowClose(message['pid']);
  } else if (type == stopListenWindowLifeCycle) {
    stopListen();
  }

  return;
}

void listenWindowClose(int pid) {
  winEventHook = setWinEventHook(
      eventSystemMoveSizeEnd,
      eventObjectDestroy,
      // 窗口销毁事件
      0,
      Pointer.fromFunction(_winEventProc),
      pid,
      0,
      winEventOutOfContext | winEventSkipOwnProcess);
}

// 停止监听
void stopListen() {
  if (winEventHook != 0) {
    unhookWinEvent(winEventHook);
    winEventHook = 0;
  }
}

// 添加窗口事件监听
void startListenWindow(int hWnd, int pid) {
  toastWorker.sendMessage({
    'type': startListenWindowLifeCycle,
    'hWnd': hWnd,
    'pid': pid,
  });
}

// 移除窗口事件监听
void stopListenWindow() {
  toastWorker.sendMessage({'type': stopListenWindowLifeCycle});
}

// 窗口事件回调处理
void _winEventProc(int hWinEventHook, int event, int hWnd, int idObject,
    int idChild, int dwEventThread, int dwmsEventTime) {
  // 仅处理目标窗口的事件
  if (hWnd != instanceHWnd) return;

  switch (event) {
    case eventSystemMoveSizeEnd:
      toastSendPort.send('windowMove');
      break;
    case eventObjectDestroy:
      toastSendPort.send('windowClose');

      break;
  }
}

void startMessagePump() async {
  // 必须运行非阻塞消息循环
  final msg = calloc<MSG>();
  await Future.doWhile(() async {
    await Future.delayed(const Duration(milliseconds: 10));
    while (
        PeekMessage(msg, NULL, 0, 0, PEEK_MESSAGE_REMOVE_TYPE.PM_REMOVE) != 0) {
      TranslateMessage(msg);
      DispatchMessage(msg);
    }
    return true;
  });
  free(msg);
}
