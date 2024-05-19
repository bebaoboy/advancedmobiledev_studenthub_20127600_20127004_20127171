// ignore_for_file: deprecated_member_use

import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/core/extensions/cap_extension.dart';
import 'package:boilerplate/core/widgets/open_container.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/dashboard/project_details.dart';
import 'package:boilerplate/presentation/dashboard/project_details_student_apply.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:timeago/timeago.dart' as timeago;

class SwipeToDismissWrap extends StatefulWidget {
  final Widget child;

  const SwipeToDismissWrap({super.key, required this.child});

  @override
  State<SwipeToDismissWrap> createState() => _SwipeToDismissWrapState();
}

class _SwipeToDismissWrapState extends State<SwipeToDismissWrap> {
  bool _swipeInProgress = false;
  late double _startPosX;

  final double _swipeStartAreaWidth = 120;
  final double _swipeMinLength = 100;
  bool dismiss = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        if (details.localPosition.dx < _swipeStartAreaWidth) {
          _swipeInProgress = true;
          _startPosX = details.localPosition.dx;
        }
      },
      onHorizontalDragUpdate: (details) {
        if (_swipeInProgress &&
            details.localPosition.dx > _startPosX + _swipeMinLength) {
          // HapticFeedback.mediumImpact();
          // Navigator.of(context).pop();
          if (!dismiss) {
            setState(() {
              dismiss = true;
            });
          }
        } else {
          if (dismiss) {
            setState(() {
              dismiss = false;
            });
          }
        }
      },
      onHorizontalDragEnd: (details) {
        if (dismiss) {
          HapticFeedback.mediumImpact();
          Navigator.of(context).pop();
        }
      },
      onVerticalDragDown: (_) => _swipeInProgress = dismiss = false,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: dismiss ? 0.8 : 0,
                      child: Container(
                        color: Colors.white,
                      )),
                  AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: dismiss ? 1 : 0,
                      child: const Center(
                        child: Text(
                          "Release to dismiss",
                          style: TextStyle(fontSize: 25),
                        ),
                      )),
                  AnimatedOpacity(
                      duration: const Duration(milliseconds: 100),
                      opacity: dismiss ? 1 : 0,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 18.0, left: 5),
                        child: Icon(
                          Icons.arrow_back,
                          size: 30,
                        ),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _OpenContainerWrapper extends StatelessWidget {
  _OpenContainerWrapper({
    required this.closedChild,
    required this.project,
  });

  final Widget closedChild;
  final Project project;
  final UserStore _userStore = getIt<UserStore>();

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      useRootNavigator: true,
      transitionDuration: const Duration(milliseconds: 500),
      openBuilder: (context, closedContainer) {
        if (_userStore.getCurrentType() == UserType.company) {
          return SwipeToDismissWrap(
            child: ProjectDetailsPage(
              project: project,
            ),
          );
        } else {
          return SwipeToDismissWrap(
            child: ProjectDetailsStudentApplyScreen(
              project: project,
            ),
          );
        }
      },
      routeSettings: RouteSettings(
          name:
              "${_userStore.getCurrentType() == UserType.company ? Routes.projectDetails : Routes.projectDetailsStudent}/${project.objectId}",
          arguments: {"project": project}),
      openColor: Theme.of(context).colorScheme.onBackground,
      openShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      closedElevation: 0,
      closedColor: Theme.of(context).colorScheme.onBackground,
      closedBuilder: (context, openContainer) {
        return Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black, width: 1.0),
                bottom: BorderSide(color: Colors.black, width: 1.0),
              ),
              // borderRadius: BorderRadius.all(Radius.circular(25))
            ),
            child: InkWell(
              onTap: () {
                if (project.isLoading) return;
                openContainer();
              },
              child: closedChild,
            ));
      },
    );
  }
}

class ProjectItem2 extends StatefulWidget {
  final Project project;

  final Function onFavoriteTap;
  final Function(String id) stopLoading;
  final int loadingDelay;
  final String? keyword;

  const ProjectItem2(
      {super.key,
      required this.project,
      required this.onFavoriteTap,
      required this.stopLoading,
      this.loadingDelay = 1,
      this.keyword});

  @override
  _ProjectItem2State createState() => _ProjectItem2State();
}

class _ProjectItem2State extends State<ProjectItem2> {
  final _languageStore = getIt<LanguageStore>();
  var createdText = '';
  var proposalText = 'Proposals: ';
  var updatedText = "";
  @override
  void initState() {
    super.initState();
    createdText = timeago
        .format(locale: _languageStore.locale, widget.project.timeCreated)
        .inCaps;

    if (widget.project.countProposals < 1) {
      proposalText += 'None';
    } else {
      proposalText += (widget.project.countProposals).toString();
    }
    if (widget.project.updatedAt != null &&
        widget.project.updatedAt! != widget.project.timeCreated &&
        widget.project.updatedAt!.day == DateTime.now().day) {
      updatedText =
          "Updated ${timeago.format(locale: _languageStore.locale, widget.project.updatedAt!.toLocal())}";
    } else if (widget.project.updatedAt != null) {
      updatedText = timeago
          .format(locale: _languageStore.locale, widget.project.updatedAt!)
          .inCaps;
    } else {
      updatedText = createdText;
    }
  }

  @override
  Widget build(BuildContext context) {
    var icon = widget.project.isFavorite
        ? const Icon(Icons.bookmark)
        : const Icon(Icons.bookmark_add_outlined);

    return _OpenContainerWrapper(
      project: widget.project,
      closedChild: LayoutBuilder(builder: (context, c) {
        return Skeletonizer(
            enabled: widget.project.isLoading,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(updatedText,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontSize: 12)),
                      AutoSizeText(
                        maxFontSize: 14,
                        words: widget.keyword != null
                            ? {
                                widget.keyword!: HighlightedWord(
                                  onTap: () {
                                    print("match");
                                  },
                                ),
                              }
                            : null,
                        matchDecoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        widget.project.title == ''
                            ? Lang.get('project_item_no_title')
                            : widget.project.title,
                        style: TextStyle(
                            color: Colors.green.shade400,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        Lang.get('project_item_description_header'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Flexible(
                        // height: 100,
                        child: AutoSizeText(
                          words: widget.keyword != null
                              ? {
                                  widget.keyword!: HighlightedWord(
                                    onTap: () {
                                      print("match");
                                    },
                                  ),
                                }
                              : null,
                          matchDecoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          widget.project.description == ''
                              ? Lang.get('project_item_blank')
                              : widget.project.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 4,
                          maxFontSize: 15,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        '${Lang.get('project_item_scope')} ${widget.project.scope.title}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${Lang.get('project_item_students')} ${widget.project.numberOfStudents}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        proposalText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 14.0),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        setState(() {
                          widget.onFavoriteTap(widget.project.objectId);
                        });
                      },
                      icon: icon,
                    ),
                  )
                ],
              ),
            ));
      }),
    );
  }
}
