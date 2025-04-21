import 'package:assistant/components/win_text.dart';
import 'package:assistant/extensions/string_extension.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Material;

import '../util/search_utils.dart';
import 'highlight_text.dart';

class HighlightComboBox extends StatefulWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String>? onChange;

  const HighlightComboBox({
    super.key,
    required this.value,
    required this.items,
    this.onChange,
  });

  @override
  State<HighlightComboBox> createState() => _HighlightComboBoxState();
}

class _HighlightComboBoxState extends State<HighlightComboBox> {
  late final TextEditingController _controller;
  List<String> _filteredItems = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  String _hintText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_onFocusChange);
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (!_focusNode.hasFocus) {
        _controller.text = _hintText.isEmpty ? _controller.text : _hintText;
        setState(() {
          _hintText = '';
        });
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  /// 根据多个字符串进行搜索
  bool searchTextList(String input, List<String?> contentList) {
    final inputTextLower = input.toLowerCase();
    for (var searchArea in contentList) {
      if (searchArea == null) {
        continue;
      }
      final textLower = searchArea.toLowerCase();
      final pinyinShort = textLower.pinyinShort;
      final pinyinAndPosMap = textLower.pinyinAndPosMap;
      if (multiMatch(
            textLower: textLower,
            pinyinShort: pinyinShort,
            pinyinAndPosMap: pinyinAndPosMap,
            searchValue: inputTextLower,
            start: 0,
          )[0] !=
          -1) {
        return true;
      }
    }
    return false;
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
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 10,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return ListTile(
                  title: HighlightText(
                    item,
                    lightText: _controller.text,
                  ),
                  onPressed: () {
                    setState(() {
                      _hintText = item;
                      _controller.text = item;
                    });
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                    if (widget.onChange != null) {
                      widget.onChange!(item);
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: TextBox(
          padding: EdgeInsetsDirectional.fromSTEB(10, 5, 6, 6),
          controller: _controller,
          style: TextStyle(
            fontSize: 16,
            fontFamily: fontFamily,
          ),
          onTap: () {
            setState(() {
              _hintText = _controller.text;
            });
            _controller.text = '';
            filterBySearchText(context);
            if (_overlayEntry == null) {
              _overlayEntry = _createOverlayEntry();
              Overlay.of(context).insert(_overlayEntry!);
            }
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
                if (widget.onChange != null) {
                  widget.onChange!(_filteredItems[0]);
                }
              });
            }
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
