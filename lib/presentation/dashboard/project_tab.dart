import 'package:boilerplate/core/widgets/lazy_loading_card.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/searchbar_widget.dart';
import 'package:boilerplate/domain/entity/project/mockData.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/dashboard/components/project_item.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class _ConfirmPage extends StatefulWidget {
  const _ConfirmPage();

  @override
  State<_ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<_ConfirmPage> {
  @override
  Widget build(BuildContext context) {
    return SheetDismissible(
      child: ScrollableSheet(
        keyboardDismissBehavior: const SheetKeyboardDismissBehavior.onDragDown(
          isContentScrollAware: true,
        ),
        child: SheetContentScaffold(
            requiredMinExtentForStickyBottomBar: const Extent.proportional(0.5),
            appBar: AppBar(
              title: Text("Filter by"),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(right: 32),
                    //   child: Text(
                    //     'Confirm your choices',
                    //   ),
                    // ),
                    // const SizedBox(height: 24),
                    ListTile(
                      title: const Text('Project Length'),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(right: 32),
                    //   child: Wrap(
                    //     spacing: 10,
                    //     children: [
                    //       for (final genre in _genres.take(5))
                    //         FilterChip(
                    //           selected: true,
                    //           label: Text(genre),
                    //           onSelected: (_) {},
                    //         ),
                    //     ],
                    //   ),
                    // ),
                    // const Divider(height: 32),
                    // ListTile(
                    //   title: const Text('Mood'),
                    //   // trailing: IconButton(
                    //   //   onPressed: () => context.go('/intro/genre/mood'),
                    //   //   icon: const Icon(Icons.edit_outlined),
                    //   // ),
                    // ),
                    RadioListTile(
                      title: Text("Less than one month"),
                      // secondary: Text(
                      //   _moods.first.emoji,
                      //   style: const TextStyle(fontSize: 24),
                      // ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: '',
                      groupValue: '',
                      onChanged: (_) {},
                    ),
                    RadioListTile(
                      title: Text("1 to 3 months"),
                      // secondary: Text(
                      //   _moods.first.emoji,
                      //   style: const TextStyle(fontSize: 24),
                      // ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: null,
                      groupValue: '',
                      onChanged: (_) {},
                    ),
                    RadioListTile(
                      title: Text("3 to 6 months"),
                      // secondary: Text(
                      //   _moods.first.emoji,
                      //   style: const TextStyle(fontSize: 24),
                      // ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: null,
                      groupValue: '',
                      onChanged: (_) {},
                    ),
                    RadioListTile(
                      title: Text("More than 6 months"),
                      // secondary: Text(
                      //   _moods.first.emoji,
                      //   style: const TextStyle(fontSize: 24),
                      // ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: '',
                      groupValue: null,
                      onChanged: (_) {},
                    ),
                    const Divider(height: 32),
                    // ListTile(
                    //   title: const Text('Seed tracks'),
                    //   trailing: IconButton(
                    //     onPressed: () =>
                    //         context.go('/intro/genre/mood/seed-track'),
                    //     icon: const Icon(Icons.edit_outlined),
                    //   ),
                    // ),
                    TextField(
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        labelText: "Students needed",
                      ),
                    ),
                    const Divider(height: 32),
                    TextField(
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        labelText: "Proposal less than",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomBar: BottomAppBar(
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
                      onPressed: () {},
                      buttonText: "Clear filter",
                    ),
                    const SizedBox(width: 12),
                    RoundedButtonWidget(
                      buttonColor: Theme.of(context).colorScheme.primary,
                      onPressed: () {},
                      buttonText: "Apply",
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet(
      {required this.onSheetDismissed,
      this.height = 750,
      required this.onFilterTap,
      required this.searchList});
  final onSheetDismissed;
  final onFilterTap;
  final double height;
  final List<Project> searchList;

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  TextEditingController controller = TextEditingController();
  bool isSuggestionTapped = true;

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
                  height: MediaQuery.of(context).size.height * 0.85,
                  list: widget.searchList,
                  firstCallback: (i) {
                    setState(() {
                      allProjects[i].isFavorite = !allProjects[i].isFavorite!;
                    });
                  },
                )
              : null,
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
          const SheetKeyboardDismissBehavior.onDrag(isContentScrollAware: true),
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
      title: AnimSearchBar2(
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
        // initialText:
        // readOnly:
        // TODO:
        searchTextEditingController: controller,
        onSuggestionCallback: (pattern) {
          if (pattern.isEmpty) return [];
          return Future<List<Project>>.delayed(
            const Duration(milliseconds: 300),
            () => allProjects.where((product) {
              final nameLower = product.title.toLowerCase().split(' ').join('');
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
  const ProjectTab({super.key});

  @override
  State<ProjectTab> createState() => _ProjectTabState();
}

class _ProjectTabState extends State<ProjectTab> {
  @override
  Widget build(BuildContext context) {
    return _buildProjectContent();
  }

  Future<SearchBottomSheet?> showTodoEditor(BuildContext context) {
    return Navigator.push(
      context,
      ModalSheetRoute(
        builder: (context) => _ConfirmPage(),
      ),
    );
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
                    onSubmitted: (value) {
                      setState(() {
                        if (yOffset == MediaQuery.of(context).size.height) {
                          NavbarNotifier2.hideBottomNavBar = true;
                          yOffset =
                              -(MediaQuery.of(context).size.height) * 0.05 + 45;
                        } else {}
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for projects',
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search,
                            size: 35, color: Colors.black.withOpacity(.7)),
                        onPressed: () {
                          setState(() {
                            if (yOffset == MediaQuery.of(context).size.height) {
                              NavbarNotifier2.hideBottomNavBar = true;
                              yOffset =
                                  -(MediaQuery.of(context).size.height) * 0.05 +
                                      45;
                            } else {
                              NavbarNotifier2.hideBottomNavBar = false;
                              yOffset = MediaQuery.of(context).size.height;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      NavbarNotifier2.pushNamed(Routes.favortie_project,
                          NavbarNotifier2.currentIndex, null);
                    },
                    color: Theme.of(context).colorScheme.primary,
                    icon: const Icon(Icons.favorite_rounded))
              ],
            )),
        // Flexible(
        //   child: ListView.builder(
        //     itemCount: allProjects.length,
        //     itemBuilder: (context, index) => ProjectItem(
        //       project: allProjects[index],
        //       isFavorite: index % 2 == 0 ? true : false,
        //     ),
        //   ),
        // ),
        SizedBox(
          height: 100,
        ),
        Container(
          margin: EdgeInsets.only(top: 40),
          child: ExampleUiLoadingAnimation(
            height: MediaQuery.of(context).size.height - 60,
            list: allProjects,
            firstCallback: (i) {
              setState(() {
                allProjects[i].isFavorite = !allProjects[i].isFavorite!;
              });
            },
          ),
        ),
        AnimatedContainer(
            curve: Easing.legacyAccelerate,
            color: Colors.black.withOpacity(0.5),

            // color: Colors.amber,
            alignment: Alignment.bottomCenter,
            duration: Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, yOffset, -1.0),
            child: SearchBottomSheet(
              searchList: allProjects
                  .where((e) =>
                      keyword.isNotEmpty &&
                      e.title.toLowerCase().contains(keyword.toLowerCase()))
                  .toList(),
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
              onFilterTap: () async {
                await showTodoEditor(context);
              },
            )),
      ],
    );
  }
}
