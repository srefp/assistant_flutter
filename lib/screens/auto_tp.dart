import 'package:assistant/components/icon_card.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

import '../components/win_text.dart';
import '../widgets/page.dart';

class AutoTpPage extends StatefulWidget {
  const AutoTpPage({super.key});

  @override
  State<AutoTpPage> createState() => _AutoTpPageState();
}

class _AutoTpPageState extends State<AutoTpPage> with PageMixin {
  bool selected = true;
  String? comboBoxValue;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const WinText('自动传送'),
      ),
      children: [
        IconCard(
          icon: Icons.play_arrow_rounded,
          title: '耕地机，启动！',
          subTitle: "启动后才能使用各项功能",
        )
      ],
    );
  }
}
