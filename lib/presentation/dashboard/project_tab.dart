import 'dart:math';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/core/widgets/loading_list.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/searchbar_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/presentation/dashboard/components/project_item.dart';
import 'package:boilerplate/presentation/dashboard/favorite_project.dart';
import 'package:boilerplate/presentation/dashboard/store/project_form_store.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'dart:async';

import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:toastification/toastification.dart';

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
    return "${scope != null ? scope!.title : ""}${studentNeeded != null ? "\nLess than $studentNeeded students needed" : ""}${proposalLessThan != null ? "\nProposal less than $proposalLessThan" : ""}";
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
    groupValue = widget.filter.scope;
    studentNeededController.text =
        (widget.filter.studentNeeded ?? "").toString();
    proposalLessThanController.text =
        (widget.filter.proposalLessThan ?? "").toString();
  }

  @override
  Widget build(BuildContext context) {
    return SheetDismissible(
      child: ScrollableSheet(
          keyboardDismissBehavior:
              const SheetKeyboardDismissBehavior.onDragDown(
            isContentScrollAware: true,
          ),
          child: Container(
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SheetContentScaffold(
                appBar: AppBar(
                  title: Text(
                    Lang.get("filter_title"),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SingleChildScrollView(
                    controller: ScrollController(),
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
                        RadioListTile<Scope?>(
                          title: const Text("Any scope"),
                          // secondary: Text(
                          //   _moods.first.emoji,
                          //   style:  TextStyle(fontSize: 24),
                          // ),
                          controlAffinity: ListTileControlAffinity.trailing,
                          value: null,
                          groupValue: groupValue,
                          onChanged: (s) {
                            setState(() {
                              widget.filter.scope = s;
                              groupValue = s;
                            });
                          },
                        ),
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
                            widget.filter.studentNeeded =
                                int.tryParse(value) ?? 2;
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
                          setState(() {
                            widget.filter.clear();
                            groupValue = null;
                            studentNeededController.clear();
                            proposalLessThanController.clear();
                          });
                        },
                        buttonText: Lang.get("clear_filter"),
                      ),
                      const SizedBox(width: 12),
                      RoundedButtonWidget(
                        buttonColor: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          NavbarNotifier2.popRoute(
                              NavbarNotifier2.currentIndex);
                        },
                        buttonText: Lang.get("apply"),
                      ),
                    ],
                  ),
                )),
          )),
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
      this.filter,
      required this.favoriteCallback,
      required this.stopLoadingCallback});
  final onSheetDismissed;
  final onFilterTap;
  final double height;
  final List<Project> searchList;
  final String? keyword;
  final SearchFilter? filter;
  final Function favoriteCallback;
  final Function(String? id) stopLoadingCallback;

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

  GlobalKey<RefazynistState> refazynistKey = GlobalKey();

  int lazyCount = 5;

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
            child: widget.searchList.isNotEmpty
                ? Refazynist(
                    setStateCallback: () => {},
                    scrollExtent: 30,
                    loaderBuilder: (bContext, bAnimation) {
                      return const LoadingScreenWidget();
                    },
                    scrollController: ScrollController(),
                    key: refazynistKey,
                    sharedPreferencesName: "",
                    onInit: () async {
                      Future.delayed(const Duration(seconds: 1), () {
                        refazynistKey.currentState!.refresh();
                      });
                      return widget.searchList.sublist(
                          0, lazyCount.clamp(0, widget.searchList.length));
                    },
                    emptyBuilder: (ewContext) {
                      return Stack(
                        children: <Widget>[
                          Center(child: Text(Lang.get("nothing_here"))),
                        ],
                      );
                    },

                    //
                    // Refazynist: It's for refresh

                    onRefresh: () async {
                      lazyCount = 5;
                      // await _projectStore.getAllProject();

                      return widget.searchList.sublist(
                          0, lazyCount.clamp(0, widget.searchList.length));
                    },

                    //
                    // Refazynist: It's for lazy load

                    onLazy: () async {
                      lazyCount += 5;
                      List<Project> lazyList = [];
                      if (refazynistKey.currentState!.length() ==
                          widget.searchList.length) {
                        return [];
                      }

                      lazyList.addAll(widget.searchList.sublist(
                          min(refazynistKey.currentState!.length(),
                              widget.searchList.length),
                          (refazynistKey.currentState!.length() + 5)
                              .clamp(0, widget.searchList.length)));
                      await Future.delayed(
                          const Duration(seconds: 1)); // Fake internet delay
                      return lazyList;
                    },

                    //
                    // Refazynist: itemBuilder

                    itemBuilder: (item, ibContext, index, animation, type) {
                      return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Interval(
                                  0,
                                  max(
                                      0,
                                      (Random().nextDouble() + 0.1)
                                          .clamp(0, 1)),
                                  curve: Curves.fastOutSlowIn))),
                          // opacity: animation,
                          child: ProjectItem2(
                              keyword: widget.keyword,
                              loadingDelay: index,
                              stopLoading: (id) {
                                widget.stopLoadingCallback(id);
                              },
                              project: item,
                              onFavoriteTap: (id) {
                                widget.favoriteCallback(id);
                                // var p = (widget.searchList).firstWhereOrNull(
                                //   (element) => element.objectId == id,
                                // );
                                // setState(() {
                                //   p?.isFavorite = p.isFavorite;
                                // });
                                // _projectStore.projects[i].isFavorite =
                                //     !_projectStore.projects[i].isFavorite;
                              }));
                    },

                    //
                    // Refazynist: removed ItemBuilder (need for Flutter's Animated List)

                    removedItemBuilder:
                        (item, ibContext, index, animation, type) {
                      return FadeTransition(
                          opacity: animation,
                          child: ProjectItem2(
                              keyword: widget.keyword,
                              project: item,
                              loadingDelay: index,
                              stopLoading: (id) {
                                widget.stopLoadingCallback(id);
                              },
                              onFavoriteTap: (id) {
                                widget.favoriteCallback(id);
                                // var p = (widget.searchList).firstWhereOrNull(
                                //   (element) => element.objectId == id,
                                // );
                                // setState(() {
                                //   p?.isFavorite = !p.isFavorite;
                                // });
                                // // _projectStore.projects[i].isFavorite =
                                //     !_projectStore.projects[i].isFavorite;
                              }));
                    })
                // LazyLoadingAnimationProjectList(
                //     scrollController: ScrollController(),
                //     itemHeight: MediaQuery.of(context).size.height * 0.3,
                //     list: widget.searchList,
                //     skipItemLoading: true,
                //     firstCallback: (id) {
                //       widget.favoriteCallback(id);
                //     },
                //   )
                : Center(child: Text(Lang.get("nothing_here"))),
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
              "Result: ${widget.searchList.length} Filter: ${widget.filter!}",
              maxLines: 3,
              minFontSize: 12,
            )
          : const SizedBox(),
      titleTextStyle:
          Theme.of(context).textTheme.titleSmall!.merge(const TextStyle(
                fontWeight: FontWeight.w700,
              )),
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
  if (f.scope != null) {
    b &= f.scope == p.scope;
  }
  if (f.studentNeeded != null) {
    b &= p.numberOfStudents <= f.studentNeeded!;
  }
  if (f.proposalLessThan != null) {
    b &= p.countProposals <= f.proposalLessThan!;
  }
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
  final ProjectStore _projectStore = getIt<ProjectStore>();
  final ProjectFormStore _projectFormStore = getIt<ProjectFormStore>();
  final UserStore _userStore = getIt<UserStore>();
  double yOffset = 0;
  String keyword = "";
  TextEditingController controller = TextEditingController();
  Set<String> searchHistory = {};
  late Future<ProjectList> future;
  int resultLenght = 0;

  @override
  void initState() {
    super.initState();
    print(_projectStore.projects);
    loadSearchHistory().then(
      (value) => searchHistory = value,
    );
    future = _projectStore.getAllProject(refazynistKey, setStateCallback: () {
      try {
        Toastify.show(
            context, "", "Finish loading", ToastificationType.success, () {});
        setState(() {
          var l = _projectStore.projects
              .map(
                (e) => e.companyId,
              )
              .toSet()
              .toList();
          l.insert(0, "");
          l.sort(
            (a, b) => a.compareTo(b),
          );
          _list = l;
        });
      } catch (e) {
        ///
      }
    });
    Toastify.show(
        context, "", "Loading project...", ToastificationType.info, () {});
  }

  // ignore: prefer_final_fields
  List<String> _list = [""];
  String keywordId = "";

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

  List<Project> getSearchList() {
    var list = keyword.isEmpty
        ? _projectStore.projects
            .where(
              (element) => applyFilter(filter, element),
            )
            .toList()
        : _projectStore.projects
            .where((e) =>
                (e.title.trim().toLowerCase().contains(keyword.toLowerCase()) ||
                    e.description
                        .trim()
                        .toLowerCase()
                        .contains(keyword.toLowerCase())) &&
                applyFilter(filter, e))
            .toList();
    if (filter.scope != null) {
      list.sort((a, b) => b.scope.index.compareTo(a.scope.index));
    }
    if (filter.studentNeeded != null) {
      list.sort((a, b) => b.numberOfStudents.compareTo(a.numberOfStudents));
    }
    if (filter.proposalLessThan != null) {
      list.sort((a, b) => b.countProposals.compareTo(a.countProposals));
    }
    return list;
  }

  Future<SearchBottomSheet?> showSearchBottomSheet(BuildContext context) async {
    return await NavbarNotifier2.push(
      NavbarNotifier2.currentIndex,
      context,
      ModalSheetRoute(
        builder: (context) => SearchBottomSheet(
          stopLoadingCallback: (id) {
            stopLoading(id!);
          },
          favoriteCallback: (id) {
            for (int i = 0; i < _projectStore.projects.length; i++) {
              if (_projectStore.projects[i].objectId == id) {
                _projectStore.projects[i].isFavorite =
                    !_projectStore.projects[i].isFavorite;
                _projectFormStore
                    .updateFavoriteProject(
                        _userStore.user!.studentProfile!.objectId ?? "",
                        id,
                        _projectStore.projects[i].isFavorite)
                    .then((value) {
                  if (value) {
                    _projectStore.updateInFav(_projectStore.projects[i]);
                  }
                });
              }
            }
          },
          filter: filter,
          keyword: keyword.isNotEmpty ? keyword : null,
          searchList: getSearchList(),
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

  GlobalKey<RefazynistState> refazynistKey = GlobalKey();

  int lazyCount = 5; // It's for lazy loading limit
  Widget _buildProjectContent() {
    resultLenght = _projectStore.projects.length;
    if (yOffset == 0) {
      yOffset = MediaQuery.of(context).size.height;
    }
    if (_list.isEmpty) {
      var l = _projectStore.projects
          .map(
            (e) => e.companyId,
          )
          .toSet()
          .toList();
      l.insert(0, "");
      l.sort(
        (a, b) => a.compareTo(b),
      );
      _list = l;
    }
    return Stack(
      // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
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
                      // yOffset =
                      //     -(MediaQuery.of(context).size.height) * 0.05 + 45;
                      if (p0.trim().isNotEmpty) searchHistory.add(p0.trim());
                      saveSearchHistory(searchHistory);
                    });
                    await showSearchBottomSheet(context);
                  },
                  width: MediaQuery.of(context).size.width,
                  textController: controller,
                  onSuffixTap: () {},
                  onSelected: (project) async {
                    setState(() {
                      keyword = project;
                      NavbarNotifier2.hideBottomNavBar = true;
                      // yOffset =
                      //     -(MediaQuery.of(context).size.height) * 0.05 + 45;
                    });
                    if (project.trim().isNotEmpty) {
                      searchHistory.add(project.trim());
                    }
                    saveSearchHistory(searchHistory);
                    await showSearchBottomSheet(context);
                  },
                  // initialText:
                  // readOnly:
                  searchTextEditingController: controller,
                  onSuggestionCallback: (pattern) {
                    if (pattern.isEmpty) return searchHistory.toList();
                    return Future<List<String>>.delayed(
                      const Duration(milliseconds: 300),
                      () =>
                          // _projectStore.projects.where((product) {
                          //   final nameLower =
                          //       product.title.toLowerCase().split(' ').join('');
                          //   //print(nameLower);
                          //   final patternLower =
                          //       pattern.toLowerCase().split(' ').join('');
                          //   return nameLower.contains(patternLower);
                          // }).toList(),
                          searchHistory.where(
                        (element) {
                          return element
                              .trim()
                              .contains(controller.text.trim());
                        },
                      ).toList(),
                    );
                  },
                  suggestionItemBuilder: (context, project) => ListTile(
                    title: Text(project),
                    contentPadding: const EdgeInsets.only(left: 5),
                    trailing: IconButton(
                      tooltip: "Clear text",
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          searchHistory.remove(project);
                        });
                        saveSearchHistory(searchHistory);
                      },
                    ),
                    // subtitle: Text(project.description),
                  ),
                ),
                Positioned(
                  right: 35,
                  child: IconButton(
                      tooltip: "Filter",
                      onPressed: () async {
                        setState(() {
                          NavbarNotifier2.hideBottomNavBar = true;
                          // yOffset =
                          // -(MediaQuery.of(context).size.height) * 0.05 + 45;
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
                  right: 70,
                  child: IconButton(
                      tooltip: "Favorite",
                      onPressed: () {
                        NavbarNotifier2.pushNamed(
                            Routes.favoriteProject,
                            NavbarNotifier2.currentIndex,
                            FavoriteScreen(
                                projectList: _projectStore.projects
                                    .where((element) => element.isFavorite)
                                    .toList(),
                                onFavoriteTap: (String id) {
                                  var p =
                                      _projectStore.projects.firstWhereOrNull(
                                    (element) => element.objectId == id,
                                  );
                                  if (p != null) p.isFavorite = !p.isFavorite;
                                }));
                      },
                      color: Theme.of(context).colorScheme.primary,
                      icon: const Icon(Icons.bookmark)),
                ),
              ],
            )),
        // Flexible(
        //   child: ListView.builder(
        //     itemCount: _projectStore.projects.length,
        //     itemBuilder: (context, index) => ProjectItem(
        //       project: _projectStore.projects[index],
        //       isFavorite: index % 2 == 0 ? true : false,
        //     ),
        //   ),
        // ),
        const SizedBox(
          height: 100,
        ),
        Container(
          margin: const EdgeInsets.only(top: 65, left: 5),
          child: Text("${Lang.get("result")} $resultLenght"),
        ),
        Positioned(
          right: 0,
          top: 55,
          width: 150,
          child: CustomDropdown<String>.searchRequest(
            futureRequest: (p0) {
              var l = _projectStore.projects
                  .map(
                    (e) => e.companyId,
                  )
                  .toSet()
                  .toList();
              l.insert(0, "");
              l.sort(
                (a, b) => a.compareTo(b),
              );
              _list = l;
              return Future.value(_list);
            },
            hideSelectedFieldWhenExpanded: false,
            closedHeaderPadding: const EdgeInsets.only(left: 40),
            decoration: const CustomDropdownDecoration(
                closedFillColor: Colors.transparent),
            initialItem: _list[0],
            onChanged: (p0) {
              setState(() {
                keywordId = p0;
              });
              if (refazynistKey.currentState != null) {
                refazynistKey.currentState!.refresh();
              }
              setState(() {});
            },
            noResultFoundText: Lang.get("nothing_here"),
            maxlines: 3,
            hintText: "Company id",
            items: _list,
            headerBuilder: (context, selectedItem) => Text(
                (_userStore.user != null &&
                            _userStore.user!.companyProfile != null &&
                            _userStore.user!.companyProfile!.objectId ==
                                selectedItem
                        ? "(You) "
                        : "") +
                    selectedItem),
            listItemBuilder: (context, item, isSelected, onItemSelect) {
              return SizedBox(
                height: 30,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon(item.icon),
                    // const SizedBox(
                    //   width: 20,
                    // ),
                    Text(
                      (_userStore.companyId == item ? "(You) " : "") + item,
                      style: isSelected
                          ? const TextStyle(fontWeight: FontWeight.bold)
                          : null,
                      textAlign: TextAlign.start,
                    ),
                    // const Spacer(),
                    // Checkbox(
                    //   value: isSelected,
                    //   onChanged: (value) => value = isSelected,
                    // )
                  ],
                ),
              );
            },
          ),
        ),

        Container(
            margin: const EdgeInsets.only(top: 100),
            child: FutureBuilder<ProjectList>(
              future: future,
              builder:
                  (BuildContext context, AsyncSnapshot<ProjectList> snapshot) {
                Widget children;
                if (snapshot.hasData) {
                  children = Refazynist(
                      setStateCallback: () => setState(() {}),
                      loaderBuilder: (bContext, bAnimation) {
                        return const LoadingScreenWidget();
                      },
                      scrollController: widget.scrollController,
                      key: refazynistKey,
                      sharedPreferencesName: Preferences.all_project,
                      onInit: () async {
                        if (snapshot.data!.projects == null) return [];
                        var p = getProjectWithKeyword(snapshot.data!.projects!);

                        return p.sublist(
                            0,
                            lazyCount.clamp(
                                0, snapshot.data!.projects!.length));
                      },
                      emptyBuilder: (ewContext) {
                        return Stack(
                          children: <Widget>[
                            Center(child: Text(Lang.get("nothing_here"))),
                          ],
                        );
                      },

                      //
                      // Refazynist: It's for refresh

                      onRefresh: () async {
                        lazyCount = 5;

                        if (keywordId.isEmpty) {
                          print("on refesshh");
                          _projectStore.getAllProject(refazynistKey,
                              setStateCallback: () {
                            Toastify.show(context, "", "Finish loading",
                                ToastificationType.success, () {});
                            setState(() {
                              var l = _projectStore.projects
                                  .map(
                                    (e) => e.companyId,
                                  )
                                  .toSet()
                                  .toList();
                              l.insert(0, "");
                              l.sort(
                                (a, b) => a.compareTo(b),
                              );
                              _list = l;
                            });
                          });
                        }
                        var p = getProjectWithKeyword(_projectStore.projects);
                        p.sort(
                          (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
                        );
                        return p.sublist(0, lazyCount.clamp(0, p.length));
                      },

                      //
                      // Refazynist: It's for lazy load

                      onLazy: () async {
                        // if (_projectStore.postSuccess) return [];
                        lazyCount += 5;
                        List<Project> lazyList = [];
                        if (refazynistKey.currentState!.length() ==
                            _projectStore.projects.length) {
                          return [];
                        }

                        var p = getProjectWithKeyword(_projectStore.projects);
                        lazyList.addAll(p.sublist(
                            min(refazynistKey.currentState!.length(), p.length),
                            (refazynistKey.currentState!.length() + 5)
                                .clamp(0, p.length)));

                        await Future.delayed(const Duration(
                            milliseconds: 500)); // Fake internet delay
                        return lazyList;
                      },

                      //
                      // Refazynist: itemBuilder

                      itemBuilder: (item, ibContext, index, animation, type) {
                        return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Interval(
                                    0,
                                    max(
                                        0,
                                        (Random().nextDouble() + 0.1)
                                            .clamp(0, 1)),
                                    curve: Curves.fastOutSlowIn))),
                            // opacity: animation,
                            child: ProjectItem2(
                                loadingDelay: index,
                                project: item,
                                stopLoading: (id) {
                                  stopLoading(id);
                                },
                                onFavoriteTap: (id) {
                                  favoriteTap(id);
                                }));
                      },

                      //
                      // Refazynist: removed ItemBuilder (need for Flutter's Animated List)

                      removedItemBuilder:
                          (item, ibContext, index, animation, type) {
                        return FadeTransition(
                            opacity: animation,
                            child: ProjectItem2(
                                loadingDelay: index,
                                project: item,
                                stopLoading: (id) {
                                  stopLoading(id);
                                },
                                onFavoriteTap: (id) {
                                  favoriteTap(id);
                                }));
                      });
                } else if (snapshot.hasError) {
                  children = Center(child: Text(Lang.get("nothing_here")));
                } else {
                  print("loading");
                  children = const LoadingScreenWidget();
                }
                return children;
              },
            )),
      ],
    );
  }

  favoriteTap(String id) {
    setState(() {
      var p = (_projectStore.projects).firstWhereOrNull(
        (element) => element.objectId == id,
      );
      if (p != null) {
        _projectFormStore
            .updateFavoriteProject(
                _userStore.user!.studentProfile!.objectId ?? "",
                id,
                !p.isFavorite)
            .then((value) {
          if (value) {
            _projectStore.updateInFav(p);
          }
        });
      }
      setState(() {
        p?.isFavorite = !p.isFavorite;
      });
      // _projectStore.projects[i].isFavorite =
      //     !_projectStore.projects[i].isFavorite;
    });
  }

  stopLoading(String id) {
    var p = (_projectStore.projects).firstWhereOrNull(
      (element) => element.objectId == id,
    );
    setState(() {
      setState(() {
        p?.isLoading = false;
      });
    });
  }

  List<Project> getProjectWithKeyword(List<Project> projects) {
    if (keywordId.isEmpty) return projects;
    return projects
        .where(
          (element) => element.companyId == keywordId,
        )
        .toList();
  }
}
