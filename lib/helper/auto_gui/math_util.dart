class MathUtil {
  /// 平滑插值，这是一个三阶贝塞尔曲线，y=3x平方 - 2x三次方
  ///
  /// [start] 起始点数组
  /// [end] 结束点数组
  /// [t] 插值因子
  /// 返回插值后的数组
  static List<int> smoothStep(List<int> start, List<int> end, double t) {
    t = clamp(t);
    t = smooth(t);

    return [
      (start[0] + (end[0] - start[0]) * t).toInt(),
      (start[1] + (end[1] - start[1]) * t).toInt()
    ];
  }

  /// 平滑插值，这是一个三阶贝塞尔曲线，y=3x平方 - 2x三次方
  ///
  /// [distance] 距离数组
  /// [t] 插值因子
  /// [prevDistance] 上一次的距离数组
  /// 返回插值后的数组
  static List<int> smoothStepWithPrev(List<int> distance, double t, List<int> prevDistance) {
    t = clamp(t);
    t = smooth(t);

    if (prevDistance[0] == 0 && prevDistance[1] == 0) {
      return [
        (distance[0] * t).toInt(),
        (distance[1] * t).toInt()
      ];
    }

    return [
      (distance[0] * t - prevDistance[0]).toInt(),
      (distance[1] * t - prevDistance[1]).toInt()
    ];
  }

  /// 线性插值
  ///
  /// [start] 起始点数组
  /// [end] 结束点数组
  /// [t] 插值因子
  /// 返回插值后的数组
  static List<int> lerp(List<int> start, List<int> end, double t) {
    t = clamp(t);

    return [
      (start[0] + (end[0] - start[0]) * t).toInt(),
      (start[1] + (end[1] - start[1]) * t).toInt()
    ];
  }

  static double smooth(double v) {
    return v * v * (3 - 2 * v);
  }

  static double clamp(double value) {
    if (value < 0) {
      return 0;
    } else if (value > 1) {
      return 1;
    }
    return value;
  }
}
