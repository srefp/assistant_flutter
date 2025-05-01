import 'package:flutter_js/flutter_js.dart';

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