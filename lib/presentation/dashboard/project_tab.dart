import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/core/widgets/lazy_loading_card.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/searchbar_widget.dart';
import 'package:boilerplate/domain/entity/project/mockData.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/favorite_project.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

import 'dart:async';

import 'package:smooth_sheets/smooth_sheets.dart';

class SearchFilter {
  Scope? scope;
  int? studentNeeded;
  int? proposalLessThan;

  SearchFilter({this.scope, this.studentNeeded, this.proposalLessThan});

  clear() {
    scope = null;
    studentNeeded = null;
    proposalLessThan = null;
  }

  @override
  String toString() {
    return "${scope != null ? scope!.title : ""}${studentNeeded != null ? "\n$studentNeeded students needed" : ""}${proposalLessThan != null ? "\nProposal less than $proposalLessThan" : ""}";
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({required this.filter});
  final SearchFilter filter;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  Scope? groupValue;
  TextEditingController studentNeededController = TextEditingController();
  TextEditingController proposalLessThanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    groupValue = widget.filter.scope ?? Scope.tight;
    studentNeededController.text =
        (widget.filter.studentNeeded ?? "").toString();
    proposalLessThanController.text =
        (widget.filter.proposalLessThan ?? "").toString();
  }

  @override
  Widget build(BuildContext context) {
    return SheetDismissible(
      child: ScrollableSheet(
        keyboardDismissBehavior: const SheetKeyboardDismissBehavior.onDragDown(
          isContentScrollAware: true,
        ),
        child: SheetContentScaffold(
            appBar: AppBar(
              title: Text(Lang.get("filter_title")),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Padding(
                    //   padding:  EdgeInsets.only(right: 32),
                    //   child: Text(
                    //     'Confirm your choices',
                    //   ),
                    // ),
                    //  SizedBox(height: 24),
                    ListTile(
                      title: Text(Lang.get('project_length')),
                    ),
                    // Padding(
                    //   padding:  EdgeInsets.only(right: 32),
                    //   child: Wrap(
                    //     spacing: 10,
                    //     children: [
                    //       for (final genre in _genres.take(5))
                    //         FilterChip(
                    //           selected: true,
                    //           label: Text(genre),
                    //           onSelected: () {},
                    //         ),
                    //     ],
                    //   ),
                    // ),
                    //  Divider(height: 32),
                    // ListTile(
                    //   title:  Text(Lang.get('Mood'),
                    //   // trailing: IconButton(
                    //   //   onPressed: () => context.go('/intro/genre/mood'),
                    //   //   icon:  Icon(Icons.edit_outlined),
                    //   // ),
                    // ),
                    RadioListTile<Scope>(
                      title: Text(Lang.get("0-1")),
                      // secondary: Text(
                      //   _moods.first.emoji,
                      //   style:  TextStyle(fontSize: 24),
                      // ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: Scope.tight,
                      groupValue: groupValue,
                      onChanged: (s) {
                        setState(() {
                          widget.filter.scope = s;
                          groupValue = s;
                        });
                      },
                    ),
                    RadioListTile<Scope>(
                      title: Text(Lang.get("1-3")),
                      // secondary: Text(
                      //   _moods.first.emoji,
                      //   style:  TextStyle(fontSize: 24),
                      // ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: Scope.short,
                      groupValue: groupValue,
                      onChanged: (s) {
                        setState(() {
                          widget.filter.scope = s;
                          groupValue = s;
                        });
                      },
                    ),
                    RadioListTile<Scope>(
                      title: Text(Lang.get('3-6')),
                      // secondary: Text(
                      //   _moods.first.emoji,
                      //   style:  TextStyle(fontSize: 24),
                      // ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: Scope.long,
                      groupValue: groupValue,
                      onChanged: (s) {
                        setState(() {
                          widget.filter.scope = s;
                          groupValue = s;
                        });
                      },
                    ),
                    RadioListTile<Scope>(
                      title: Text(Lang.get('6-')),
                      // secondary: Text(
                      //   _moods.first.emoji,
                      //   style:  TextStyle(fontSize: 24),
                      // ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: Scope.extended,
                      groupValue: groupValue,
                      onChanged: (s) {
                        setState(() {
                          widget.filter.scope = s;
                          groupValue = s;
                        });
                      },
                    ),
                    const Divider(height: 32),
                    // ListTile(
                    //   title:  Text(Lang.get('Seed tracks'),
                    //   trailing: IconButton(
                    //     onPressed: () =>
                    //         context.go('/intro/genre/mood/seed-track'),
                    //     icon:  Icon(Icons.edit_outlined),
                    //   ),
                    // ),
                    TextField(
                      controller: studentNeededController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: Lang.get("nothing_here"),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        labelText: Lang.get("student_needed"),
                      ),
                      onChanged: (value) {
                        widget.filter.studentNeeded = int.tryParse(value) ?? 2;
                      },
                    ),
                    const Divider(height: 32),
                    TextField(
                      controller: proposalLessThanController,
                      decoration: InputDecoration(
                        hintText: Lang.get("nothing_here"),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        labelText: Lang.get("proposal_less_than"),
                      ),
                      onChanged: (value) {
                        widget.filter.proposalLessThan =
                            int.tryParse(value) ?? 0;
                      },
                    ),
                  ],
                ),
              ),
            ),
            bottomBar: StickyBottomBarVisibility(
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
                  //     child:  Text(Lang.get('Cancel'),
                  //   ),
                  // ),
                  //  SizedBox(width: 16),
                  RoundedButtonWidget(
                    buttonColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      widget.filter.clear();
                    },
                    buttonText: Lang.get("clear_filter"),
                  ),
                  const SizedBox(width: 12),
                  RoundedButtonWidget(
                    buttonColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      NavbarNotifier2.popRoute(NavbarNotifier2.currentIndex);
                    },
                    buttonText: Lang.get("apply"),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet(
      {super.key,
      required this.onSheetDismissed,
      this.height = 650,
      required this.onFilterTap,
      required this.searchList,
      this.keyword,
      this.filter});
  final onSheetDismissed;
  final onFilterTap;
  final double height;
  final List<Project> searchList;
  final String? keyword;
  final SearchFilter? filter;

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  TextEditingController controller = TextEditingController();
  bool isSuggestionTapped = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.text = widget.keyword ?? "";

    // SheetContentScaffold is a special Scaffold designed for use in a sheet.
    // It has slots for an app bar and a sticky bottom bar, similar to Scaffold.
    // However, it differs in that its height reduces to fit the 'body' widget.
    final content = Container(
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SheetContentScaffold(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        // The bottom bar sticks to the bottom unless the sheet extent becomes
        // smaller than this threshold extent.
        // With the following configuration, the sheet height will be
        // 500px + (app bar height) + (bottom bar height).
        body: SizedBox(
          height: widget.height * 0.85,
          child: Align(
            alignment: Alignment.topCenter,
            child: isSuggestionTapped
                ? LazyLoadingAnimationProjectList(
                  scrollController: ScrollController(),
                    itemHeight: MediaQuery.of(context).size.height * 0.3,
                    list: widget.searchList,
                    skipItemLoading: true,
                    firstCallback: (id) {
                      setState(() {
                        for (int i = 0; i < allProjects.length; i++) {
                          if (allProjects[i].objectId == id) {
                            allProjects[i].isFavorite =
                                !allProjects[i].isFavorite;
                          }
                        }
                      });
                    },
                  )
                : null,
          ),
        ),
        appBar: buildAppBar(context),
        bottomBar: buildBottomBar(),
      ),
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
      // title:  Text(Lang.get('Search projects'),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      title: widget.filter != null
          ? AutoSizeText(
              "Filter: ${widget.filter!}",
              maxLines: 3,
              minFontSize: 12,
            )
          : const SizedBox(),
      titleTextStyle:
          Theme.of(context).textTheme.titleSmall!.merge(const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              )),

      // AnimSearchBar2(
      //   enabled: false,
      //   expandedByDefault: false,
      //   textFieldColor: Theme.of(context).colorScheme.surface,
      //   color: Theme.of(context).colorScheme.surface,
      //   onSubmitted: (p0) {},
      //   width: MediaQuery.of(context).size.width,
      //   textController: controller,
      //   onSuffixTap: () {},
      //   onSelected: (project) {
      //     // //print(project.title);
      //     // setState(() {
      //     //   isSuggestionTapped = true;
      //     // });
      //   },
      //   // initialText:
      //   // readOnly:
      //   searchTextEditingController: controller,
      //   onSuggestionCallback: (pattern) {
      //     // if (pattern.isEmpty) return [];
      //     // return Future<List<Project>>.delayed(
      //     //    Duration(milliseconds: 300),
      //     //   () => allProjects.where((product) {
      //     //     final nameLower = product.title.toLowerCase().split(' ').join('');
      //     //     //print(nameLower);
      //     //     final patternLower = pattern.toLowerCase().split(' ').join('');
      //     //     return nameLower.contains(patternLower);
      //     //   }).toList(),
      //     // );
      //     return [];
      //   },
      //   suggestionItemBuilder: (context, project) => ListTile(
      //     title: Text(project.title),
      //     subtitle: Text(project.description),
      //   ),
      // ),

      actions: const [
        // IconButton(
        //     onPressed: () {
        //       widget.onFilterTap();
        //     },
        //     icon: Icon(Icons.filter_alt_outlined))
      ],
    );
  }

  Widget buildBottomBar() {
    return StickyBottomBarVisibility(
      child: BottomAppBar(
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
              //     child:  Text(Lang.get('Cancel'),
              //   ),
              // ),
              //  SizedBox(width: 16),
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
      ),
    );
  }
}

