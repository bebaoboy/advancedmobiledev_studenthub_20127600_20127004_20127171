// ignore_for_file: deprecated_member_use

import 'package:animations/animations.dart';
import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/core/extensions/cap_extension.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/dashboard/project_details.dart';
import 'package:boilerplate/presentation/dashboard/project_details_student_apply.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    final theme = Theme.of(context);
    return OpenContainer(
      useRootNavigator: true,
      transitionDuration: const Duration(milliseconds: 500),
      openBuilder: (context, closedContainer) {
        if (_userStore.getCurrentType() == UserType.company) {
          return ProjectDetailsPage(
            project: project,
          );
        } else {
          return ProjectDetailsStudentApplyScreen(
            project: project,
          );
        }
      },
      openColor: theme.cardColor,
      openShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      closedElevation: 0,
      closedColor: theme.cardColor,
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
                // Provider.of<EmailStore>(
                //   context,
                //   listen: false,
                // ).currentlySelectedEmailId = id;

                // ToDo: uncomment first line and comment second
                // this is for testing               
                if (project.isLoading) return;
                  openContainer();
              },
              child: closedChild,
            ));
      },
    );
  }
}

// class ProjectItem extends StatefulWidget {
//   final Project project;

//   final Function onFavoriteTap;
//   const ProjectItem(
//       {super.key, required this.project, required this.onFavoriteTap});

//   @override
//   _ProjectItemState createState() => _ProjectItemState();
// }

// class _ProjectItemState extends State<ProjectItem> {
//   final _languageStore = getIt<LanguageStore>();
//   var createdText = '';
//   var proposalText = 'Proposals: ';
//   var updatedText = "";
//   @override
//   void initState() {
//     super.initState();
//     // int differenceWithToday = widget.project.getModifiedTimeCreated();
//     // if (differenceWithToday == 0) {
//     //   createdText = Lang.get("created_now");
//     // } else if (differenceWithToday == 1) {
//     //   createdText = 'Created 1 day ago';
//     // } else {
//     //   createdText = 'Created $differenceWithToday${Lang.get('day_ago')}';
//     // }
//     createdText = timeago
//         .format(locale: _languageStore.locale, widget.project.timeCreated)
//         .inCaps;

//     if (widget.project.countProposals < 1) {
//       proposalText += 'None';
//     } else {
//       proposalText += widget.project.proposal!.length.toString();
//     }
//     if (widget.project.updatedAt != null &&
//         widget.project.updatedAt! != widget.project.timeCreated &&
//         widget.project.updatedAt!.day == DateTime.now().day) {
//       updatedText =
//           "Updated ${timeago.format(locale: _languageStore.locale, widget.project.updatedAt!.toLocal())}";
//     } else {
//       updatedText = createdText;
//     }
//   }

//   Widget _buildImage() {
//     return AspectRatio(
//       aspectRatio: 16 / 9,
//       child: Container(
//         width: double.infinity,
//         height: 100,
//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.project.isLoading) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildImage(),
//           ],
//         ),
//       );
//     } else {
//       var icon = widget.project.isFavorite
//           ? const Icon(Icons.favorite)
//           : const Icon(Icons.favorite_border);

