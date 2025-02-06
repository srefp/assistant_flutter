import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/link.dart';

import '../components/win_text.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with PageMixin {
  bool selected = true;
  String? comboboxValue;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const WinText('Fluent UI for Flutter Showcase App'),
        commandBar: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Link(
            uri: Uri.parse('https://github.com/bdlukaa/fluent_ui'),
            builder: (context, open) => Semantics(
              link: true,
              child: Tooltip(
                message: 'Source code',
                child: IconButton(
                  icon: const Icon(FluentIcons.open_source, size: 24.0),
                  onPressed: open,
                ),
              ),
            ),
          ),
        ]),
      ),
      children: [
        Card(
          child:
              Wrap(alignment: WrapAlignment.center, spacing: 10.0, children: [
            InfoLabel(
              label: 'Inputs',
              child: ToggleSwitch(
                checked: selected,
                onChanged: (v) => setState(() => selected = v),
              ),
            ),
            SizedBox(
              width: 100,
              child: InfoLabel(
                label: 'Forms',
                child: ComboBox<String>(
                  value: comboboxValue,
                  items: ['Item 1', 'Item 2']
                      .map((e) => ComboBoxItem(
                            value: e,
                            child: WinText(e),
                          ))
                      .toList(),
                  isExpanded: true,
                  onChanged: (v) => setState(() => comboboxValue = v),
                ),
              ),
            ),
            RepaintBoundary(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 4.0),
                child: InfoLabel(
                  label: 'Progress',
                  child: const SizedBox(
                    height: 30,
                    width: 30,
                    child: ProgressRing(),
                  ),
                ),
              ),
            ),
            InfoLabel(
              label: 'Surfaces & Materials',
              child: SizedBox(
                height: 40,
                width: 120,
                child: Stack(children: [
                  Container(
                    width: 120,
                    height: 50,
                    color: theme.accentColor.lightest,
                  ),
                  const Positioned.fill(child: Acrylic(luminosityAlpha: 0.5)),
                ]),
              ),
            ),
            InfoLabel(
              label: 'Icons',
              child: const Icon(FluentIcons.graph_symbol, size: 30.0),
            ),
            InfoLabel(
              label: 'Colors',
              child: SizedBox(
                width: 40,
                height: 30,
                child: Wrap(
                  children: <Color>[
                    ...Colors.accentColors,
                    Colors.successPrimaryColor,
                    Colors.warningPrimaryColor,
                    Colors.errorPrimaryColor,
                    Colors.grey,
                  ].map((color) {
                    return Container(
                      height: 10,
                      width: 10,
                      color: color,
                    );
                  }).toList(),
                ),
              ),
            ),
            InfoLabel(
              label: 'Typography',
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    colors: [
                      Colors.white,
                      ...Colors.accentColors,
                    ],
                  ).createShader(rect);
                },
                blendMode: BlendMode.srcATop,
                child: const WinText(
                  'ABCDEFGH',
                  style: TextStyle(fontSize: 24, shadows: [
                    Shadow(offset: Offset(1, 1)),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 22.0),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => const Changelog(),
            );
          },
          icon: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WinText(
                'What\'s new on 4.0.0',
                style: theme.typography.body
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              WinText('June 21, 2022', style: theme.typography.caption),
              WinText(
                'A native look-and-feel out of the box',
                style: theme.typography.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22.0),
        Row(children: [
          WinText('SPONSORS', style: theme.typography.bodyStrong),
          const SizedBox(width: 4.0),
          const Icon(FluentIcons.heart_fill, size: 16.0),
        ]),
        const SizedBox(height: 4.0),
        WinText('CONTRIBUTORS', style: theme.typography.bodyStrong),
        subtitle(content: const WinText('Equivalents with the material library')),
        const MaterialEquivalents(),
      ],
    );
  }
}

class SponsorButton extends StatelessWidget {
  const SponsorButton({
    super.key,
    required this.imageUrl,
    required this.username,
  });

  final String imageUrl;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
          ),
          shape: BoxShape.circle,
        ),
      ),
      WinText(username),
    ]);
  }
}
