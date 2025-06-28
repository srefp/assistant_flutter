import 'coded_enum.dart';

enum ProfileStatus implements CodedEnum {
  unknown(0, '未知'),
  active(1, '启用'),
  disabled(2, '禁用'),
  deleted(3, '已删除'),
  ;

  @override
  final int code;

  @override
  final String resourceId;

  const ProfileStatus(this.code, this.resourceId);
}
