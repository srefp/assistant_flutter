import 'package:assistant/components/title_with_sub.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// 带icon、标题、副标题的tile
class IconCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  final Widget content;

  const IconCard({
    super.key,
    required this.icon,
    required this.title,
    this.subTitle = '',
    this.content = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    return Expander(
      leading: Icon(
        icon,
        size: 30,
      ),
      header: TitleWithSub(
        title: title,
        subTitle: subTitle,
      ),
      content: content,
    );
  }
}
