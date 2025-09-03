import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../component/box/custom_sliver_box.dart';
import '../../../component/text/win_text.dart';
import 'doc_model.dart';

class DocPage extends StatelessWidget {
  const DocPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DocModel>(builder: (context, model, child) {
      return CustomScrollView(
        slivers: [
          CustomSliverBox(
            child: Markdown(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              styleSheet: MarkdownStyleSheet(
                h1: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily),
                h2: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily),
                h3: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily),
                h4: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily),
                h5: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily),
                h6: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily),
                p: TextStyle(fontSize: 16, fontFamily: fontFamily),
                code: TextStyle(fontSize: 14, fontFamily: 'Consolas'),
                blockquote: TextStyle(fontSize: 16, fontFamily: fontFamily),
                listBullet: TextStyle(fontSize: 16, fontFamily: fontFamily),
                tableBody: TextStyle(fontSize: 16, fontFamily: fontFamily),
              ),
              selectable: true,
              data: model.doc,
              onTapLink: (text, href, title) {
                if (href != null) {
                  _launchURL(href);
                }
              },
            ),
          ),
        ],
      );
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }
}
