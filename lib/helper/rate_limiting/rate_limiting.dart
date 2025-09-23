import 'dart:async';
import 'dart:ui' show VoidCallback;

/// 头部防抖
/// 首次触发立即执行，进入冷却期，期间忽略所有触发。
class LeadingDebounce {
  Timer? _timer;
  final Duration duration;
  bool _isOnCooldown = false;

  LeadingDebounce({this.duration = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    if (!_isOnCooldown) {
      action(); // 立即执行
      _isOnCooldown = true;
      _timer = Timer(duration, () {
        _isOnCooldown = false;
      });
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// 尾部防抖
/// 每次触发都重置定时器，只在停止触发后延迟执行最后一次。
class TrailingDebounce {
  Timer? _timer;
  final Duration duration;

  TrailingDebounce({this.duration = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// 头部节流
/// 使用时间戳法，每个时间窗口开始时执行一次（立即执行）。
class LeadingThrottle {
  DateTime? _lastTime;
  final Duration duration;

  LeadingThrottle({this.duration = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    final now = DateTime.now();
    if (_lastTime == null || now.difference(_lastTime!) >= duration) {
      action();
      _lastTime = now;
    }
  }
}

/// 尾部节流
/// 使用定时器法，每个时间窗口结束时执行一次（延迟执行）。
class TrailingThrottle {
  Timer? _timer;
  final Duration duration;

  TrailingThrottle({this.duration = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    _timer ??= Timer(duration, () {
        action();
        _timer?.cancel();
        _timer = null;
      });
  }

  void dispose() {
    _timer?.cancel();
  }
}
