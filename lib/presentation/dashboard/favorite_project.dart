import 'package:boilerplate/core/widgets/lazy_loading_card.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:flutter/material.dart';

// class SearchBottomSheet extends StatefulWidget {
//   const SearchBottomSheet(
//       {required this.onSheetDismissed,
//       this.height = 550,
//       required this.onFilterTap,
//       required this.searchList});
//   final onSheetDismissed;
//   final onFilterTap;
//   final double height;
//   final List<Project> searchList;

//   @override
//   State<SearchBottomSheet> createState() => _SearchBottomSheetState();
// }
//   @override
//   State<SearchBottomSheet> createState() => _SearchBottomSheetState();
// }

// class _SearchBottomSheetState extends State<SearchBottomSheet> {
//   TextEditingController controller = TextEditingController();
//   bool isSuggestionTapped = true;
// class _SearchBottomSheetState extends State<SearchBottomSheet> {
//   TextEditingController controller = TextEditingController();
//   bool isSuggestionTapped = true;

//   @override
//   Widget build(BuildContext context) {
//     // SheetContentScaffold is a special Scaffold designed for use in a sheet.
//     // It has slots for an app bar and a sticky bottom bar, similar to Scaffold.
//     // However, it differs in that its height reduces to fit the 'body' widget.
//     final content = SheetContentScaffold(
//       backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
//       // The bottom bar sticks to the bottom unless the sheet extent becomes
//       // smaller than this threshold extent.
//       requiredMinExtentForStickyBottomBar: const Extent.proportional(0.5),
//       // With the following configuration, the sheet height will be
//       // 500px + (app bar height) + (bottom bar height).
//       body: Container(
//         height: widget.height,
//         child: Align(
//           alignment: Alignment.topCenter,
//           child: isSuggestionTapped
//               ? LazyLoadingAnimationProjectList(
//                   height: MediaQuery.of(context).size.height * 0.8,
//                   list: widget.searchList,
//                   firstCallback: (i) {
//               setState(() {
//                 widget.projectList[i].isFavorite = !widget.projectList[i].isFavorite!;
//               });

//                   },
//                 )
//               : null,
//         ),
//       ),
//       appBar: buildAppBar(context),
//       bottomBar: buildBottomBar(),
//     );
//   @override
//   Widget build(BuildContext context) {
//     // SheetContentScaffold is a special Scaffold designed for use in a sheet.
//     // It has slots for an app bar and a sticky bottom bar, similar to Scaffold.
//     // However, it differs in that its height reduces to fit the 'body' widget.
//     final content = SheetContentScaffold(
//       backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
//       // The bottom bar sticks to the bottom unless the sheet extent becomes
//       // smaller than this threshold extent.
//       requiredMinExtentForStickyBottomBar: const Extent.proportional(0.5),
//       // With the following configuration, the sheet height will be
//       // 500px + (app bar height) + (bottom bar height).
//       body: Container(
//         height: widget.height,
//         child: Align(
//           alignment: Alignment.topCenter,
//           child: isSuggestionTapped
//               ? ExampleUiLoadingAnimation(
//                   height: MediaQuery.of(context).size.height * 0.8,
//                   list: widget.searchList,
//                   firstCallback: (i) {
//               setState(() {
//                 widget.projectList[i].isFavorite = !widget.projectList[i].isFavorite!;
//               });

//                   },
//                 )
//               : null,
//         ),
//       ),
//       appBar: buildAppBar(context),
//       bottomBar: buildBottomBar(),
//     );

//     final physics = StretchingSheetPhysics(
//       parent: SnappingSheetPhysics(
//         snappingBehavior: SnapToNearest(
//           snapTo: [
//             const Extent.proportional(0.2),
//             const Extent.proportional(0.5),
//             const Extent.proportional(0.8),
//             const Extent.proportional(1),
//           ],
//         ),
//       ),
//     );
//     final physics = StretchingSheetPhysics(
//       parent: SnappingSheetPhysics(
//         snappingBehavior: SnapToNearest(
//           snapTo: [
//             const Extent.proportional(0.2),
//             const Extent.proportional(0.5),
//             const Extent.proportional(0.8),
//             const Extent.proportional(1),
//           ],
//         ),
//       ),
//     );

