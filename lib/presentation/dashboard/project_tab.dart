import 'package:boilerplate/core/widgets/lazy_loading_card.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/searchbar_widget.dart';
import 'package:boilerplate/utils/classes.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route_navbar.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet(
      {required this.onSheetDismissed,
      this.height = 550,
      required this.onFilterTap});
  final onSheetDismissed;
  final onFilterTap;
  final double height;

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  TextEditingController controller = TextEditingController();
  bool isSuggestionTapped = false;

  var allProjects = [
    Project(title: "ABC", description: "description"),
    Project(title: "XYZ", description: "description"),
    Project(title: "JKMM", description: "description"),
    Project(title: "man bhsk p", description: "description"),
    Project(title: "jOa josfj á ", description: "description"),
  ];

  @override
  Widget build(BuildContext context) {
    // SheetContentScaffold is a special Scaffold designed for use in a sheet.
    // It has slots for an app bar and a sticky bottom bar, similar to Scaffold.
    // However, it differs in that its height reduces to fit the 'body' widget.
    final content = SheetContentScaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      // The bottom bar sticks to the bottom unless the sheet extent becomes
      // smaller than this threshold extent.
      requiredMinExtentForStickyBottomBar: const Extent.proportional(0.5),
      // With the following configuration, the sheet height will be
      // 500px + (app bar height) + (bottom bar height).
      body: Container(
        height: widget.height,
        child: Align(
          alignment: Alignment.topCenter,
          child: isSuggestionTapped
              ? ExampleUiLoadingAnimation(
                  height: MediaQuery.of(context).size.height * 0.8,
                )
              : null,
          // child:
          // AnimationSearchBar(
          //   onSelected: (project) {
          //     print(project.title);
          //   },
          //   onSuggestionCallback: (pattern) {
          //     return Future<List<Project>>.delayed(
          //       Duration(milliseconds: 300),
          //       () => allProjects.where((product) {
          //         final nameLower =
          //             product.title.toLowerCase().split(' ').join('');
          //         print(nameLower);
          //         final patternLower =
          //             pattern.toLowerCase().split(' ').join('');
          //         return nameLower.contains(patternLower);
          //       }).toList(),
          //     );
          //   },
          //   suggestionItemBuilder: (context, project) => ListTile(
          //     title: Text(project.title),
          //     subtitle: Text(project.description),
          //   ),

          //   ///! Required
          //   onChanged: (text) => debugPrint(text),
          //   searchTextEditingController: controller,

          //   ///! Optional. For more customization
          //   //? Back Button
          //   backIcon: Icons.arrow_back_ios_new,
          //   backIconColor: Colors.black,
          //   isBackButtonVisible: false,
          //   previousScreen:
          //       null, // It will push and replace this screen when pressing the back button
          //   //? Close Button
          //   closeIconColor: Colors.black,
          //   //? Center Title
          //   centerTitle: ' ',
          //   hintText: 'Type here...',
          //   centerTitleStyle:
          //       const TextStyle(fontWeight: FontWeight.w500, fontSize: 13,),
          //   //? Search hint text
          //   hintStyle: const TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
          //   //? Search Text
          //   textStyle: const TextStyle(fontWeight: FontWeight.w300),
          //   //? Cursor color
          //   cursorColor: Colors.lightBlue.shade300,
          //   //? Duration
          //   duration: const Duration(milliseconds: 300),
          //   //? Height, Width & Padding
          //   searchFieldHeight: 35, // Total height of the search field
          //   searchBarHeight: 50, // Total height of this Widget
          //   searchBarWidth: MediaQuery.of(context).size.width -
          //       20, // Total width of this Widget
          //   horizontalPadding: 10,
          //   verticalPadding: 0,
          //   //? Search icon color
          //   searchIconColor: Colors.black.withOpacity(.7),
          //   //? Search field background decoration
          //   searchFieldDecoration: BoxDecoration(
          //       border:
          //           Border.all(color: Colors.black.withOpacity(.2), width: .5),
          //       borderRadius: BorderRadius.circular(15)),
          // ),
        ),
      ),
      appBar: buildAppBar(context),
      bottomBar: buildBottomBar(),
    );

    final physics = StretchingSheetPhysics(
      parent: SnappingSheetPhysics(
        snappingBehavior: SnapToNearest(
          snapTo: [
            const Extent.proportional(0.2),
            const Extent.proportional(0.5),
            const Extent.proportional(0.8),
            const Extent.proportional(1),
          ],
        ),
      ),
    );

    return DraggableSheet(
      physics: physics,
      keyboardDismissBehavior:
          SheetKeyboardDismissBehavior.onDrag(isContentScrollAware: true),
      minExtent: const Extent.pixels(0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      ),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      titleSpacing: 0,
      // title: const Text('Search projects'),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      title:  AnimSearchBar2(
          textFieldColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.surface,
          onSubmitted: (p0) {},
          width: MediaQuery.of(context).size.width,
          textController: controller,
          onSuffixTap: () {},
          onSelected: (project) {
            print(project.title);
            setState(() {
              isSuggestionTapped = true;
            });
          },
          searchTextEditingController: controller,
          onSuggestionCallback: (pattern) {
            if (pattern.isEmpty) return [];
            return Future<List<Project>>.delayed(
              Duration(milliseconds: 300),
              () => allProjects.where((product) {
                final nameLower =
                    product.title.toLowerCase().split(' ').join('');
                print(nameLower);
                final patternLower = pattern.toLowerCase().split(' ').join('');
                return nameLower.contains(patternLower);
              }).toList(),
            );
          },
          suggestionItemBuilder: (context, project) => ListTile(
            title: Text(project.title),
            subtitle: Text(project.description),
          ),
        ),
        
      actions: [
       IconButton(
            onPressed: () {
              widget.onFilterTap();
            },
            icon: Icon(Icons.filter_alt_outlined))
      ],
    );
  }

  Widget buildBottomBar() {
    return BottomAppBar(
      height: 70,
      surfaceTintColor: Colors.white,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flexible(
            //   fit: FlexFit.tight,
            //   child: TextButton(
            //     onPressed: () {
            //       widget.onSheetDismissed();
            //     },
            //     child: const Text('Cancel'),
            //   ),
            // ),
            // const SizedBox(width: 16),
            RoundedButtonWidget(
              buttonColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                widget.onSheetDismissed();
              },
              buttonText: "OK",
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectTab extends StatefulWidget {
  @override
  State<ProjectTab> createState() => _ProjectTabState();
}

class _ProjectTabState extends State<ProjectTab> {
  @override
  Widget build(BuildContext context) {
    return _buildProjectContent();
  }

  // Future<SearchBottomSheet?> showTodoEditor(BuildContext context) {
  //   return Navigator.push(
  //     context,
  //     ModalSheetRoute(
  //       builder: (context) => SearchBottomSheet(),
  //     ),
  //   );
  // }

  double yOffset = 0;

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
          child: IconButton(
            icon: Icon(Icons.search,
                size: 35, color: Colors.black ?? Colors.black.withOpacity(.7)),
            onPressed: () {
              // showTodoEditor(context);
              setState(() {
                if (yOffset == MediaQuery.of(context).size.height) {
                  NavbarNotifier2.hideBottomNavBar = true;
                  yOffset = -(MediaQuery.of(context).size.height) * 0.05 + 45;
                } else {
                  NavbarNotifier2.hideBottomNavBar = false;
                  yOffset = MediaQuery.of(context).size.height;
                }
              });
            },
          ),
        ),
        SizedBox(
          height: 100,
        ),
        Container(
          margin: EdgeInsets.only(top: 40),
          child: ExampleUiLoadingAnimation(
              height: MediaQuery.of(context).size.height - 60),
        ),
        AnimatedContainer(
            curve: Easing.legacyAccelerate,
            // color: Colors.amber,
            alignment: Alignment.bottomCenter,
            duration: Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, yOffset, -1.0),
            child: SearchBottomSheet(
              onSheetDismissed: () {
              setState(() {
                NavbarNotifier2.hideBottomNavBar = false;
                yOffset = MediaQuery.of(context).size.height;
              });
              final FocusScopeNode currentScope = FocusScope.of(context);
              if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
              return true;
            },
            onFilterTap: () {},
            )),
      ],
    );
  }
}
