import 'dart:async';

import 'package:assistant/components/button_with_icon.dart';
import 'package:assistant/components/icon_card.dart';
import 'package:assistant/components/title_with_sub.dart';
import 'package:assistant/util/asset_loader.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/win_text.dart';
import '../theme.dart';
import '../util/file_utils.dart';

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
        SizedBox(height: 16),
        IconCard(
          icon: Icons.play_arrow_rounded,
          title: '耕地机，启动！',
          subTitle: "启动后才能使用各项功能",
          content: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                flex: 1,
                child: TitleWithSub(
                    title: '路线文件夹',
                    subTitle:
                        '每次更新后会覆盖你写的路线，请千万记得备份！请按照文档写路线并将文件发送到QQ群660182560'),
              ),
              ButtonWithIcon(
                text: '打开路线目录',
                icon: FluentIcons.folder,
                onPressed: () {
                  openRelativeOrAbsolute(getAssets('routes'));
                },
              ),
            ],
          ),
        ),
        IconCard(
          icon: Icons.rocket_launch_rounded,
          title: '自动传送',
          subTitle: '依据路线自动传送',
          content: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                flex: 1,
                child: TitleWithSub(
                  title: '路线',
                  subTitle: '重新选择路线起始位置置零',
                ),
              ),
              ComboboxFormField(
                items: [],
                onChanged: (value) {},
              ),
            ],
          ),
        )
      ],
    );
  }
}
