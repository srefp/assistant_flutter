import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:window_manager/window_manager.dart';

import '../../main.dart';
import '../text/win_text.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return DragToMoveArea(
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              SizedBox(width: 14),
              SvgPicture.asset(
                'assets/image/logo.svg',
                height: 18,
              ),
              SizedBox(width: 8),
              const WinText(
                appTitle,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WinText('耕地机'),
        ],
      );
    }
  }
}
