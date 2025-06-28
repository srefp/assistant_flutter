import 'coded_enum.dart';

enum MacroTriggerType implements CodedEnum {
  down(1, '按下'),
  up(2, '抬起'),
  upStop(3, '抬终'),
  toggle(4, '开关'),
  longDown(5, '长按'),
  doubleDown(6, '双击'),
  ;

  @override
  final int code;

  @override
  final String resourceId;

  const MacroTriggerType(this.code, this.resourceId);
}
