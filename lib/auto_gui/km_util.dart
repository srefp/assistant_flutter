import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// 获取鼠标位置
List<int> getMousePosition() {
  final point = calloc<POINT>();
  GetCursorPos(point);
  final x = point.ref.x;
  final y = point.ref.y;
  return [x, y];
}
