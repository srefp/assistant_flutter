import 'package:assistant/config/hotkey_config.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../app/windows_app.dart';
import '../components/string_config_row.dart';
import '../components/title_with_sub.dart';
import '../components/win_text.dart';
import '../key_mouse/mouse_button.dart';
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
    title: '上一个点位（不传送）',
    valueKey: HotkeyConfig.keyToPrev,
    valueCallback: HotkeyConfig.to.getToPrev,
  ),
  StringConfigItem(
    title: '下一个点位（不传送）',
    valueKey: HotkeyConfig.keyToNext,
    valueCallback: HotkeyConfig.to.getToNext,
  ),
  StringConfigItem(
    title: '全自动传送',
    valueKey: HotkeyConfig.keyTpNext,
    valueCallback: HotkeyConfig.to.getTpNext,
  ),
  StringConfigItem(
    title: 'qm全自动传送',
    valueKey: HotkeyConfig.keyQmTpNext,
    valueCallback: HotkeyConfig.to.getQmTpNext,
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
            width: 200,
            child: HotkeyBox(
              value: widget.item.valueCallback(),
              global: widget.item.type == global,
              hotKey: widget.item.keyItemCallback?.call(),
              onValueChanged: (value) =>
                  HotkeyConfig.to.save(widget.item.valueKey, value),
              onGlobalValueChanged: (value) => hotKeyManager.register(
                  widget.item.keyItemCallback!(),
                  keyDownHandler: widget.item.keyDownHandler),
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

class HotkeyBox extends StatefulWidget {
  final HotKey? hotKey;
  final String? value;
  final bool global;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<String>? onGlobalValueChanged;

  const HotkeyBox({
    super.key,
    required this.value,
    required this.onValueChanged,
    this.global = false,
    this.hotKey,
    this.onGlobalValueChanged,
  });

  @override
  State<HotkeyBox> createState() => _HotkeyBoxState();
}

class _HotkeyBoxState extends State<HotkeyBox> {
  late final FocusNode focusNode;
  late String? value;

  @override
  void initState() {
    focusNode = FocusNode();
    value = widget.value;
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void updateKey(KeyDownEvent event) async {
    // 取消快捷键
    if (widget.global) {
      var item = widget.hotKey;
      final list = hotKeyManager.registeredHotKeyList;
      for (var i = 0; i < list.length; i++) {
        var e = list[i];
        if (e.identifier == item?.identifier) {
          await hotKeyManager.unregister(e);
        }
      }
    }

    var text = logicalKeyMap[event.logicalKey] ??
        event.logicalKey.keyLabel.toLowerCase();

    if ([
      'ctrlleft',
      'ctrlright',
      'shiftleft',
      'shiftright',
      'altleft',
      'altright'
    ].contains(text)) {
      return;
    }

    final modifiers = <String>[];
    // 识别组合键
    if (HardwareKeyboard.instance.isControlPressed) {
      modifiers.add('ctrl');
    }

    if (HardwareKeyboard.instance.isShiftPressed) {
      modifiers.add('shift');
    }

    if (HardwareKeyboard.instance.isAltPressed) {
      modifiers.add('alt');
    }

    text = modifiers.join(' + ') + (modifiers.isNotEmpty ? ' + ' : '') + text;
    widget.onValueChanged(text);
    value = text;

    // 注册新快捷键
    if (widget.global) {
      widget.onGlobalValueChanged!(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      width: 200,
      child: Listener(
        onPointerSignal: (event) {
          if (!focusNode.hasFocus) {
            return;
          }

          if (event is PointerScrollEvent) {
            // 垂直滚动量（正值向下，负值向上）
            final verticalScroll = event.scrollDelta.dy;

            String text;
            // 可在此添加业务逻辑（如调整配置值）
            if (verticalScroll > 0) {
              text = wheelDown;
            } else {
              text = wheelUp;
            }

            widget.onValueChanged(text);
            setState(() {
              value = text;
            });
          }
        },
        onPointerDown: (event) {
          if (!focusNode.hasFocus) {
            return;
          }

          if (widget.global) {
            return;
          }
          setState(() {
            final text = mouseEventToNameMap[event.buttons];
            if (text != null) {
              widget.onValueChanged(text);
              value = text;
            }
          });
          return;
        },
        child: Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              setState(() {
                // 取消快捷键
                updateKey(event);
              });
            }
            return KeyEventResult.handled;
          },
          child: Button(
            focusNode: focusNode,
            onPressed: () {
              if (focusNode.hasFocus) {
                focusNode.unfocus();
              } else {
                focusNode.requestFocus();
              }
            },
            child: WinText(value ?? ''),
          ),
        ),
      ),
    );
  }
}
