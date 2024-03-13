library animation_search_bar;

import 'dart:async';

import 'package:boilerplate/utils/classes.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderScope, StateProvider, Consumer;
import 'package:flutter_typeahead/flutter_typeahead.dart';

final searchingProvider = StateProvider.autoDispose((ref) => false);

// ignore: must_be_immutable
class AnimationSearchBar extends StatefulWidget {
  AnimationSearchBar(
      {Key? key,
      this.searchBarWidth,
      this.searchBarHeight,
      this.previousScreen,
      this.backIconColor,
      this.closeIconColor,
      this.searchIconColor,
      this.centerTitle,
      this.centerTitleStyle,
      this.searchFieldHeight,
      this.searchFieldDecoration,
      this.cursorColor,
      this.textStyle,
      this.hintText,
      this.hintStyle,
      required this.onChanged,
      required this.searchTextEditingController,
      this.horizontalPadding,
      this.verticalPadding,
      this.isBackButtonVisible,
      this.backIcon,
      this.duration,
      required this.suggestionItemBuilder,
      required this.onSelected,
      required this.onSuggestionCallback})
      : super(key: key);

  ///
  final double? searchBarWidth;
  final double? searchBarHeight;
  final double? searchFieldHeight;
  final double? horizontalPadding;
  final double? verticalPadding;
  final Widget? previousScreen;
  final Color? backIconColor;
  final Color? closeIconColor;
  final Color? searchIconColor;
  final Color? cursorColor;
  final String? centerTitle;
  final String? hintText;
  final bool? isBackButtonVisible;
  final IconData? backIcon;
  final TextStyle? centerTitleStyle;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Decoration? searchFieldDecoration;
  late Duration? duration;
  final TextEditingController searchTextEditingController;
  final Function(String) onChanged;
  final Widget Function(BuildContext, Project) suggestionItemBuilder;
  Function(Project)? onSelected;
  FutureOr<List<Project>?> Function(String) onSuggestionCallback;

  @override
  State<AnimationSearchBar> createState() => _AnimationSearchBarState();
}