bool applyFilter(SearchFilter f, Project p) {
  bool b = true;
  b &= (f.scope != null && f.scope! == p.scope) || (f.scope == null);
  b &= (f.studentNeeded != null && f.studentNeeded! == p.numberOfStudents) ||
      (f.studentNeeded == null);
  b &= (f.proposalLessThan != null &&
          (p.proposal != null && f.proposalLessThan! == p.proposal!.length)) ||
      (f.studentNeeded == null) ||
      (p.proposal == null);
  return b;
}

// ignore: must_be_immutable
class ProjectTab extends StatefulWidget {
  const ProjectTab({super.key, this.isAlive = true, this.scrollController});
  final bool? isAlive;
  final ScrollController? scrollController;

  @override
  State<ProjectTab> createState() => _ProjectTabState();
}

class _ProjectTabState extends State<ProjectTab> {
  SearchFilter filter = SearchFilter();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _buildProjectContent(),
    );
  }

  Future<SearchFilter?> showFilterBottomSheet(BuildContext context) async {
    return await NavbarNotifier2.push(
      NavbarNotifier2.currentIndex,
      context,
      ModalSheetRoute(
        builder: (context) => _FilterBottomSheet(
          filter: filter,
        ),
      ),
    ).then((value) {
      if (value != null) {
        return value;
      }
      //print(filter);
      return null;
    });
  }

  Future<SearchBottomSheet?> showSearchBottomSheet(BuildContext context) async {
    return await NavbarNotifier2.push(
      NavbarNotifier2.currentIndex,
      context,
      ModalSheetRoute(
        builder: (context) => SearchBottomSheet(
          filter: filter,
          keyword: keyword,
          searchList: allProjects
              .where((e) =>
                  keyword.isNotEmpty &&
                  e.title.toLowerCase().contains(keyword.toLowerCase()) &&
                  applyFilter(filter, e))
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
            NavbarNotifier2.popRoute(NavbarNotifier2.currentIndex);

            return true;
          },
          onFilterTap: () async {
            // await showFilterBottomSheet(context).then((value) {
            //   if (value != null) {
            //     setState(() {
            //       filter = value;
            //     });
            //     NavbarNotifier2.popRoute(Navigator.currentIndex);
            //   }
            // });
          },
        ),
      ),
    ).then((value) {
      setState(() {
        NavbarNotifier2.hideBottomNavBar = false;
        yOffset = MediaQuery.of(context).size.height;
      });
      FocusManager.instance.primaryFocus?.unfocus();
      return null;
    });
  }

  double yOffset = 0;
  String keyword = "";
  TextEditingController controller = TextEditingController();

  Widget _buildProjectContent() {
    if (yOffset == 0) {
      yOffset = MediaQuery.of(context).size.height;
    }
    return Stack(
      // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon:
              Icon(Icons.search, size: 35, color: Colors.black.withOpacity(.7)),
          onPressed: () {
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
        // Text(Lang.get('This is project page"),
        Align(
            alignment: Alignment.topRight,
            child: Stack(
              children: [
                AnimSearchBar2(
                  helpText: Lang.get("search"),
                  expandedByDefault: true,
                  textFieldColor: Theme.of(context).colorScheme.surface,
                  color: Theme.of(context).colorScheme.surface,
                  onSubmitted: (p0) async {
                    setState(() {
                      keyword = p0;
                      NavbarNotifier2.hideBottomNavBar = true;
                      yOffset =
                          -(MediaQuery.of(context).size.height) * 0.05 + 45;
                    });
                    await showSearchBottomSheet(context);
                  },
                  width: MediaQuery.of(context).size.width,
                  textController: controller,
                  onSuffixTap: () {},
                  onSelected: (project) async {
                    setState(() {
                      keyword = project.title;
                      NavbarNotifier2.hideBottomNavBar = true;
                      yOffset =
                          -(MediaQuery.of(context).size.height) * 0.05 + 45;
                    });
                    await showSearchBottomSheet(context);
                    // await showSearchBottomSheet(context);
                    // showModalBottomSheet(
                    //     isScrollControlled: true,
                    //     context: context,
                    //     builder: (context) {
                    //       return SearchBottomSheet(
                    //         filter: filter,
                    //         keyword: keyword,
                    //         searchList: allProjects
                    //             .where((e) =>
                    //                 keyword.isNotEmpty &&
                    //                 e.title
                    //                     .toLowerCase()
                    //                     .contains(keyword.toLowerCase()) &&
                    //                 applyFilter(filter, e))
                    //             .toList(),
                    //         onSheetDismissed: () {
                    //           setState(() {
                    //             Navigator.hideBottomNavBar = false;
                    //             yOffset = MediaQuery.of(context).size.height;
                    //           });
                    //           final FocusScopeNode currentScope =
                    //               FocusScope.of(context);
                    //           if (!currentScope.hasPrimaryFocus &&
                    //               currentScope.hasFocus) {
                    //             FocusManager.instance.primaryFocus?.unfocus();
                    //           }
                    //           Navigator.popRoute(
                    //               Navigator.currentIndex);
                    //           return true;
                    //         },
                    //         onFilterTap: () async {
                    //           // await showFilterBottomSheet(context).then((value) {
                    //           //   if (value != null) {
                    //           //     setState(() {
                    //           //       filter = value;
                    //           //     });
                    //           //     NavbarNotifier2.popRoute(Navigator.currentIndex);
                    //           //   }
                    //           // });
                    //         },
                    //       );
                    //     }).then((value) {
                    //   setState(() {
                    //     Navigator.hideBottomNavBar = false;
                    //     yOffset = MediaQuery.of(context).size.height;
                    //   });
                    //   FocusManager.instance.primaryFocus?.unfocus();
                    // });
                  },
                  // initialText:
                  // readOnly:
                  searchTextEditingController: controller,
                  onSuggestionCallback: (pattern) {
                    if (pattern.isEmpty) return [];
                    return Future<List<Project>>.delayed(
                      const Duration(milliseconds: 300),
                      () => allProjects.where((product) {
                        final nameLower =
                            product.title.toLowerCase().split(' ').join('');
                        //print(nameLower);
                        final patternLower =
                            pattern.toLowerCase().split(' ').join('');
                        return nameLower.contains(patternLower);
                      }).toList(),
                    );
                  },
                  suggestionItemBuilder: (context, project) => ListTile(
                    title: Text(project.title),
                    subtitle: Text(project.description),
                  ),
                ),
                Positioned(
                  right: 30,
                  child: IconButton(
                      onPressed: () async {
                        setState(() {
                          NavbarNotifier2.hideBottomNavBar = true;
                          yOffset =
                              -(MediaQuery.of(context).size.height) * 0.05 + 45;
                        });
                        await showFilterBottomSheet(context).then((value) {
                          NavbarNotifier2.hideBottomNavBar = false;
                          if (value != null) {
                            setState(() {
                              filter = value;
                            });
                            NavbarNotifier2.popRoute(
                                NavbarNotifier2.currentIndex);
                          }
                        });
                      },
                      icon: const Icon(Icons.filter_alt_outlined)),
                ),
                Positioned(
                  right: 60,
                  child: IconButton(
                      onPressed: () {
                        NavbarNotifier2.pushNamed(
                            Routes.favortieProject,
                            NavbarNotifier2.currentIndex,
                            FavoriteScreen(
                                projectList: allProjects
                                    .where((element) => element.isFavorite)
                                    .toList(),
                                onFavoriteTap: (int i) {
                                  allProjects[i].isFavorite =
                                      !allProjects[i].isFavorite;
                                }));
                      },
                      color: Theme.of(context).colorScheme.primary,
                      icon: const Icon(Icons.favorite_rounded)),
                ),
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
        const SizedBox(
          height: 100,
        ),
        Container(
          margin: const EdgeInsets.only(top: 50),
          child: LazyLoadingAnimationProjectList(
            scrollController: widget.scrollController,
            itemHeight: 230,
            list: allProjects,
            firstCallback: (i) {
              setState(() {
                allProjects[i].isFavorite = !allProjects[i].isFavorite;
              });
            },
          ),
        ),
        // AnimatedContainer(
        //     curve: Easing.legacyAccelerate,
        //     color: Colors.black.withOpacity(0.5),

        //     // color: Colors.amber,
        //     alignment: Alignment.bottomCenter,
        //     duration: Duration(milliseconds: 300),
        //     transform: Matrix4.translationValues(0, yOffset, -1.0),
        //     child: SearchBottomSheet(
        //       filter: filter,
        //       keyword: keyword,
        //       searchList: allProjects
        //           .where((e) =>
        //               keyword.isNotEmpty &&
        //               e.title.toLowerCase().contains(keyword.toLowerCase()))
        //           .toList(),
        //       onSheetDismissed: () {
        //         setState(() {
        //           Navigator.hideBottomNavBar = false;
        //           yOffset = MediaQuery.of(context).size.height;
        //         });
        //         final FocusScopeNode currentScope = FocusScope.of(context);
        //         if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
        //           FocusManager.instance.primaryFocus?.unfocus();
        //         }
        //         return true;
        //       },
        //       onFilterTap: () async {
        //         await showFilterBottomSheet(NavigationService.navigatorKey.currentContext ?? context);
        //       },
        //     )),
      ],
    );
  }
}
