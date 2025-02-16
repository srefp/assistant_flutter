import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../screens/virtual_screen.dart';
import '../win32/toast.dart';

/// 获取鼠标位置
List<int> getMousePosition() {
  final point = calloc<POINT>();
  GetCursorPos(point);
  final x = point.ref.x;
  final y = point.ref.y;
  return [x, y];
}

/// 显示鼠标坐标
void showCoordinate() {
  List<int> point = getMousePosition();
  List<int> virtualPos = getVirtualPos(point);
  showToast('已复制坐标: ${virtualPos[0]}, ${virtualPos[1]}');
}
