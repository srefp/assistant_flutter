import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

void messagePump() async {
  // 必须运行非阻塞消息循环
  final msg = calloc<MSG>();
  await Future.doWhile(() async {
    await Future.delayed(const Duration(milliseconds: 1));
    while (
        PeekMessage(msg, NULL, 0, 0, PEEK_MESSAGE_REMOVE_TYPE.PM_REMOVE) != 0) {
      TranslateMessage(msg);
      DispatchMessage(msg);
    }
    return true;
  });
  free(msg);
}
