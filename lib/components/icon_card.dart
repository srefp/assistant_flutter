import 'package:assistant/components/win_text.dart';
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
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          WinText(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          WinText(subTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w200)),
          const SizedBox(height: 10),
        ],
      ),
      content: content,
    );
  }
}
