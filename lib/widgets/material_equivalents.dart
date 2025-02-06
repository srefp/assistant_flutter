import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;

import '../components/win_text.dart';

class MaterialEquivalents extends StatefulWidget {
  const MaterialEquivalents({super.key});

  @override
  State<MaterialEquivalents> createState() => _MaterialEquivalentsState();
}

class _MaterialEquivalentsState extends State<MaterialEquivalents> {
  bool comboboxChecked = true;
  bool radioChecked = true;
  bool switchChecked = true;

  final List<String> comboboxItems = [
    'Item 1',
    'Item 2',
  ];
  String? comboboxItem;
  String dropdownItem = 'Item 1';
  final popupKey = GlobalKey<m.PopupMenuButtonState>();

  double sliderValue = Random().nextDouble() * 100;

  final fieldController = TextEditingController();
  DateTime time = DateTime.now();

  @override
  void dispose() {
    fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<List<Widget>> children = [
      [
        const WinText('Button'),
        Button(
          child: const WinText('Content'),
          onPressed: () {},
        ),
        m.OutlinedButton(
          child: const WinText('Content'),
          onPressed: () {},
        ),
      ],
      [
        const WinText('HyperlinkButton'),
        HyperlinkButton(
          child: const WinText('Content'),
          onPressed: () {},
        ),
        m.TextButton(
          child: const WinText('Content'),
          onPressed: () {},
        ),
      ],
      [
        const WinText('FilledButton'),
        FilledButton(
          child: const WinText('Content'),
          onPressed: () {},
        ),
        m.ElevatedButton(
          child: const WinText('Content'),
          onPressed: () {},
        ),
      ],
      [
        const WinText('IconButton'),
        IconButton(
          icon: const Icon(FluentIcons.graph_symbol),
          onPressed: () {},
        ),
        m.IconButton(
          icon: const Icon(FluentIcons.graph_symbol),
          onPressed: () {},
        ),
      ],
      [
        const WinText('Checkbox'),
        Checkbox(
          checked: comboboxChecked,
          onChanged: (v) =>
              setState(() => comboboxChecked = v ?? comboboxChecked),
        ),
        m.Checkbox(
          value: comboboxChecked,
          onChanged: (v) =>
              setState(() => comboboxChecked = v ?? comboboxChecked),
        ),
      ],
      [
        const WinText('RadioButton'),
        RadioButton(
          checked: radioChecked,
          onChanged: (v) => setState(() => radioChecked = v),
        ),
        m.Radio<bool>(
          groupValue: true,
          value: radioChecked,
          onChanged: (v) => setState(() => radioChecked = !radioChecked),
        ),
      ],
      [
        const WinText('ToggleSwitch'),
        ToggleSwitch(
          checked: switchChecked,
          onChanged: (v) => setState(() => switchChecked = v),
        ),
        m.Switch(
          value: switchChecked,
          onChanged: (v) => setState(() => switchChecked = v),
        ),
      ],
      [
        const WinText('Slider'),
        Slider(
          value: sliderValue,
          max: 100,
          onChanged: (v) => setState(() => sliderValue = v),
        ),
        m.Slider(
          value: sliderValue,
          max: 100,
          onChanged: (v) => setState(() => sliderValue = v),
        ),
      ],
      [
        const WinText('ProgressRing'),
        const RepaintBoundary(child: ProgressRing()),
        const RepaintBoundary(child: m.CircularProgressIndicator()),
      ],
      [
        const WinText('ProgressBar'),
        const RepaintBoundary(child: ProgressBar()),
        const RepaintBoundary(child: m.LinearProgressIndicator()),
      ],
      [
        const WinText('ComboBox'),
        ComboBox<String>(
          items: comboboxItems
              .map((e) => ComboBoxItem(value: e, child: WinText(e)))
              .toList(),
          value: comboboxItem,
          onChanged: (value) => setState(() => comboboxItem = value),
        ),
        m.DropdownButton<String>(
          items: comboboxItems
              .map((e) => m.DropdownMenuItem(value: e, child: WinText(e)))
              .toList(),
          value: comboboxItem,
          onChanged: (value) => setState(() => comboboxItem = value),
        ),
      ],
      [
        const WinText('DropDownButton'),
        DropDownButton(
          items: comboboxItems
              .map(
                (e) => MenuFlyoutItem(
                  text: WinText(e),
                  onPressed: () => setState(() => dropdownItem = e),
                ),
              )
              .toList(),
          title: WinText(dropdownItem),
        ),
        m.PopupMenuButton<String>(
          key: popupKey,
          itemBuilder: (context) {
            return comboboxItems
                .map(
                  (e) => m.PopupMenuItem(
                    value: e,
                    child: WinText(e),
                  ),
                )
                .toList();
          },
          onSelected: (e) => setState(() => dropdownItem = e),
          initialValue: dropdownItem,
          position: m.PopupMenuPosition.under,
          child: m.TextButton(
            child: WinText(dropdownItem),
            onPressed: () {
              popupKey.currentState?.showButtonMenu();
            },
          ),
        ),
      ],
      [
        const WinText('TextBox'),
        TextBox(controller: fieldController),
        m.TextField(controller: fieldController),
      ],
      [
        const WinText('TimePicker'),
        TimePicker(
          selected: time,
          onChanged: (value) => setState(() => time),
        ),
        m.TextButton(
          child: const WinText('Show Picker'),
          onPressed: () async {
            final newTime = await m.showTimePicker(
              context: context,
              initialTime: m.TimeOfDay(
                hour: time.hour,
                minute: time.minute,
              ),
            );
            if (newTime != null) {
              time = DateTime(
                time.year,
                time.month,
                time.day,
                newTime.hour,
                newTime.minute,
                time.second,
              );
            }
          },
        ),
      ],
      [
        const WinText('DatePicker'),
        DatePicker(
          selected: time,
          onChanged: (value) => setState(() => time),
        ),
        m.TextButton(
          child: const WinText('Show Picker'),
          onPressed: () async {
            final newTime = await m.showDatePicker(
              context: context,
              initialDate: time,
              firstDate: DateTime(time.year - 100),
              lastDate: DateTime(time.year + 100),
            );
            if (newTime != null) {
              setState(() => time = newTime);
            }
          },
        ),
      ],
      [
        const WinText('ListTile'),
        ListTile(
          leading: const Icon(FluentIcons.graph_symbol),
          title: const WinText('Content'),
          onPressed: () {},
        ),
        m.ListTile(
          leading: const Icon(FluentIcons.graph_symbol),
          title: const WinText('Content'),
          onTap: () {},
        ),
      ],
      [
        const WinText('Tooltip'),
        const Tooltip(
          message: 'A fluent-styled tooltip',
          child: WinText('Hover'),
        ),
        const m.Tooltip(
          message: 'A material-styled tooltip',
          child: WinText('Hover'),
        ),
      ],
    ];

    Widget buildColumn(int index) {
      return Column(
        children: children
            .map(
              (children) => Container(
                constraints: const BoxConstraints(minHeight: 50.0),
                alignment: AlignmentDirectional.center,
                child: children[index],
              ),
            )
            .toList(),
      );
    }

    return m.Material(
      type: m.MaterialType.transparency,
      child: Row(children: [
        Expanded(child: buildColumn(0)),
        const m.VerticalDivider(),
        Expanded(child: buildColumn(1)),
        const m.VerticalDivider(),
        Expanded(child: buildColumn(2)),
      ]),
    );
  }
}
