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

  /// 视频地址
  String? videoUrl;

  /// 备注
  String? remark;

  /// 作者
  String author;

  /// 创建时间
  int? createdOn;

  /// 更新时间
  int? updatedOn;

  TpRoute({
    this.id,
    required this.scriptName,
    required this.scriptType,
    required this.content,
    this.remark,
    this.author = '-1',
    this.ratio = '16:9',
    this.videoUrl,
    int? createdOn,
    int? updatedOn,
  }) {
    final cur = currentMillis();
    this.createdOn = createdOn ?? cur;
    this.updatedOn = updatedOn ?? cur;
  }

  factory TpRoute.fromJson(Map<String, dynamic> json) => TpRoute(
        id: json['id'] as int?,
        scriptName: json['scriptName'] as String,
        scriptType: json['scriptType'] as String,
        content: json['content'] as String,
        remark: json['remark'] as String?,
        author: json['author'] as String,
        ratio: json['ratio'] as String,
        videoUrl: json['videoUrl'] as String?,
        createdOn: json['createdOn'] as int?,
        updatedOn: json['updatedOn'] as int?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'scriptName': scriptName,
        'scriptType': scriptType,
        'content': content,
        'remark': remark,
        'author': author,
        'ratio': ratio,
        'videoUrl': videoUrl,
        'createdOn': createdOn,
        'updatedOn': updatedOn,
      };

  @override
  String toString() =>
      'Route{id: $id, name: $scriptName, content: $content, remark: $remark, author: $author, ratio: $ratio, videoUrl: $videoUrl, createdOn: $createdOn, updatedOn: $updatedOn}';
}
