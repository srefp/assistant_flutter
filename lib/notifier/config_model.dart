import 'package:assistant/components/win_text_box.dart';
import 'package:assistant/config/hotkey_config.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../app/windows_app.dart';
import '../components/string_config_row.dart';
import '../components/title_with_sub.dart';
import '../util/key_mouse_name.dart';
import '../util/search_utils.dart';

const global = 1;
const listen = 2;

/// 快捷键配置
final hotkeyConfigItems = [
  StringConfigItem(
    type: global,
    keyItemCallback: HotkeyConfig.to.getStartStopKeyItem,
    keyDownHandler: (hotKey) {
      WindowsApp.autoTpModel.startOrStop();
    },
    title: '启动/关闭耕地机',
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
  StringConfigItem(
    title: '全自动传送',
    valueKey: HotkeyConfig.keyTpNext,
    valueCallback: HotkeyConfig.to.getTpNext,
  ),
  StringConfigItem(
    title: '匀速冲刺',
    valueKey: HotkeyConfig.keyTimerDashKey,
    valueCallback: HotkeyConfig.to.getTimerDashKey,
  ),
  StringConfigItem(
    title: '一键吃药',
    valueKey: HotkeyConfig.keyEatFoodKey,
    valueCallback: HotkeyConfig.to.getEatFoodKey,
  ),
  StringConfigItem(
    title: '快捡',
    valueKey: HotkeyConfig.keyQuickPickKey,
    valueCallback: HotkeyConfig.to.getQuickPickKey,
  ),
  StringConfigItem(
    title: '开启/关闭快捡',
    valueKey: HotkeyConfig.keyToggleQuickPickKey,
    valueCallback: HotkeyConfig.to.getToggleQuickPickKey,
  ),
];

class HotkeyConfigRow extends StatefulWidget {
  final StringConfigItem item;
  final String lightText;

  const HotkeyConfigRow(
      {super.key, required this.item, required this.lightText});

  @override
  State<HotkeyConfigRow> createState() => _HotkeyConfigRowState();
}

class _HotkeyConfigRowState extends State<HotkeyConfigRow> {
  FocusNode focusNode = FocusNode();
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.item.valueCallback());
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TitleWithSub(
        title: widget.item.title,
        hasSubTitle: false,
        lightText: widget.lightText,
        rightWidget: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: SizedBox(
            height: 34,
            width: 200,
            child: Listener(
              onPointerDown: (event) {
                if (widget.item.type == global) {
                  return;
                }
                setState(() {
                  final text = mouseEventToNameMap[event.buttons];
                  if (text != null) {
                    HotkeyConfig.to.save(widget.item.valueKey, text);
                    controller.text = text;
                  }
                });
                return;
              },
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent) {
                    setState(() {
                      // 取消快捷键
                      updateKey(event);
                    });
                  }
                  return;
                },
                child: WinTextBox(
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  controller: controller,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateKey(KeyDownEvent event) async {
    // 取消快捷键
    if (widget.item.type == global) {
      var item = widget.item.keyItemCallback!();
      final list = hotKeyManager.registeredHotKeyList;
      for (var i = 0; i < list.length; i++) {
        var e = list[i];
        if (e.identifier == item.identifier) {
          await hotKeyManager.unregister(e);
        }
      }
    }

    final text = physicalKeyMap[event.physicalKey] ??
        event.physicalKey.keyLabel.toLowerCase();
    HotkeyConfig.to.save(widget.item.valueKey, text);
    controller.text = text;

    // 注册新快捷键
    if (widget.item.type == global) {
      await hotKeyManager.register(widget.item.keyItemCallback!(),
          keyDownHandler: widget.item.keyDownHandler);
    }
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
