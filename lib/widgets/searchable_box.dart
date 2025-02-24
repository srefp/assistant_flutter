import 'package:fluent_ui/fluent_ui.dart';

class SearchableBox extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const SearchableBox({
    super.key,
    required this.items,
    this.onChanged,
  });

  @override
  State<SearchableBox> createState() => _SearchableBoxState();
}

class _SearchableBoxState extends State<SearchableBox> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _focusNode.addListener(_toggleOverlay);
  }

  void _toggleOverlay() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    title: _highlightText(item, _controller.text),
                    onPressed: () {
                      _controller.text = item;
                      widget.onChanged?.call(item);
                      _hideOverlay();
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
      ),
    );
  }

  Widget _highlightText(String text, String query) {
    if (query.isEmpty) return Text(text);
    
    final matches = text.toLowerCase().split(query.toLowerCase());
    final List<TextSpan> spans = [];
    int currentIndex = 0;
    
    for (var match in matches) {
      if (match.isNotEmpty) {
        spans.add(TextSpan(text: text.substring(currentIndex, currentIndex + match.length)));
        currentIndex += match.length;
      }
      if (currentIndex < text.length) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, currentIndex + query.length),
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold
          )
        ));
        currentIndex += query.length;
      }
    }
    
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextBox(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: '搜索路线...',
        onChanged: (value) {
          setState(() {
            _filteredItems = widget.items
                .where((item) => item.toLowerCase().contains(value.toLowerCase()))
                .toList();
          });
          _overlayEntry?.markNeedsBuild();
        },
        onTap: _showOverlay,
      ),
    );
  }
}
