import 'package:win32/win32.dart';

const k = 65535;

List<int> getVirtualPos(List<int> pos) {
  // 获取屏幕的宽度
  final int screenWidth = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CXSCREEN);
  // 获取屏幕的高度
  final int screenHeight = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CYSCREEN);

  return [
    (pos[0] * k / screenWidth).floor(),
    (pos[1] * k / screenHeight).floor(),
  ];
}
