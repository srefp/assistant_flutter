import '../util/date_utils.dart';

/// 自动传送路线
class TpRoute {
  /// ID
  int? id;

  /// 路线名称
  String scriptName;

  /// 路线类型
  String scriptType;

  /// 路线内容
  String content;

  /// 屏幕比例
  String ratio;

  /// 备注
  String? remark;

  /// 作者
  String author;

  /// 创建时间
  int? createdAt;

  /// 更新时间
  int? updatedAt;

  TpRoute({
    this.id,
    required this.scriptName,
    required this.scriptType,
    required this.content,
    this.remark,
    this.author = '-1',
    this.ratio = '16:9',
    int? createdAt,
    int? updatedAt,
  }) {
    final cur = currentMillis();
    this.createdAt = createdAt ?? cur;
    this.updatedAt = updatedAt ?? cur;
  }

  factory TpRoute.fromJson(Map<String, dynamic> json) => TpRoute(
        id: json['id'] as int?,
        scriptName: json['scriptName'] as String,
        scriptType: json['scriptType'] as String,
        content: json['content'] as String,
        remark: json['remark'] as String?,
        author: json['author'] as String,
        ratio: json['ratio'] as String,
        createdAt: json['created_at'] as int?,
        updatedAt: json['updated_at'] as int?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'scriptName': scriptName,
        'scriptType': scriptType,
        'content': content,
        'remark': remark,
        'author': author,
        'ratio': ratio,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  @override
  String toString() =>
      'Route{id: $id, name: $scriptName, content: $content, remark: $remark, author: $author, ratio: $ratio, createdAt: $createdAt, updatedAt: $updatedAt}';
}
