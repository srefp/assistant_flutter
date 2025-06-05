import 'package:assistant/components/win_text_box.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Material, Theme;

import '../util/search_utils.dart';
import 'highlight_text.dart';

class HighlightComboBox extends StatefulWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String>? onChanged;

  const HighlightComboBox({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  State<HighlightComboBox> createState() => _HighlightComboBoxState();
}

class _HighlightComboBoxState extends State<HighlightComboBox> {
  late final TextEditingController _controller;
  List<String> _filteredItems = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  String _hintText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        _controller.text = widget.value ?? '';
        _hintText = '';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // 确保 OverlayEntry 被移除
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _closeDropdown() {
    _controller.text = _hintText.isEmpty ? _controller.text : _hintText;
    setState(() {
      _hintText = '';
    });
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    const double itemHeight = 44;
    const double maxHeight = 400;
    final double totalHeight = _filteredItems.length * itemHeight;
    final double actualHeight =
        totalHeight < maxHeight ? totalHeight : maxHeight;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              child: Container(
                color: Color.fromARGB(100, 50, 50, 50),
              ),
              onTap: () {
                _closeDropdown();
              },
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height),
              child: Material(
                color: Color(0xFF282828),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: actualHeight,
                  ),
                  child: ListView(
                    children: _filteredItems
                        .map((item) => ListTile(
                              title: HighlightText(
                                item,
                                lightText: _controller.text,
                              ),
                              onPressed: () {
                                if (item == widget.value) {
                                  _closeDropdown();
                                  return;
                                }
                                setState(() {
                                  _hintText = '';
                                });
                                _controller.text = item;
                                _overlayEntry?.remove();
                                _overlayEntry = null;
                                if (widget.onChanged != null) {
                                  widget.onChanged!(item);
                                }
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
        height: 34,
        child: CompositedTransformTarget(
          link: _layerLink,
          child: WinTextBox(
            controller: _controller,
            style: TextStyle(
              fontSize: 16,
            ),
            onTap: () {
              if (_hintText.isNotEmpty) {
                return;
              }
              setState(() {
                _hintText = _controller.text;
              });
              _controller.text = '';
              filterBySearchText(context);
            },
            onChanged: (value) {
              setState(() {
                filterBySearchText(context);
              });
            },
            onSubmitted: (value) {
              if (_filteredItems.isNotEmpty) {
                setState(() {
                  _hintText = '';
                  _controller.text = _filteredItems[0];
                  if (widget.onChanged != null) {
                    widget.onChanged!(_filteredItems[0]);
                  }
                });
              }
              _closeDropdown();
            },
            suffix: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                FluentIcons.chevron_down,
                size: 8,
              ),
            ),
            placeholder: _hintText,
          ),
        ),
      ),
    );
  }

  void filterBySearchText(BuildContext context) {
    if (_controller.text.isEmpty) {
      _filteredItems = widget.items;
    } else {
      _filteredItems = widget.items
          .where((item) => searchTextList(_controller.text, [item]))
          .toList();
    }

    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }
}
