import 'package:assistant/components/title_with_sub.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// 带icon、标题、副标题的tile
class IconCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  final Widget content;
  final Widget rightWidget;
  final bool subTitleSelectable;
  final bool expandEnabled;

  const IconCard({
    super.key,
    required this.icon,
    required this.title,
    this.subTitle = '',
    this.content = const SizedBox(),
    this.rightWidget = const SizedBox(),
    this.subTitleSelectable = false,
    this.expandEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _buildExpander(),
    );
  }

  Widget _buildExpander() {
    if (expandEnabled) {
      return Expander(
        leading: Icon(
          icon,
          size: 30,
        ),
        header: TitleWithSub(
          title: title,
          subTitle: subTitle,
          subTitleSelectable: subTitleSelectable,
          rightWidget: rightWidget,
        ),
        content: content,
      );
    }
    return Card(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TitleWithSub(
              title: title,
              subTitle: subTitle,
              subTitleSelectable: subTitleSelectable,
              rightWidget: rightWidget,
            ),
          ),
        ],
      ),
    );
  }
}
