/// 自动传送路线
class Route {

  /// 路线名称
  final String name;

  /// 路线内容
  final String content;

  /// 屏幕比例
  final String ratio;

  Route({required this.name, required this.content, this.ratio = '16:9'});
}