//       return _OpenContainerWrapper(
//         project: widget.project,
//         closedChild: LayoutBuilder(builder: (context, c) {
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 9,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(updatedText,
//                           style: Theme.of(context)
//                               .textTheme
//                               .bodyText1!
//                               .copyWith(fontSize: 12)),
//                       Text(
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         widget.project.title == ''
//                             ? 'No title'
//                             : widget.project.title,
//                         style: Theme.of(context)
//                             .textTheme
//                             .bodyText2!
//                             .copyWith(color: Colors.green.shade400),
//                       ),
//                       Text(
//                         '${Lang.get('project_item_scope')} ${widget.project.scope.title}',
//                         //'Time: ${widget.project.scope.title}',
//                         style: Theme.of(context).textTheme.subtitle2,
//                       ),
//                       Text(
//                         '${Lang.get('project_item_students')} ${widget.project.numberOfStudents}',
//                         style: Theme.of(context).textTheme.subtitle2,
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         Lang.get('project_item_description_header'),
//                         style: Theme.of(context).textTheme.bodyText1,
//                       ),
//                       SizedBox(
//                         height: c.maxHeight / 5,
//                         child: AutoSizeText(
//                           widget.project.description == ''
//                               ? Lang.get("project_item_blank")
//                               : widget.project.description,
//                           style: const TextStyle(),
//                           maxLines: 5,
//                           overflow: TextOverflow.ellipsis,
//                           textAlign: TextAlign.justify,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         proposalText,
//                         style: Theme.of(context)
//                             .textTheme
//                             .bodyText1!
//                             .copyWith(fontSize: 14.0),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   color: Theme.of(context).colorScheme.primary,
//                   onPressed: () {
//                     setState(() {
//                       widget.onFavoriteTap();
//                     });
//                   },
//                   icon: icon,
//                 ),
//               ],
//             ),
//           );
//         }),

//         //  Card(
//         //   child: InkWell(
//         //     onTap: () {
//         //       //NavbarNotifier2.pushNamed(Routes.projectDetails, 1, widget.project);
//         //       Navigator.of(NavigationService.navigatorKey.currentContext!)
//         //           .pushNamed(Routes.projectDetailsStudent,
//         //               arguments: widget.project);
//         //     },
//         //     child: Padding(
//         //       padding: const EdgeInsets.all(8.0),
//         //       child: Row(
//         //         children: [
//         //           Expanded(
//         //             flex: 9,
//         //             child: SingleChildScrollView(
//         //               child: Column(
//         //                 crossAxisAlignment: CrossAxisAlignment.start,
//         //                 children: [
//         //                   Text(createdText),
//         //                   Text(widget.project.title),
//         //                   Text(
//         //                     'Time: ${widget.project.scope.title}, ${widget.project.numberOfStudents} students needed',
//         //                   ),
//         //                   Text(widget.project.description),
//         //                   Text(proposalText),
//         //                 ],
//         //               ),
//         //             ),
//         //           ),
//         //           IconButton(
//         //             color: Theme.of(context).colorScheme.primary,
//         //             onPressed: () {
//         //               setState(() {
//         //                 widget.onFavoriteTap();
//         //               });
//         //             },
//         //             icon: icon,
//         //           ),
//         //         ],
//         //       ),
//         //     ),
//         //   ),
//         // ),
//       );
//     }
//   }
// }

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
    // int differenceWithToday = widget.project.getModifiedTimeCreated();
    // if (differenceWithToday == 0) {
    //   createdText = Lang.get("created_now");
    // } else if (differenceWithToday == 1) {
    //   createdText = 'Created 1 day ago';
    // } else {
    //   createdText = 'Created $differenceWithToday${Lang.get('day_ago')}';
    // }
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

    // Future.delayed(Duration(milliseconds: 500 + widget.loadingDelay * 100), () {
    //   widget.stopLoading(widget.project.objectId!);
    //   if (mounted) {
    //     setState(() {
    //       widget.project.isLoading = false;
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    var icon = widget.project.isFavorite
        ? const Icon(Icons.bookmark)
        : const Icon(Icons.bookmark_add_outlined);

    return _OpenContainerWrapper(
      project: widget.project,
      closedChild: LayoutBuilder(builder: (context, c) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
          child: Stack(
            children: [
              Skeletonizer(
                enabled: widget.project.isLoading,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(updatedText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontSize: 12)),
                    AutoSizeText(
                      maxFontSize: 13,
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
                          fontWeight: FontWeight.bold),
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
                          .bodyText1!
                          .copyWith(fontSize: 14.0),
                    ),
                  ],
                ),
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
        );
      }),
    );
  }
}
