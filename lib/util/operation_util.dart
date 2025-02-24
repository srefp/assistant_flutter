import 'dart:async';

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
Function(int) throttle(Future Function(int) func) {
  bool enable = true;
  return (int index) {
    if (enable) {
      enable = false;
      func(index).then((_) {
        enable = true;
      });
    }
  };
}
