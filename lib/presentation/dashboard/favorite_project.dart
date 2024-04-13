import 'dart:math';

import 'package:boilerplate/core/widgets/loading_list.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/presentation/dashboard/components/project_item.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen(
      {super.key, required this.projectList, this.onFavoriteTap});
  final List<Project> projectList;
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
  GlobalKey<RefazynistState> refazynistKey = GlobalKey();

  int lazyCount = 5;

  Widget _buildProjectContent() {
    if (yOffset == 0) {
      yOffset = MediaQuery.of(context).size.height;
    }
    return Stack(
      // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Text(Lang.get('This is project page"),
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
                      hintText: Lang.get('search'),
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
            child: FutureBuilder<ProjectList>(
              // TODO: get favorite project
              future: Future.value(ProjectList(projects: widget.projectList)),
              builder:
                  (BuildContext context, AsyncSnapshot<ProjectList> snapshot) {
                Widget children;
                if (snapshot.hasData) {
                  children = Refazynist(
                      loaderBuilder: (bContext, bAnimation) {
                        return const LoadingScreenWidget();
                      },
                      scrollController: ScrollController(),
                      key: refazynistKey,
                      sharedPreferencesName: "",
                      onInit: () async {
                        return snapshot.data!.projects != null
                            ? snapshot.data!.projects!.sublist(
                                0,
                                lazyCount.clamp(
                                    0, snapshot.data!.projects!.length))
                            : [];
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

                        return widget.projectList.sublist(0, lazyCount);
                      },

                      //
                      // Refazynist: It's for lazy load

                      onLazy: () async {
                        lazyCount += 5;
                        List<Project> lazyList = [];

                        lazyList.addAll(widget.projectList.sublist(
                            refazynistKey.currentState!.length(),
                            (refazynistKey.currentState!.length() + 5)
                                .clamp(0, widget.projectList.length)));

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
                                loadingDelay: index,
                                stopLoading: (id) {
                                  var p = (widget.projectList).firstWhereOrNull(
                                    (element) => element.objectId == id,
                                  );
                                  setState(() {
                                    setState(() {
                                      p?.isLoading = false;
                                    });
                                    // _projectStore.projects[i].isFavorite =
                                    //     !_projectStore.projects[i].isFavorite;
                                  });
                                },
                                project: item,
                                onFavoriteTap: (id) {
                                  var p = (widget.projectList).firstWhereOrNull(
                                    (element) => element.objectId == id,
                                  );
                                  setState(() {
                                    setState(() {
                                      p?.isFavorite = !p.isFavorite;
                                    });
                                    // _projectStore.projects[i].isFavorite =
                                    //     !_projectStore.projects[i].isFavorite;
                                  });
                                }));
                      },

                      //
                      // Refazynist: removed ItemBuilder (need for Flutter's Animated List)

                      removedItemBuilder:
                          (item, ibContext, index, animation, type) {
                        return FadeTransition(
                            opacity: animation,
                            child: ProjectItem2(
                                project: item,
                                stopLoading: (id) {
                                  var p = (widget.projectList).firstWhereOrNull(
                                    (element) => element.objectId == id,
                                  );
                                  setState(() {
                                    setState(() {
                                      p?.isLoading = false;
                                    });
                                    // _projectStore.projects[i].isFavorite =
                                    //     !_projectStore.projects[i].isFavorite;
                                  });
                                },
                                onFavoriteTap: (id) {
                                  if (widget.onFavoriteTap != null) {
                                    widget.onFavoriteTap!(id);
                                  }
                                  var p = (widget.projectList).firstWhereOrNull(
                                    (element) => element.objectId == id,
                                  );
                                  setState(() {
                                    p?.isFavorite = !p.isFavorite;
                                  });
                                  // _projectStore.projects[i].isFavorite =
                                  //     !_projectStore.projects[i].isFavorite;
                                }));
                      });

                  // LazyLoadingAnimationProjectList(
                  //   scrollController: ScrollController(),
                  //   skipItemLoading: true,
                  //   itemHeight: MediaQuery.of(context).size.height * 0.3,
                  //   list: widget.projectList ?? [],
                  //   firstCallback: (i) {
                  //     if (widget.projectList != null) {
                  //       if (widget.onFavoriteTap != null) {
                  //         widget.onFavoriteTap!(widget.projectList![i].objectId);
                  //       }
                  //       setState(() {
                  //         widget.projectList![i].isFavorite =
                  //             !widget.projectList![i].isFavorite;
                  //       });
                  //     }
                  //   },
                  // ),
                } else if (snapshot.hasError) {
                  children = Center(
                    child: Text(Lang.get("error")),
                  );
                } else {
                  print("loading");
                  children = Align(
                    alignment: Alignment.topCenter,
                    child: Lottie.asset(
                      'assets/animations/loading_animation.json', // Replace with the path to your Lottie JSON file
                      fit: BoxFit.cover,
                      width: 80, // Adjust the width and height as needed
                      height: 80,
                      repeat:
                          true, // Set to true if you want the animation to loop
                    ),
                  );
                }
                return children;
              },
            )),
      ],
    );
  }
}