//     return DraggableSheet(
//       physics: physics,
//       keyboardDismissBehavior:
//           const SheetKeyboardDismissBehavior.onDrag(isContentScrollAware: true),
//       minExtent: const Extent.pixels(0),
//       child: Card(
//         clipBehavior: Clip.antiAlias,
//         margin: EdgeInsets.zero,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: content,
//       ),
//     );
//   }
//     return DraggableSheet(
//       physics: physics,
//       keyboardDismissBehavior:
//           const SheetKeyboardDismissBehavior.onDrag(isContentScrollAware: true),
//       minExtent: const Extent.pixels(0),
//       child: Card(
//         clipBehavior: Clip.antiAlias,
//         margin: EdgeInsets.zero,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: content,
//       ),
//     );
//   }

//   PreferredSizeWidget buildAppBar(BuildContext context) {
//     return AppBar(
//       toolbarHeight: 80,
//       titleSpacing: 0,
//       // title: const Text('Search projects'),
//       backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
//       title: AnimSearchBar2(
//         textFieldColor: Theme.of(context).colorScheme.surface,
//         color: Theme.of(context).colorScheme.surface,
//         onSubmitted: (p0) {},
//         width: MediaQuery.of(context).size.width,
//         textController: controller,
//         onSuffixTap: () {},
//         onSelected: (project) {
//           print(project.title);
//           setState(() {
//             isSuggestionTapped = true;
//           });
//         },
//         searchTextEditingController: controller,
//         onSuggestionCallback: (pattern) {
//           if (pattern.isEmpty) return [];
//           return Future<List<Project>>.delayed(
//             const Duration(milliseconds: 300),
//             () => widget.projectList.where((product) {
//               final nameLower = product.title.toLowerCase().split(' ').join('');
//               print(nameLower);
//               final patternLower = pattern.toLowerCase().split(' ').join('');
//               return nameLower.contains(patternLower);
//             }).toList(),
//           );
//         },
//         suggestionItemBuilder: (context, project) => ListTile(
//           title: Text(project.title),
//           subtitle: Text(project.description),
//         ),
//       ),
//   PreferredSizeWidget buildAppBar(BuildContext context) {
//     return AppBar(
//       toolbarHeight: 80,
//       titleSpacing: 0,
//       // title: const Text('Search projects'),
//       backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
//       title: AnimSearchBar2(
//         textFieldColor: Theme.of(context).colorScheme.surface,
//         color: Theme.of(context).colorScheme.surface,
//         onSubmitted: (p0) {},
//         width: MediaQuery.of(context).size.width,
//         textController: controller,
//         onSuffixTap: () {},
//         onSelected: (project) {
//           print(project.title);
//           setState(() {
//             isSuggestionTapped = true;
//           });
//         },
//         searchTextEditingController: controller,
//         onSuggestionCallback: (pattern) {
//           if (pattern.isEmpty) return [];
//           return Future<List<Project>>.delayed(
//             const Duration(milliseconds: 300),
//             () => widget.projectList.where((product) {
//               final nameLower = product.title.toLowerCase().split(' ').join('');
//               print(nameLower);
//               final patternLower = pattern.toLowerCase().split(' ').join('');
//               return nameLower.contains(patternLower);
//             }).toList(),
//           );
//         },
//         suggestionItemBuilder: (context, project) => ListTile(
//           title: Text(project.title),
//           subtitle: Text(project.description),
//         ),
//       ),

//       actions: [
//         IconButton(
//             onPressed: () {
//               widget.onFilterTap();
//             },
//             icon: Icon(Icons.filter_alt_outlined))
//       ],
//     );
//   }
//       actions: [
//         IconButton(
//             onPressed: () {
//               widget.onFilterTap();
//             },
//             icon: Icon(Icons.filter_alt_outlined))
//       ],
//     );
//   }

