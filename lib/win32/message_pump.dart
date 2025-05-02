import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'key_listen.dart';

void messagePump() async {
  // 必须运行非阻塞消息循环
  final msg = calloc<MSG>();
  await Future.doWhile(() async {
    await Future.delayed(const Duration(milliseconds: 2));
    while (
        PeekMessage(msg, NULL, 0, 0, PEEK_MESSAGE_REMOVE_TYPE.PM_REMOVE) != 0) {
      TranslateMessage(msg);
      DispatchMessage(msg);
    }
    return true;
  });
  free(msg);
}

int threadHandle = 0;

void createMessageThread() {
  threadHandle = CreateThread(
      nullptr,
      0,
      threadProc,
      nullptr,
      0,
      nullptr
  );
}

final threadProc = SetListenCallback((lpParam) {
  final msg = calloc<MSG>();
  while (GetMessage(msg, NULL, 0, 0) != 0) {
    TranslateMessage(msg);
    DispatchMessage(msg);
  }
  free(msg);
  return 0;
});
