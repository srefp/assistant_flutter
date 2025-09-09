import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:easy_isolate/easy_isolate.dart';
import 'package:ffi/ffi.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:win32/win32.dart';

import '../win32/toast.dart';

final toastWorker = Worker();

void startToastListen() {
  toastWorker.sendMessage(0);
}

void stopToastListen() {
  toastWorker.sendMessage(1);
}

Future<void> runToastIsolate() async {
  if (!Platform.isWindows) return;

  await toastWorker.init((_, __) {}, _toastIsolateHandler);
}

void _toastIsolateHandler(
    dynamic message, SendPort sendPort, SendErrorFunction onSendError) {
  if (message == 0) {
    startMessagePump();
    return;
  } else if (message == 1) {
    PostQuitMessage(0);
    debugPrint('消息泵监听结束');
    return;
  }

  showToastMethod(message['message'], duration: message['duration']);
  return;
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
