import 'package:assistant/constants/macro_trigger_type.dart';
import 'package:assistant/constants/profile_status.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../util/date_utils.dart';

class Macro {
  /// 主键
  int? id;

  /// 名称
  String name;

  /// 备注
  String? comment;

  /// 脚本
  String script;

  /// 触发键
  String triggerKey;

  /// 触发类型
  MacroTriggerType triggerType;

  /// 指定进程名
  String? processName;

  /// 状态
  ProfileStatus status;

  /// 创建时间
  int? createdOn;

  /// 更新时间
  int? updatedOn;

  Macro({
    this.id,
    required this.name,
    this.comment,
    required this.script,
    required this.triggerKey,
    required this.triggerType,
    this.status = ProfileStatus.active,
    this.processName,
    int? createdOn,
    int? updatedOn,
  }) {
    final cur = currentMillis();
    this.createdOn = createdOn ?? cur;
    this.updatedOn = updatedOn ?? cur;
  }

  factory Macro.fromJson(Map<String, dynamic> json) {
    return Macro(
      id: json['id'],
      name: json['name'],
      comment: json['comment'],
      script: json['script'],
      triggerKey: json['trigger_key'],
      triggerType: MacroTriggerType.values[json['trigger_type']],
      processName: json['process_name'],
      status: ProfileStatus.values[json['status']],
      createdOn: json['created_on'],
      updatedOn: json['updated_on'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'comment': comment,
      'script': script,
      'trigger_key': triggerKey,
      'trigger_type': triggerType.index,
      'process_name': processName,
      'status': status.index,
      'created_on': createdOn,
      'updated_on': updatedOn,
    };
  }

  @override
  String toString() {
    return 'Macro{id: $id, name: $name, comment: $comment, script: $script, triggerKey: $triggerKey, triggerType: $triggerType, processName: $processName, status: $status}';
  }
}
