import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

import '../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/keyboard.dart';
import '../win32/toast.dart';
import 'data_converter.dart';

const tp = "tp";
const tip = "tip";
const wait = "wait";
const move = "move";
const moveR = "moveR";
const moveR3D = "moveR3D";
const drag = "drag";
const mDown = "mDown";
const mUp = "mUp";
const click = "click";
const kDown = "kDown";
const kUp = "kUp";
const press = "press";
const cp = "cp";
const wheel = "wheel";
const openMap = "openMap";

const keys = [
  tp,
  tip,
  wait,
  move,
  moveR,
  moveR3D,
  drag,
  mDown,
  mUp,
  click,
  kDown,
  kUp,
  press,
  cp,
  wheel,
  openMap
];

final JavascriptRuntime jsRuntime  = getJavascriptRuntime();

late String jsFunction;

loadJsFunction() async {
  jsFunction = await rootBundle.loadString('assets/js/func.js');
}

void registerJsFunc() {
  jsRuntime.onMessage('log', (params) {
    WindowsApp.logModel.info(params['info']);
  });
  jsRuntime.onMessage('click', (params) async {
    print('params: ${params}');
    await KeyMouseUtil.clickAtPoint(
        convertDynamicListToIntList(params['coords']), params['delay']);
  });
  jsRuntime.onMessage('press', (params) async {
    print('params: ${params}');
    await api.press(key: params['key']);
    await Future.delayed(Duration(milliseconds: params['delay']));
  });
  jsRuntime.onMessage('wait', (param) async {
    await Future.delayed(Duration(milliseconds: param));
  });
  jsRuntime.onMessage('tip', (params) async {
    if (params['duration'] == null) {
      params['duration'] = 3000;
    }
    showToast(params['message'], duration: params['duration']);
  });
}

/// 运行js代码
Future<void> runScript(String code) async {
  // 将code中的异步函数添加await
  for (var key in keys) {
    code = code.replaceAll('$key(', 'await $key(');
  }

  JsEvalResult result = await jsRuntime.evaluateAsync('''
    $jsFunction
    (async function() {
    $code
    })();
    ''');
  jsRuntime.executePendingJob();
  await jsRuntime.handlePromise(result);
}