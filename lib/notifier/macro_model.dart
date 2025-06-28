import 'package:assistant/model/macro.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:re_editor/re_editor.dart';

import '../app/windows_app.dart';
import '../constants/macro_trigger_type.dart';
import '../constants/profile_status.dart';
import '../routes/routes.dart';

class MacroModel extends ChangeNotifier {
  final macroSearchController = TextEditingController();

  List<Macro> macroList = [
    Macro(
      id: 1,
      name: '半自动',
      script: 'click([100, 200], 60);',
      triggerKey: 'a',
      triggerType: MacroTriggerType.down,
      status: ProfileStatus.active,
    ),
  ];

  Macro? editedMacro;

  String searchText = '';

  final nameTextController = TextEditingController();
  final commentTextController = TextEditingController();

  final CodeLineEditingController scriptController =
      CodeLineEditingController();

  void saveMicro() async {
    rootNavigatorKey.currentContext!.pop();
  }

  void onScriptChanged(String script) {}

  void changeTriggerKey(key) {
    editedMacro?.triggerKey = key;
    notifyListeners();
  }

  void searchMacroConfigItems(String value) {}

  void addMacro() {}

  void toggleMacroStatus(Macro item) {
    item.status = item.status == ProfileStatus.active
        ? ProfileStatus.disabled
        : ProfileStatus.active;
  }

  void changeTriggerType(String value) {
    editedMacro?.triggerType = {
      MacroTriggerType.down.resourceId: MacroTriggerType.down,
      MacroTriggerType.up.resourceId: MacroTriggerType.up,
      MacroTriggerType.upStop.resourceId: MacroTriggerType.upStop,
      MacroTriggerType.toggle.resourceId: MacroTriggerType.toggle,
      MacroTriggerType.longDown.resourceId: MacroTriggerType.longDown,
      MacroTriggerType.doubleDown.resourceId: MacroTriggerType.doubleDown,
    }[value]!;

    notifyListeners();
  }

  void selectMacro(Macro value) {
    editedMacro = value;
    nameTextController.text = value.name;
    commentTextController.text = value.comment ?? '';
    scriptController.text = value.script;
    notifyListeners();
  }
}
