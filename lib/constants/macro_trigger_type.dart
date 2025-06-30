import 'coded_enum.dart';

enum MacroTriggerType implements CodedEnum {
  down(1, '按下'),
  up(2, '抬起'),
  toggle(3, '开关'),
  doubleDown(4, '双击'),
  longDownCycle(5, '长按循环触发'),
  longDown(6, '长按1s触发'),
  ;

  @override
  final int code;

  @override
  final String resourceId;

  const MacroTriggerType(this.code, this.resourceId);
}