class _AnimationSearchBarState extends State<AnimationSearchBar> {
  @override
  Widget build(BuildContext context) {
    final _duration = widget.duration ?? const Duration(milliseconds: 500);
    final _searchFieldHeight = widget.searchFieldHeight ?? 40;
    final _hPadding = widget.horizontalPadding != null ? widget.horizontalPadding! * 2 : 0;
    final _searchBarWidth =
        widget.searchBarWidth ?? MediaQuery.of(context).size.width - _hPadding;
    final _isBackButtonVisible = widget.isBackButtonVisible ?? true;
    return ProviderScope(
      child: Consumer(builder: (context, ref, __) {
        final _isSearching = ref.watch(searchingProvider);
        final _searchNotifier = ref.watch(searchingProvider.notifier);
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: widget.horizontalPadding ?? 0,
              vertical: widget.verticalPadding ?? 0),
          child: SizedBox(
            width: _searchBarWidth,
            height: widget.searchBarHeight ?? 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                /// back Button
                _isBackButtonVisible
                    ? AnimatedOpacity(
                        opacity: _isSearching ? 0 : 1,
                        duration: _duration,
                        child: AnimatedContainer(
                            curve: Curves.easeInOutCirc,
                            width: _isSearching ? 0 : 35,
                            height: _isSearching ? 0 : 35,
                            duration: _duration,
                            child: FittedBox(
                                child: KBackButton(
                                    icon: widget.backIcon,
                                    iconColor: widget.backIconColor,
                                    previousScreen: widget.previousScreen))))
                    : AnimatedContainer(
                        curve: Curves.easeInOutCirc,
                        width: _isSearching ? 0 : 35,
                        height: _isSearching ? 0 : 35,
                        duration: _duration),

                /// text
                AnimatedOpacity(
                  opacity: _isSearching ? 0 : 1,
                  duration: _duration,
                  child: AnimatedContainer(
                    curve: Curves.easeInOutCirc,
                    width: _isSearching ? 0 : _searchBarWidth - 100,
                    duration: _duration,
                    alignment: Alignment.center,
                    child: FittedBox(
                      child: Text(
                        widget.centerTitle ?? 'Title',
                        textAlign: TextAlign.center,
                        style: widget.centerTitleStyle ??
                            const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 20,
                            ),
                      ),
                    ),
                  ),
                ),

                /// close search
                AnimatedOpacity(
                  opacity: _isSearching ? 1 : 0,
                  duration: _duration,
                  child: AnimatedContainer(
                    curve: Curves.easeInOutCirc,
                    width: _isSearching ? 35 : 0,
                    height: _isSearching ? 35 : 0,
                    duration: _duration,
                    child: FittedBox(
                      child: KCustomButton(
                        widget: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Icon(Icons.close,
                                color: widget.closeIconColor ??
                                    Colors.black.withOpacity(.7))),
                        onPressed: () {
                          _searchNotifier.state = false;
                          widget.searchTextEditingController.clear();
                        },
                      ),
                    ),
                  ),
                ),

                /// input panel
                AnimatedOpacity(
                  opacity: _isSearching ? 1 : 0,
                  duration: _duration,
                  child: AnimatedContainer(
                    curve: Curves.easeInOutCirc,
                    duration: _duration,
                    width: _isSearching
                        ? _searchBarWidth - 55 - (widget.horizontalPadding ?? 0 * 2)
                        : 0,
                    height: _isSearching ? _searchFieldHeight : 20,
                    margin: EdgeInsets.only(
                        left: _isSearching ? 5 : 0,
                        right: _isSearching ? 10 : 0),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: widget.searchFieldDecoration ??
                        BoxDecoration(
                            color: Colors.black.withOpacity(.05),
                            border: Border.all(
                                color: Colors.black.withOpacity(.2), width: .5),
                            borderRadius: BorderRadius.circular(15)),
                    child: TypeAheadField<Project>(
                        controller: widget.searchTextEditingController,
                        suggestionsCallback: widget.onSuggestionCallback,
                        itemBuilder: widget.suggestionItemBuilder,
                        onSelected: widget.onSelected,
                        decorationBuilder: (context, child) {
                          return Material(
                            type: MaterialType.card,
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            child: child,
                          );
                        },
                        offset: Offset(0, 12),
                        constraints: BoxConstraints(maxHeight: 500),
                        transitionBuilder: (context, animation, child) {
                          return FadeTransition(
                            opacity: CurvedAnimation(
                                parent: animation, curve: Curves.fastOutSlowIn),
                            child: child,
                          );
                        },
                        itemSeparatorBuilder: null,
                        builder: (context, controller, focusNode) {
                          return TextField(
                            focusNode: focusNode,
                            controller: controller,
                            cursorColor: widget.cursorColor ?? Colors.lightBlue,
                            style: widget.textStyle ??
                                const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: widget.hintText ?? 'Search here...',
                              hintStyle: widget.hintStyle ??
                                  const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300),
                              disabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                            onChanged: widget.onChanged,
                          );
                        }),
                  ),
                ),

                ///  search button
                AnimatedOpacity(
                  opacity: _isSearching ? 0 : 1,
                  duration: _duration,
                  child: AnimatedContainer(
                    curve: Curves.easeInOutCirc,
                    duration: _duration,
                    width: _isSearching ? 0 : 35,
                    height: _isSearching ? 0 : 35,
                    child: FittedBox(
                      child: KCustomButton(
                          widget: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Icon(Icons.search,
                                  size: 35,
                                  color: widget.searchIconColor ??
                                      Colors.black.withOpacity(.7))),
                          onPressed: () => _searchNotifier.state = true),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}

class KCustomButton extends StatelessWidget {
  final Widget widget;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final double? radius;

  const KCustomButton(
      {Key? key,
      required this.widget,
      required this.onPressed,
      this.radius,
      this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 50),
        child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius ?? 50),
            child: InkWell(
                splashColor: Theme.of(context).primaryColor.withOpacity(.2),
                highlightColor: Theme.of(context).primaryColor.withOpacity(.05),
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    child: widget),
                onTap: onPressed,
                onLongPress: onLongPress)));
  }
}

class KBackButton extends StatelessWidget {
  final Widget? previousScreen;
  final Color? iconColor;
  final IconData? icon;
  const KBackButton(
      {Key? key,
      required this.previousScreen,
      required this.iconColor,
      required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
                splashColor: Theme.of(context).primaryColor.withOpacity(.2),
                highlightColor: Theme.of(context).primaryColor.withOpacity(.05),
                onTap: () async {
                  previousScreen == null
                      ? Navigator.pop(context)
                      : Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => previousScreen!));
                },
                child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(icon ?? Icons.arrow_back_ios_new,
                            color: iconColor ?? Colors.black.withOpacity(.7),
                            size: 25))))));
  }
}