//   Widget buildBottomBar() {
//     return BottomAppBar(
//       height: 70,
//       surfaceTintColor: Colors.white,
//       child: Center(
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Flexible(
//             //   fit: FlexFit.tight,
//             //   child: TextButton(
//             //     onPressed: () {
//             //       widget.onSheetDismissed();
//             //     },
//             //     child: const Text('Cancel'),
//             //   ),
//             // ),
//             // const SizedBox(width: 16),
//             RoundedButtonWidget(
//               buttonColor: Theme.of(context).colorScheme.primary,
//               onPressed: () {
//                 widget.onSheetDismissed();
//               },
//               buttonText: "OK",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//   Widget buildBottomBar() {
//     return BottomAppBar(
//       height: 70,
//       surfaceTintColor: Colors.white,
//       child: Center(
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Flexible(
//             //   fit: FlexFit.tight,
//             //   child: TextButton(
//             //     onPressed: () {
//             //       widget.onSheetDismissed();
//             //     },
//             //     child: const Text('Cancel'),
//             //   ),
//             // ),
//             // const SizedBox(width: 16),
//             RoundedButtonWidget(
//               buttonColor: Theme.of(context).colorScheme.primary,
//               onPressed: () {
//                 widget.onSheetDismissed();
//               },
//               buttonText: "OK",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key, this.projectList, this.onFavoriteTap});
  final List<Project>? projectList;
  final Function? onFavoriteTap;

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return _buildProjectContent();
  }

  double yOffset = 0;
  String keyword = "";

  Widget _buildProjectContent() {
    if (yOffset == 0) {
      yOffset = MediaQuery.of(context).size.height;
    }
    return Stack(
      // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Text("This is project page"),
        Align(
            alignment: Alignment.topRight,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      keyword = value;
                    },
                    onSubmitted: (value) {},
                    decoration: InputDecoration(
                      hintText: 'Search for projects',
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search,
                            size: 35, color: Colors.black.withOpacity(.7)),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
              ],
            )),
        const SizedBox(
          height: 100,
        ),
        Container(
          margin: const EdgeInsets.only(top: 40),
          child: LazyLoadingAnimationProjectList(
            itemHeight: 230,
            list: widget.projectList ?? [],
            firstCallback: (i) {
              setState(() {
                if (widget.onFavoriteTap != null) widget.onFavoriteTap!(i);
                if (widget.onFavoriteTap != null) widget.onFavoriteTap!(i);
              });
            },
          ),
        ),
        // AnimatedContainer(
        //     curve: Easing.legacyAccelerate,
        //     // color: Colors.amber,
        //     alignment: Alignment.bottomCenter,
        //     duration: Duration(milliseconds: 300),
        //     transform: Matrix4.translationValues(0, yOffset, -1.0),
        //     child: SearchBottomSheet(
        //       searchList: widget.projectList
        //           .where((e) =>
        //               e.title.toLowerCase().contains(keyword.toLowerCase()))
        //           .toList(),
        //       onSheetDismissed: () {
        //         setState(() {
        //           NavbarNotifier2.hideBottomNavBar = false;
        //           yOffset = MediaQuery.of(context).size.height;
        //         });
        //         final FocusScopeNode currentScope = FocusScope.of(context);
        //         if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
        //           FocusManager.instance.primaryFocus?.unfocus();
        //         }
        //         return true;
        //       },
        //       onFilterTap: () {},
        //     )),
        // AnimatedContainer(
        //     curve: Easing.legacyAccelerate,
        //     // color: Colors.amber,
        //     alignment: Alignment.bottomCenter,
        //     duration: Duration(milliseconds: 300),
        //     transform: Matrix4.translationValues(0, yOffset, -1.0),
        //     child: SearchBottomSheet(
        //       searchList: widget.projectList
        //           .where((e) =>
        //               e.title.toLowerCase().contains(keyword.toLowerCase()))
        //           .toList(),
        //       onSheetDismissed: () {
        //         setState(() {
        //           NavbarNotifier2.hideBottomNavBar = false;
        //           yOffset = MediaQuery.of(context).size.height;
        //         });
        //         final FocusScopeNode currentScope = FocusScope.of(context);
        //         if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
        //           FocusManager.instance.primaryFocus?.unfocus();
        //         }
        //         return true;
        //       },
        //       onFilterTap: () {},
        //     )),
      ],
    );
  }
}
