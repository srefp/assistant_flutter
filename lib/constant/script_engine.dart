import 'coded_enum.dart';

enum ScriptEngine implements CodedEnum {
  zero(0, '极速引擎'),
  js(1, 'js引擎'),
  ;

  @override
  final int code;

  @override
  final String resourceId;

  const ScriptEngine(this.code, this.resourceId);
}
