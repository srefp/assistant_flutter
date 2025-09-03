import 'package:fluent_ui/fluent_ui.dart';

import '../title_with_sub.dart';

class ConfigRow extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget content;

  const ConfigRow({
    super.key,
    required this.title,
    this.subTitle = '',
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          flex: 1,
          child: TitleWithSub(
            title: title,
            subTitle: subTitle,
          ),
        ),
        content,
      ],
    );
  }
}
