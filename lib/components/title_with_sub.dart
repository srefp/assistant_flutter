import 'package:assistant/components/win_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'highlight_text.dart';

class TitleWithSub extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget rightWidget;
  final String lightText;

  const TitleWithSub({
    super.key,
    required this.title,
    this.subTitle = '',
    this.lightText = '',
    this.rightWidget = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              HighlightText(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: fontFamily),
                lightText: lightText,
              ),
              HighlightText(
                subTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w200,
                  color: Color(0xFFAAAAAA),
                  fontFamily: fontFamily,
                ),
                lightText: lightText,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        rightWidget,
      ],
    );
  }
}
