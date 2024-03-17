library animation_search_bar;

import 'dart:async';

import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'dart:math';
// ignore: duplicate_import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimSearchBar2 extends StatefulWidget {
  ///  width - double ,isRequired : Yes
  ///  textController - TextEditingController  ,isRequired : Yes
  ///  onSuffixTap - Function, isRequired : Yes
  ///  onSubmitted - Function, isRequired : Yes
  ///  rtl - Boolean, isRequired : No
  ///  autoFocus - Boolean, isRequired : No
  ///  style - TextStyle, isRequired : No
  ///  closeSearchOnSuffixTap - bool , isRequired : No
  ///  suffixIcon - Icon ,isRequired :  No
  ///  prefixIcon - Icon  ,isRequired : No
  ///  animationDurationInMilli -  int ,isRequired : No
  ///  helpText - String ,isRequired :  No
  ///  inputFormatters - TextInputFormatter, Required - No
  ///  boxShadow - bool ,isRequired : No
  ///  textFieldColor - Color ,isRequired : No
  ///  searchIconColor - Color ,isRequired : No
  ///  textFieldIconColor - Color ,isRequired : No

  final double width;
  final TextEditingController textController;
  final Icon? suffixIcon;
  final Icon? prefixIcon;
  final String helpText;
  final int animationDurationInMilli;
  final onSuffixTap;
  final bool rtl;
  final bool autoFocus;
  final TextStyle? style;
  final bool closeSearchOnSuffixTap;
  final Color? color;
  final Color? textFieldColor;
  final Color? searchIconColor;
  final Color? textFieldIconColor;
  final List<TextInputFormatter>? inputFormatters;
  final bool boxShadow;
  final Function(String) onSubmitted;
  final TextEditingController searchTextEditingController;
  final Widget Function(BuildContext, Project) suggestionItemBuilder;
  final Function(Project)? onSelected;
  final FutureOr<List<Project>?> Function(String) onSuggestionCallback;

  const AnimSearchBar2(
      {Key? key,

      /// The width cannot be null
      required this.width,

      /// The textController cannot be null
      required this.textController,
      this.suffixIcon,
      this.prefixIcon,
      this.helpText = "Search...",

      /// choose your custom color
      this.color = Colors.white,

      /// choose your custom color for the search when it is expanded
      this.textFieldColor = Colors.white,

      /// choose your custom color for the search when it is expanded
      this.searchIconColor = Colors.black,

      /// choose your custom color for the search when it is expanded
      this.textFieldIconColor = Colors.black,

      /// The onSuffixTap cannot be null
      required this.onSuffixTap,
      this.animationDurationInMilli = 375,

      /// The onSubmitted cannot be null
      required this.onSubmitted,

      /// make the search bar to open from right to left
      this.rtl = false,

      /// make the keyboard to show automatically when the searchbar is expanded
      this.autoFocus = false,

      /// TextStyle of the contents inside the searchbar
      this.style,

      /// close the search on suffix tap
      this.closeSearchOnSuffixTap = false,

      /// enable/disable the box shadow decoration
      this.boxShadow = true,

      /// can add list of inputformatters to control the input
      this.inputFormatters,
      required this.searchTextEditingController,
      required this.suggestionItemBuilder,
      required this.onSelected,
      required this.onSuggestionCallback})
      : super(key: key);

  @override
  _AnimSearchBar2State createState() => _AnimSearchBar2State();
}

///toggle - 0 => false or closed
///toggle 1 => true or open
int toggle = 1;

/// * use this variable to check current text from OnChange
String textFieldValue = '';

