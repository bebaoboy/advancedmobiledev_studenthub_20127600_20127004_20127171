// ignore_for_file: unused_element

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ChipsInputSuggestions<T> = Future<List<T>> Function(String query);
typedef ChipSelected<T> = void Function(T data, bool selected);
typedef ChipsBuilder<T> = Widget Function(
    BuildContext context, ChipsInputState<T> state, T data);

class ChipsInput<T> extends StatefulWidget {
  const ChipsInput({
    super.key,
    this.decoration = const InputDecoration(),
    required this.chipBuilder,
    required this.suggestionBuilder,
    required this.findSuggestions,
    required this.onChanged,
    required this.onChipTapped,
    required this.initialChips,
    this.maxInputHeight = 70,
    this.totalHeight = 500,
    this.emptyInputHeight = 70,
    this.nonEmptyInputHeight = 92,
  });

  final InputDecoration decoration;
  final ChipsInputSuggestions<T> findSuggestions;
  final ValueChanged<List<T>> onChanged;
  final ValueChanged<T> onChipTapped;
  final ChipsBuilder<T> chipBuilder;
  final ChipsBuilder<T> suggestionBuilder;
  final List<T> initialChips;
  final double maxInputHeight;
  final double emptyInputHeight;
  final double nonEmptyInputHeight;
  final double totalHeight;

  @override
  ChipsInputState<T> createState() => ChipsInputState<T>();
}

class ChipsInputState<T> extends State<ChipsInput<T>>
    implements TextInputClient {
  static const kObjectReplacementChar = 0xFFFC;

  late Set<T> _chips;
  List<T> _suggestions = List.empty(growable: true);
  int _searchId = 0;

  final FocusNode _focusNode = FocusNode();
  TextEditingValue _value = const TextEditingValue();
  TextInputConnection? _connection;
  final ScrollController _scrollController = ScrollController();

  String get text => String.fromCharCodes(
        _value.text.codeUnits.where((ch) => ch != kObjectReplacementChar),
      );

  bool get _hasInputConnection => _connection != null && _connection!.attached;

  void requestKeyboard() {
    if (_focusNode.hasFocus) {
      _openInputConnection();
      _connection!.show();
    } else {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void selectSuggestion(T data) {
    print(data);
    setState(() {
      _chips.add(data);
      _updateTextInputState();
      _suggestions.remove(data);
      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent,
      //   duration: Duration(milliseconds: 10),
      //   curve: Curves.ease,
      // );
    });
    widget.onChanged(_chips.toList(growable: false));
  }

  void deleteChip(T data) {
    setState(() {
      _chips.remove(data);
      _updateTextInputState();
    });
    widget.onChanged(_chips.toList(growable: false));
  }

  @override
  void initState() {
    _chips = Set<T>.from(widget.initialChips);
    _openInputConnection();
    //print(_chips);
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _openInputConnection();
    } else {
      // //print("out");
      //_closeInputConnectionIfNeeded();
      _suggestions = [];
    }
    if (mounted) {
      setState(() {
      // rebuild so that _TextCursor is hidden.
    });
    }
  }

  @override
  void dispose() {
    // _focusNode.dispose();
    _closeInputConnectionIfNeeded();
    super.dispose();
  }

  void _openInputConnection() {
    if (!_hasInputConnection) {
      _connection = TextInput.attach(this, const TextInputConfiguration());
      _connection!.setEditingState(_value);
    }
    //_connection!.show();
    _onSearchChanged("");
  }

  void _closeInputConnectionIfNeeded() {
    if (_hasInputConnection) {
      //_connection!.close();
    }
  }

  @override
  void connectionClosed() {
    //_closeInputConnectionIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    var chipsChildren = _chips
        .map<Widget>(
          (data) => widget.chipBuilder(context, this, data),
        )
        .toList();

    final theme = Theme.of(context);

    chipsChildren.add(
      SizedBox(
        height: 32.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(
                height: 1.5,
              ),
            ),
            _TextCaret(
              resumed: _focusNode.hasFocus,
            ),
          ],
        ),
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _focusNode.hasFocus
          ? widget.totalHeight
          : _chips.isEmpty
              ? widget.emptyInputHeight
              : widget.nonEmptyInputHeight,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: requestKeyboard,
              child: InputDecorator(
                decoration: widget.decoration,
                isFocused: _focusNode.hasFocus,
                isEmpty: _value.text.isEmpty,
                child: Container(
                  constraints: BoxConstraints(maxHeight: widget.maxInputHeight),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    reverse: true,
                    child: Wrap(
                      spacing: 2.0,
                      runSpacing: 2.0,
                      children: chipsChildren,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (BuildContext context, int index) {
                  return widget.suggestionBuilder(
                      context, this, _suggestions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    final oldCount = _countReplacements(_value);
    final newCount = _countReplacements(value);
    setState(() {
      if (newCount < oldCount) {
        _chips = Set.from(_chips.take(newCount));
      }
      _value = value;
    });
    _onSearchChanged(text);
  }

  int _countReplacements(TextEditingValue value) {
    return value.text.codeUnits
        .where((ch) => ch == kObjectReplacementChar)
        .length;
  }

  @override
  void performAction(TextInputAction action) {
    _focusNode.unfocus();
  }

  void _updateTextInputState() {
    final text =
        String.fromCharCodes(_chips.map((_) => kObjectReplacementChar));
    _value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange(start: 0, end: text.length),
    );
    _connection!.setEditingState(_value);
  }

  void _onSearchChanged(String value) async {
    final localId = ++_searchId;
    await widget.findSuggestions(value).then((value) {
      if (_searchId == localId && mounted) {
        setState(() {
          _suggestions = value
              .where((profile) => !_chips.contains(profile))
              .toList(growable: true);
        });
      }
    });
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TextCaret extends StatefulWidget {
  const _TextCaret(
      {this.resumed = false,
      this.duration = const Duration(milliseconds: 500)});

  final Duration duration;
  final bool resumed;

  @override
  _TextCursorState createState() => _TextCursorState();
}

class _TextCursorState extends State<_TextCaret>
    with SingleTickerProviderStateMixin {
  bool _displayed = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.duration, _onTimer);
  }

  void _onTimer(Timer timer) {
    setState(() => _displayed = !_displayed);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Opacity(
        opacity: _displayed && widget.resumed ? 1.0 : 0.0,
        child: Container(
          width: 2.0,
          color: theme.primaryColor,
        ),
      ),
    );
  }
}
