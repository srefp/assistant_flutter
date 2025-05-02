import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'key_listen.dart';

class MessagePump {
  static Isolate? _isolate;
  static SendPort? _sendPort;
  static final Completer<void> _initialized = Completer<void>();

  // 初始化Isolate消息泵
  static Future<void> initialize() async {
    if (_isolate != null) return;

    final receivePort = ReceivePort();
    receivePort.listen(_handleIsolateMessage);

    _isolate = await Isolate.spawn(
      _isolateEntry,
      receivePort.sendPort,
      debugName: 'Win32MessagePump',
    );

    return _initialized.future;
  }

  // Isolate入口函数
  static void _isolateEntry(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message == 'start') {
        _runMessageLoop();
      }
    });

    // 初始化Native回调处理
    _initNativeCallbacks();
  }

  // 运行消息循环
  static void _runMessageLoop() {
    final msg = calloc<MSG>();
    while (GetMessage(msg, NULL, 0, 0) != 0) {
      TranslateMessage(msg);
      DispatchMessage(msg);
    }
    free(msg);
  }

  // 处理跨Isolate通信
  static void _handleIsolateMessage(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _initialized.complete();
    }
  }

  // 初始化Native回调（关键修改）
  static void _initNativeCallbacks() {
    SetListenCallback((lpParam) {
      final msg = calloc<MSG>();
      while (GetMessage(msg, NULL, 0, 0) != 0) {
        TranslateMessage(msg);
        DispatchMessage(msg);
      }
      free(msg);
      return 0;
    });
  }

  // 修改原有消息泵启动方式
  static void start() async {
    await MessagePump.initialize();
    _sendPort?.send('start');
  }
}
