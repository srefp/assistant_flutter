import 'package:assistant/config/hotkey_config.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../components/coords_config_row.dart';
import '../components/title_with_sub.dart';
import '../util/search_utils.dart';

/// 快捷键配置
final hotkeyConfigItems = [
  StringConfigItem(
    title: '开图',
    valueKey: HotkeyConfig.keyStartStopKey,
    valueCallback: HotkeyConfig.to.getStartStopKey,
  ),
  StringConfigItem(
    title: '显示并复制当前鼠标坐标',
    valueKey: HotkeyConfig.keyShowCoordsKey,
    valueCallback: HotkeyConfig.to.getShowCoordsKey,
  ),
  StringConfigItem(
    title: '半自动传送',
    valueKey: HotkeyConfig.keyHalfTp,
    valueCallback: HotkeyConfig.to.getHalfTp,
  ),
];

class HotkeyConfigRow extends StatelessWidget {
  final StringConfigItem item;
  final String lightText;

  const HotkeyConfigRow(
      {super.key, required this.item, required this.lightText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TitleWithSub(
        title: item.title,
        hasSubTitle: false,
        lightText: lightText,
        rightWidget: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: SizedBox(
            height: 34,
            child: HotKeyRecorder(
              initalHotKey: HotKey(key: PhysicalKeyboardKey.f7),
              onHotKeyRecorded: (HotKey value) {
                print('value: ${value.debugName}');
                // HotkeyConfig.to.save(item.valueKey, value.toString());
              },
              // child: TextBox(
              //   textAlign: TextAlign.center,
              //   controller: TextEditingController(text: item.valueCallback()),
              //   onChanged: (value) => HotkeyConfig.to.save(item.valueKey, value),
              // ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConfigModel extends ChangeNotifier {
  var lightText = '';
  var displayedConfigItems = hotkeyConfigItems;
  final searchController = TextEditingController();

  void searchConfigItems(String searchValue) {
    lightText = searchValue;
    if (searchValue.isEmpty) {
      displayedConfigItems = hotkeyConfigItems;
      notifyListeners();
      return;
    }
    final filteredList = hotkeyConfigItems
        .where(
            (item) => searchTextList(searchValue, [item.title, item.subTitle]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedConfigItems = filteredList;
    }

    notifyListeners();
  }

  void updateConfig() {
    notifyListeners();
  }
}
