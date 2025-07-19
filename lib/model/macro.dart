import 'package:assistant/constants/enum_util.dart';
import 'package:assistant/constants/macro_trigger_type.dart';
import 'package:assistant/constants/profile_status.dart';

import '../util/date_utils.dart';

class Macro {
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

  /// 任务
  Future? macroFuture;

  /// 是否循环执行（开关宏）
  bool loopRunning = false;

  /// 是否正在执行（开关可中断）
  bool running = false;

  /// 是否可以停止（开关宏）
  bool canStop = false;

  /// 是否可以开始（开关宏）
  bool canStart = true;

  /// 是否可以运行（双击宏）
  bool canRunFor2 = false;

  /// 是否可以运行（长按宏）
  bool canRunForLong = false;

  /// 长按开始时间
  int longPressStartTime = 0;

  Macro({
    this.id,
    required this.uniqueId,
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
      uniqueId: json['uniqueId'],
      name: json['name'],
      comment: json['comment'],
      script: json['script'],
      triggerKey: json['triggerKey'],
      triggerType: EnumUtil.fromCode(json['triggerType'], MacroTriggerType.values),
      processName: json['processName'],
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
      'triggerKey': triggerKey,
      'triggerType': triggerType.code,
      'processName': processName,
      'status': status.index,
      'createdOn': createdOn,
      'updatedOn': updatedOn,
    };
  }

  @override
  String toString() {
    return 'Macro{id: $id, uniqueId: $uniqueId name: $name, comment: $comment, script: $script, triggerKey: $triggerKey, triggerType: $triggerType, processName: $processName, status: $status}';
  }
}
