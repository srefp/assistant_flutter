import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:win32/win32.dart';

class FindUtil {
  static Future<bool> findColor(List<int> coords, String color) async {
    if (coords.length == 2) {
      coords = [coords[0], coords[1], coords[0], coords[1]];
    }

    // 解析区域坐标
    final p1 = KeyMouseUtil.physicalPos([coords[0], coords[1]]);
    final p2 = KeyMouseUtil.physicalPos([coords[2], coords[3]]);
    final area = [p1[0], p1[1], p2[0], p2[1]];

    // 解析颜色值（支持 #RRGGBB 或 RGB 数值字符串）
    final targetColor = _parseColor(color);
    if (targetColor == -1) return false;

    // 获取屏幕设备上下文
    final hdcScreen = GetDC(0);
    if (hdcScreen == 0) throw Exception("无法获取屏幕设备上下文");

    try {
      // 遍历区域内所有像素
      for (int x = area[0]; x <= area[2]; x++) {
        for (int y = area[1]; y <= area[3]; y++) {
          // 获取当前像素颜色（格式：0xBBGGRR）
          final pixelColor = GetPixel(hdcScreen, x, y);
          // 转换为 0xRRGGBB 格式与目标颜色比较
          if (_bgrToRgb(pixelColor) == targetColor) {
            return true; // 找到匹配颜色
          }
        }
      }
      return false; // 未找到
    } finally {
      ReleaseDC(0, hdcScreen); // 释放设备上下文
    }
  }

  static Future<bool> findPic(List<int> area, String picKey) async {
    return false;
  }

  /// 解析颜色字符串为 0xRRGGBB 数值
  static int _parseColor(String color) {
    if (color.startsWith('#')) {
      return int.parse(color.substring(1), radix: 16);
    } else {
      return int.tryParse(color) ?? -1;
    }
  }

  /// 将 Windows 的 BGR 颜色（0xBBGGRR）转换为 RGB（0xRRGGBB）
  static int _bgrToRgb(int bgr) {
    return ((bgr & 0xFF) << 16) | (bgr & 0xFF00) | ((bgr & 0xFF0000) >> 16);
  }
}
