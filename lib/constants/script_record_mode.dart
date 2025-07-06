import 'coded_enum.dart';

enum ScriptRecordMode implements CodedEnum {
  autoTp(1, '自动传'),
  autoScript(2, '自动脚本'),
  ;

  @override
  final int code;

  @override
  final String resourceId;

  const ScriptRecordMode(this.code, this.resourceId);
}
