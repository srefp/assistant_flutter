import 'package:assistant/components/win_text.dart';
import 'package:assistant/screens/auto_tp_page.dart';
import 'package:fluent_ui/fluent_ui.dart';

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
