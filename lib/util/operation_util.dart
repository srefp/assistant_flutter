import 'dart:async';
import 'dart:ui';

/// 防抖
Function(dynamic) debounce(void Function(dynamic) fn, {int seconds = 1}) {
  Timer? debounce;
  return (dynamic value) {
    if (debounce?.isActive ?? false) {
      debounce?.cancel();
    }
    debounce = Timer(Duration(seconds: seconds), () {
      fn.call(value);
    });
  };
}

/// 节流
Function() throttle(Future Function() func) {
  bool enable = true;
  return () {
    if (enable) {
      enable = false;
      func().then((_) {
        enable = true;
      });
    }
  };
}
