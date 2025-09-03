import 'package:assistant/component/text/win_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'box/custom_sliver_box.dart';

class PageTitle extends StatelessWidget {
  final String title;

  const PageTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return CustomSliverBox(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: WinText(
          title,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
