import 'package:assistant/components/win_text.dart';
import 'package:assistant/extensions/string_extension.dart';
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
  final FocusNode _focusNode = FocusNode();
  String _hintText = '';

  void _initStateValues() {
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_onFocusChange);
    _filteredItems = widget.items;
  }

  @override
  void initState() {
    super.initState();
    _initStateValues();
  }

  void _updateWidgetValues() {
    if (widget.value != null) {
      setState(() {
        _controller.text = widget.value!;
        _hintText = '';
      });
    }
  }

  @override
  void didUpdateWidget(covariant HighlightComboBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateWidgetValues();
    }
  }

  void _disposeFocusNode() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
  }

  @override
  void dispose() {
    _disposeFocusNode();
    super.dispose();
  }

  void _onFocusChange() {
    Future.delayed(const Duration(milliseconds: 100), () {
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

    const double itemHeight = 44;
    const double maxHeight = 400;
    final double totalHeight = _filteredItems.length * itemHeight;
    final double actualHeight =
        totalHeight < maxHeight ? totalHeight : maxHeight;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: Material(
            color: const Color(0xFF282828),
            elevation: 10,
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
                              setState(() {
                                _hintText = item;
                                _controller.text = item;
                              });
                              _overlayEntry?.remove();
                              _overlayEntry = null;
                              if (widget.onChanged != null) {
                                widget.onChanged!(item);
                              }
                            },
                          ))
                      .toList()),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTextBoxTap(BuildContext context) {
    setState(() {
      _hintText = _controller.text;
    });
    _controller.text = '';
    _filterBySearchText(context);
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _handleTextBoxChange(BuildContext context) {
    setState(() {
      _filterBySearchText(context);
    });
  }

  void _handleTextBoxSubmit() {
    if (_filteredItems.isNotEmpty) {
      setState(() {
        _hintText = '';
        _controller.text = _filteredItems[0];
        if (widget.onChanged != null) {
          widget.onChanged!(_filteredItems[0]);
        }
      });
    }
  }

  void _filterBySearchText(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 10,
      child: SizedBox(
        height: 34,
        child: Focus(
          focusNode: _focusNode,
          child: CompositedTransformTarget(
            link: _layerLink,
            child: TextBox(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 6, 6),
              controller: _controller,
              style: TextStyle(
                fontSize: 16,
                fontFamily: fontFamily, // 注意：需要确保这个变量已定义
              ),
              onTap: () => _handleTextBoxTap(context),
              onChanged: (value) => _handleTextBoxChange(context),
              onSubmitted: (value) => _handleTextBoxSubmit(),
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
      ),
    );
  }
}
