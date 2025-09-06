import '../../app/config/auto_tp_config.dart';
import '../../app/config/process_pos/process_pos_config.dart';

/// 键鼠操作
class Operation {
  final String func;
  List<int> coords;
  String template;
  int prevDelay;

  static Operation confirm = Operation(
      func: "click",
      coords: ProcessPosConfig.to.getConfirmPosIntList(),
      template:
          "click(${ProcessPosConfig.to.getConfirmPos()[0]}, ${ProcessPosConfig.to.getConfirmPos()[1]}, %s);",
      prevDelay: AutoTpConfig.to.getClickRecordDelay());

  static Operation openMap = Operation(
      func: "map",
      coords: [],
      template: "map(%s);",
      prevDelay: AutoTpConfig.to.getMapRecordDelay());

  static Operation openBook = Operation(
    func: "book",
    template: "book(%s);",
    prevDelay: AutoTpConfig.to.getBookRecordDelay(),
  );

  static Operation mDown = Operation(
    func: "mDown",
    coords: [],
    template: "mDown(%s);",
    prevDelay: AutoTpConfig.to.getClickRecordDelay(),
  );

  Operation({
    required this.func,
    this.coords = const [0, 0],
    required this.template,
    this.prevDelay = 0,
  });

  @override
  String toString() {
    return template.replaceFirst('%s', prevDelay.toString());
  }
}
