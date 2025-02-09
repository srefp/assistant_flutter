import 'dart:async';

import 'package:assistant/components/icon_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/win_text.dart';
import '../theme.dart';

bool finishedSettingTheme = false;

class AutoTpPage extends StatefulWidget {
  const AutoTpPage({super.key});

  @override
  State<AutoTpPage> createState() => _AutoTpPageState();
}

class _AutoTpPageState extends State<AutoTpPage> {
  int tryTimes = 0;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();

    if (!finishedSettingTheme) {
      Timer.periodic(Duration(milliseconds: 5), (timer) {
        if (context.mounted) {
          appTheme.setEffect(appTheme.windowEffect, context);
        }

        if (tryTimes >= 10) {
          timer.cancel();
          finishedSettingTheme = true;
        }

        tryTimes++;
      });
    }

    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        WinText(
          '自动传送',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        IconCard(
          icon: Icons.play_arrow_rounded,
          title: '耕地机，启动！',
          subTitle: "启动后才能使用各项功能",
        )
      ],
    );
  }
}
