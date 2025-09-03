import '../../../constant/profile_status.dart';
import '../../../helper/date_utils.dart';

class Efficient {
  /// 主键
  int? id;

  /// 唯一ID
  String uniqueId;

  /// 名称
  String name;

  /// 备注
  String? comment;

  /// 脚本
  String script;

  /// 状态
  ProfileStatus status;

  /// 创建时间
  int? createdOn;

  /// 更新时间
  int? updatedOn;

  /// 构造函数
  Efficient({
    this.id,
    required this.uniqueId,
    required this.name,
    this.comment,
    required this.script,
    this.status = ProfileStatus.active,
    int? createdOn,
    int? updatedOn,
  }) {
    final cur = currentMillis();
    this.createdOn = createdOn ?? cur;
    this.updatedOn = updatedOn ?? cur;
  }

  factory Efficient.fromJson(Map<String, dynamic> json) {
    return Efficient(
      id: json['id'],
      uniqueId: json['uniqueId'],
      name: json['name'],
      comment: json['comment'],
      script: json['script'],
      status: ProfileStatus.values[json['status']],
      createdOn: json['createdOn'],
      updatedOn: json['updatedOn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uniqueId': uniqueId,
      'name': name,
      'comment': comment,
      'script': script,
      'status': status.index,
      'createdOn': createdOn,
      'updatedOn': updatedOn,
    };
  }

  @override
  String toString() {
    return 'Efficient{id: $id, uniqueId: $uniqueId name: $name, comment: $comment, script: $script, status: $status}';
  }
}
