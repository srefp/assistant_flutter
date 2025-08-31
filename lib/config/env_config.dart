import 'package:assistant/routes/routes.dart';

class Env {

  /// 显示工具菜单
  static bool showTools = false;

  /// 显示测试菜单
  static bool showTest = false;

  /// 显示日志菜单
  static bool showLog = false;

  /// 显示数据库
  static bool showDb = true;

  /// 初始路由
  static String initialRoute = Routes.autoTp;
}