class _AnimSearchBar2State extends State<AnimSearchBar2>
    with SingleTickerProviderStateMixin {
  ///initializing the AnimationController
  late AnimationController _con;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    ///Initializing the animationController which is responsible for the expanding and shrinking of the search bar
    _con = AnimationController(
      vsync: this,

      /// animationDurationInMilli is optional, the default value is 375
      duration: Duration(milliseconds: widget.animationDurationInMilli),
    );
  }

  unfocusKeyboard() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
                    border: toggle == 1 ? Border(
              bottom: BorderSide(width: 0.5, color: Colors.grey),
            ) : null,
      ),
      height: 50.0,

      ///if the rtl is true, search bar will be from right to left
      alignment:
          widget.rtl ? Alignment.centerRight : const Alignment(-1.0, 0.0),

      ///Using Animated container to expand and shrink the widget
      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.animationDurationInMilli),
        height: 48.0,
        width: (toggle == 0) ? 48.0 : widget.width,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          /// can add custom  color or the color will be white
          color: toggle == 1 ? widget.textFieldColor : widget.color,
          borderRadius: BorderRadius.circular(3.0),

          /// show boxShadow unless false was passed
          boxShadow: !widget.boxShadow
              ? null
              // : [
              //     const BoxShadow(
              //       color: Colors.black26,
              //       spreadRadius: -10.0,
              //       blurRadius: 1.0,
              //       offset: Offset(0.0, 10.0),
              //     ),
              //   ],
              : null,
        ),
        child: Stack(
          children: [
            ///Using Animated Positioned widget to expand and shrink the widget
            AnimatedPositioned(
              duration: Duration(milliseconds: widget.animationDurationInMilli),
              top: 1.0,
              right: 7.0,
              bottom: 1.0,
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: (toggle == 0) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    /// can add custom color or the color will be white
                    color: widget.color,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: AnimatedBuilder(
                    builder: (context, widget) {
                      ///Using Transform.rotate to rotate the suffix icon when it gets expanded
                      return Transform.rotate(
                        angle: _con.value * 2.0 * pi,
                        child: widget,
                      );
                    },
                    animation: _con,
                    child: GestureDetector(
                      onTap: () {
                        try {
                          ///trying to execute the onSuffixTap function
                          widget.onSuffixTap();

                          // * if field empty then the user trying to close bar
                          if (textFieldValue == '') {
                            unfocusKeyboard();
                            setState(() {
                              toggle = 0;
                            });

                            ///reverse == close
                            _con.reverse();
                          }

                          // * why not clear textfield here?
                          widget.textController.clear();
                          textFieldValue = '';

                          ///closeSearchOnSuffixTap will execute if it's true
                          if (widget.closeSearchOnSuffixTap) {
                            unfocusKeyboard();
                                  focusNode.unfocus();

                            setState(() {
                              toggle = 0;
                            });
                          }
                        } catch (e) {
                          ///print the error if the try block fails
                          print(e);
                        }
                      },

                      ///suffixIcon is of type Icon
                      child: widget.suffixIcon ??
                          IconButton(
                            padding: EdgeInsets.only(left: 20),
                            alignment: Alignment.centerRight,
                            icon: Icon(
                              Icons.close_outlined,
                              size: 20.0,
                            ),
                            color: widget.textFieldIconColor,
                            onPressed: () {
                              try {
                                ///trying to execute the onSuffixTap function
                                widget.onSuffixTap();

                                // * if field empty then the user trying to close bar
                                if (textFieldValue == '') {
                                  unfocusKeyboard();
                                  setState(() {
                                    toggle = 0;
                                  });

                                  ///reverse == close
                                  _con.reverse();
                                }

                                // * why not clear textfield here?
                                widget.textController.clear();
                                textFieldValue = '';

                                ///closeSearchOnSuffixTap will execute if it's true
                                if (widget.closeSearchOnSuffixTap) {
                                  unfocusKeyboard();
                                  focusNode.unfocus();
                                  setState(() {
                                    toggle = 0;
                                  });
                                }
                              } catch (e) {
                                ///print the error if the try block fails
                                print(e);
                              }
                            },
                          ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: widget.animationDurationInMilli),
              left: (toggle == 0) ? 20.0 : 10,
              right: (toggle == 0) ? 0 : 40,
              curve: Curves.easeOut,
              top: 6.0,

              ///Using Animated opacity to change the opacity of th textField while expanding
              child: AnimatedOpacity(
                opacity: (toggle == 0) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  alignment: Alignment.topCenter,
                  width: widget.width,
                  child: TypeAheadField<Project>(
                    hideOnSelect: true,
                      focusNode: focusNode,
                      hideOnEmpty: true,
                      hideWithKeyboard: false,
                      hideKeyboardOnDrag: true,
                      hideOnUnfocus: false,
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
                      offset: const Offset(0, 12),
                      constraints: const BoxConstraints(maxHeight: 300),
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
                          ///Text Controller. you can manipulate the text inside this textField by calling this controller.
                          controller: widget.textController,
                          inputFormatters: widget.inputFormatters,
                          focusNode: focusNode,
                          cursorRadius: const Radius.circular(10.0),
                          cursorWidth: 2.0,
                          onChanged: (value) {
                            textFieldValue = value;
                          },
                          onSubmitted: (value) => {
                            widget.onSubmitted(value),
                            unfocusKeyboard(),
                            setState(() {
                              toggle = 0;
                            }),
                            widget.textController.clear(),
                          },
                          onEditingComplete: () {
                            /// on editing complete the keyboard will be closed and the search bar will be closed
                            unfocusKeyboard();
                            setState(() {
                              toggle = 0;
                            });
                          },

                          ///style is of type TextStyle, the default is just a color black
                          style: widget.style ??
                              const TextStyle(color: Colors.black),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(bottom: 5),
                            isDense: true,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: widget.helpText,
                            labelStyle: const TextStyle(
                              color: Color(0xff5B5B5B),
                              fontSize: 17.0,
                              fontWeight: FontWeight.w500,
                            ),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide.none,
                            ),
                            // enabledBorder: OutlineInputBorder(
                            //   borderSide: const BorderSide(color: Colors.black, width: 2.0),
                            // ),
                            // focusedBorder: OutlineInputBorder(
                            //   borderRadius: BorderRadius.circular(20.0),
                            //   borderSide: const BorderSide(color: Colors.black, width: 2.0),
                            // ),
                          ),
                        );
                      }),
                ),
              ),
            ),

            ///Using material widget here to get the ripple effect on the prefix icon
            Material(
              /// can add custom color or the color will be white
              /// toggle button color based on toggle state
              color: toggle == 0 ? widget.color : widget.textFieldColor,
              borderRadius: BorderRadius.circular(30.0),
              child: toggle == 0
                  ? IconButton(
                      splashRadius: 19.0,

                      ///if toggle is 1, which means it's open. so show the back icon, which will close it.
                      ///if the toggle is 0, which means it's closed, so tapping on it will expand the widget.
                      ///prefixIcon is of type Icon
                      icon: widget.prefixIcon != null
                          ? toggle == 1
                              ? Icon(
                                  Icons.arrow_back_ios,
                                  color: widget.textFieldIconColor,
                                )
                              : widget.prefixIcon!
                          : Icon(
                              toggle == 1 ? 
                              Icons.arrow_back_ios : 
                              Icons.search,
                              // search icon color when closed
                              color: toggle == 0
                                  ? widget.searchIconColor
                                  : widget.textFieldIconColor,
                              size: 20.0,
                            ),
                      onPressed: () {
                        setState(
                          () {
                            ///if the search bar is closed
                            if (toggle == 0) {
                              toggle = 1;
                              setState(() {
                                ///if the autoFocus is true, the keyboard will pop open, automatically
                                if (widget.autoFocus)
                                  FocusScope.of(context)
                                      .requestFocus(focusNode);
                              });

                              ///forward == expand
                              _con.forward();
                            } else {
                              ///if the search bar is expanded
                              toggle = 0;

                              ///if the autoFocus is true, the keyboard will close, automatically
                              setState(() {
                                if (widget.autoFocus) unfocusKeyboard();
                              });

                              ///reverse == close
                              _con.reverse();
                            }
                          },
                        );
                      },
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// final searchingProvider = StateProvider.autoDispose((ref) => false);

// // ignore: must_be_immutable
// class AnimationSearchBar extends StatefulWidget {
//   AnimationSearchBar(
//       {Key? key,
//       this.searchBarWidth,
//       this.searchBarHeight,
//       this.previousScreen,
//       this.backIconColor,
//       this.closeIconColor,
//       this.searchIconColor,
//       this.centerTitle,
//       this.centerTitleStyle,
//       this.searchFieldHeight,
//       this.searchFieldDecoration,
//       this.cursorColor,
//       this.textStyle,
//       this.hintText,
//       this.hintStyle,
//       required this.onChanged,
//       required this.searchTextEditingController,
//       this.horizontalPadding,
//       this.verticalPadding,
//       this.isBackButtonVisible,
//       this.backIcon,
//       this.duration,
//       required this.suggestionItemBuilder,
//       required this.onSelected,
//       required this.onSuggestionCallback})
//       : super(key: key);

//   ///
//   final double? searchBarWidth;
//   final double? searchBarHeight;
//   final double? searchFieldHeight;
//   final double? horizontalPadding;
//   final double? verticalPadding;
//   final Widget? previousScreen;
//   final Color? backIconColor;
//   final Color? closeIconColor;
//   final Color? searchIconColor;
//   final Color? cursorColor;
//   final String? centerTitle;
//   final String? hintText;
//   final bool? isBackButtonVisible;
//   final IconData? backIcon;
//   final TextStyle? centerTitleStyle;
//   final TextStyle? textStyle;
//   final TextStyle? hintStyle;
//   final Decoration? searchFieldDecoration;
//   late Duration? duration;
//   final TextEditingController searchTextEditingController;
//   final Function(String) onChanged;
//   final Widget Function(BuildContext, Project) suggestionItemBuilder;
//   Function(Project)? onSelected;
//   FutureOr<List<Project>?> Function(String) onSuggestionCallback;

//   @override
//   State<AnimationSearchBar> createState() => _AnimationSearchBarState();
// }

// class _AnimationSearchBarState extends State<AnimationSearchBar> {
//   final focusNode = FocusNode();
//   @override
//   Widget build(BuildContext context) {
//     final _duration = widget.duration ?? const Duration(milliseconds: 500);
//     final _searchFieldHeight = widget.searchFieldHeight ?? 40;
//     final _hPadding =
//         widget.horizontalPadding != null ? widget.horizontalPadding! * 2 : 0;
//     final _searchBarWidth = (widget.searchBarWidth ??
//         MediaQuery.of(context).size.width - _hPadding);
//     final _isBackButtonVisible = widget.isBackButtonVisible ?? true;
//     return ProviderScope(
//       child: Consumer(builder: (context, ref, __) {
//         final _isSearching = ref.watch(searchingProvider);
//         final _searchNotifier = ref.watch(searchingProvider.notifier);
//         return Padding(
//           padding: EdgeInsets.symmetric(
//               horizontal: widget.horizontalPadding ?? 0,
//               vertical: widget.verticalPadding ?? 0),
//           child: SizedBox(
//             width: _searchBarWidth,
//             height: widget.searchBarHeight ?? 50,
//             child: Container(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   /// back Button
//                   _isBackButtonVisible
//                       ? AnimatedOpacity(
//                           opacity: _isSearching ? 0 : 1,
//                           duration: _duration,
//                           child: AnimatedContainer(
//                               curve: Curves.easeInOutCirc,
//                               width: _isSearching ? 0 : 35,
//                               height: _isSearching ? 0 : 35,
//                               duration: _duration,
//                               child: FittedBox(
//                                   child: KBackButton(
//                                       icon: widget.backIcon,
//                                       iconColor: widget.backIconColor,
//                                       previousScreen: widget.previousScreen))))
//                       : AnimatedContainer(
//                           curve: Curves.easeInOutCirc,
//                           width: 0,
//                           height: _isSearching ? 0 : 35,
//                           duration: _duration),

//                   /// text
//                   AnimatedOpacity(
//                     opacity: _isSearching ? 0 : 1,
//                     duration: _duration,
//                     child: AnimatedContainer(
//                       curve: Curves.easeInOutCirc,
//                       width: _isSearching ? 0 : _searchBarWidth - 100,
//                       duration: _duration,
//                       alignment: Alignment.centerLeft,
//                       child: FittedBox(
//                         child: Text(
//                           widget.centerTitle ?? 'Title',
//                           textAlign: TextAlign.center,
//                           style: widget.centerTitleStyle ??
//                               const TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black,
//                                 fontSize: 20,
//                               ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   /// close search

//                   /// input panel
//                   AnimatedOpacity(
//                     opacity: _isSearching ? 1 : 0,
//                     duration: _duration,
//                     child: AnimatedContainer(
//                       curve: Curves.easeInOutCirc,
//                       duration: _duration,
//                       width: _isSearching
//                           ? _searchBarWidth -
//                               10 -
//                               (widget.horizontalPadding ?? 0 * 2)
//                           : 0,
//                       height: _isSearching ? _searchFieldHeight : 20,
//                       // margin: EdgeInsets.only(
//                       //     left: _isSearching ? 5 : 0,
//                       //     right: _isSearching ? 10 : 0),
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       alignment: Alignment.center,
//                       decoration: widget.searchFieldDecoration ??
//                           BoxDecoration(
//                               color: Colors.black.withOpacity(.05),
//                               border: Border.all(
//                                   color: const Color.fromRGBO(0, 0, 0, 1)
//                                       .withOpacity(.2),
//                                   width: .5),
//                               borderRadius: BorderRadius.circular(15)),
//                       child: TypeAheadField<Project>(
//                           focusNode: focusNode,
//                           hideWithKeyboard: false,
//                           hideOnUnfocus: false,
//                           controller: widget.searchTextEditingController,
//                           suggestionsCallback: widget.onSuggestionCallback,
//                           itemBuilder: widget.suggestionItemBuilder,
//                           onSelected: widget.onSelected,
//                           decorationBuilder: (context, child) {
//                             return Material(
//                               type: MaterialType.card,
//                               elevation: 4,
//                               borderRadius: BorderRadius.circular(8),
//                               child: child,
//                             );
//                           },
//                           offset: const Offset(0, 12),
//                           constraints: const BoxConstraints(maxHeight: 300),
//                           transitionBuilder: (context, animation, child) {
//                             return FadeTransition(
//                               opacity: CurvedAnimation(
//                                   parent: animation,
//                                   curve: Curves.fastOutSlowIn),
//                               child: child,
//                             );
//                           },
//                           itemSeparatorBuilder: null,
//                           builder: (context, controller, focusNode) {
//                             return TextField(
//                               focusNode: focusNode,
//                               controller: controller,
//                               cursorColor:
//                                   widget.cursorColor ?? Colors.lightBlue,
//                               style: widget.textStyle ??
//                                   const TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.w300),
//                               decoration: InputDecoration(
//                                 suffixIcon: AnimatedOpacity(
//                                   opacity: _isSearching ? 1 : 0,
//                                   duration: _duration,
//                                   child: AnimatedContainer(
//                                     curve: Curves.easeInOutCirc,
//                                     width: _isSearching ? 35 : 0,
//                                     height: _isSearching ? 35 : 0,
//                                     duration: _duration,
//                                     child: FittedBox(
//                                       child: KCustomButton(
//                                         widget: Padding(
//                                             padding: const EdgeInsets.all(3),
//                                             child: Icon(Icons.close,
//                                                 color: widget.closeIconColor ??
//                                                     Colors.black
//                                                         .withOpacity(.7))),
//                                         onPressed: () {
//                                           _searchNotifier.state = false;
//                                           focusNode.unfocus();
//                                           widget.searchTextEditingController
//                                               .clear();
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 contentPadding: EdgeInsets.zero,
//                                 hintText: widget.hintText ?? 'Type here...',
//                                 hintStyle: widget.hintStyle ??
//                                     const TextStyle(
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w300),
//                                 disabledBorder: const OutlineInputBorder(
//                                     borderSide: BorderSide.none),
//                                 focusedBorder: const OutlineInputBorder(
//                                     borderSide: BorderSide.none),
//                                 enabledBorder: const OutlineInputBorder(
//                                     borderSide: BorderSide.none),
//                                 border: const OutlineInputBorder(
//                                     borderSide: BorderSide.none),
//                               ),
//                               onChanged: widget.onChanged,
//                             );
//                           }),
//                     ),
//                   ),

//                   ///  search button
//                   AnimatedOpacity(
//                     opacity: _isSearching ? 0 : 1,
//                     duration: _duration,
//                     child: AnimatedContainer(
//                       curve: Curves.easeInOutCirc,
//                       duration: _duration,
//                       width: _isSearching ? 0 : 35,
//                       height: _isSearching ? 0 : 35,
//                       child: FittedBox(
//                         child: KCustomButton(
//                             widget: Padding(
//                                 padding: const EdgeInsets.all(5),
//                                 child: Icon(Icons.search,
//                                     size: 35,
//                                     color: widget.searchIconColor ??
//                                         Colors.black.withOpacity(.7))),
//                             onPressed: () {
//                               _searchNotifier.state = true;
//                               // focusNode.nextFocus();
//                             }),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }

// class KCustomButton extends StatelessWidget {
//   final Widget widget;
//   final VoidCallback onPressed;
//   final VoidCallback? onLongPress;
//   final double? radius;

//   const KCustomButton(
//       {Key? key,
//       required this.widget,
//       required this.onPressed,
//       this.radius,
//       this.onLongPress})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//         borderRadius: BorderRadius.circular(radius ?? 50),
//         child: Material(
//             color: Colors.transparent,
//             borderRadius: BorderRadius.circular(radius ?? 50),
//             child: InkWell(
//                 splashColor: Theme.of(context).primaryColor.withOpacity(.2),
//                 highlightColor: Theme.of(context).primaryColor.withOpacity(.05),
//                 child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
//                     child: widget),
//                 onTap: onPressed,
//                 onLongPress: onLongPress)));
//   }
// }

// class KBackButton extends StatelessWidget {
//   final Widget? previousScreen;
//   final Color? iconColor;
//   final IconData? icon;
//   const KBackButton(
//       {Key? key,
//       required this.previousScreen,
//       required this.iconColor,
//       required this.icon})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//         borderRadius: BorderRadius.circular(50),
//         child: Material(
//             color: Colors.transparent,
//             borderRadius: BorderRadius.circular(50),
//             child: InkWell(
//                 splashColor: Theme.of(context).primaryColor.withOpacity(.2),
//                 highlightColor: Theme.of(context).primaryColor.withOpacity(.05),
//                 onTap: () async {
//                   previousScreen == null
//                       ? Navigator.pop(context)
//                       : Navigator.pushReplacement(
//                           context,
//                           CupertinoPageRoute(
//                               builder: (context) => previousScreen!));
//                 },
//                 child: Padding(
//                     padding: const EdgeInsets.all(3),
//                     child: SizedBox(
//                         width: 30,
//                         height: 30,
//                         child: Icon(icon ?? Icons.arrow_back_ios_new,
//                             color: iconColor ?? Colors.black.withOpacity(.7),
//                             size: 25))))));
//   }
// }
