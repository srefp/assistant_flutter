import 'package:assistant/components/win_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TitleWithSub extends StatelessWidget {
  final String title;
  final String subTitle;

  const TitleWithSub({
    super.key,
    required this.title,
    this.subTitle = ''
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        WinText(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
        WinText(subTitle,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w200)),
        const SizedBox(height: 10),
      ],
    );
  }
}
