// ignore_for_file: deprecated_member_use

import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/core/extensions/cap_extension.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/project_details.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class _OpenContainerWrapper extends StatelessWidget {
  const _OpenContainerWrapper({
    required this.closedChild,
    required this.project,
  });

  final Widget closedChild;
  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer(
      useRootNavigator: true,
      transitionDuration: const Duration(milliseconds: 500),
      openBuilder: (context, closedContainer) {
        return ProjectDetailsPage(
          project: project,
        );
      },
      openColor: theme.cardColor,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      closedElevation: 0,
      closedColor: theme.cardColor,
      closedBuilder: (context, openContainer) {
        return Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black, width: 1.0),
                bottom: BorderSide(color: Colors.black, width: 1.0),
              ),
            ),
            child: InkWell(
              onTap: () {
                // Provider.of<EmailStore>(
                //   context,
                //   listen: false,
                // ).currentlySelectedEmailId = id;
                openContainer();
              },
              child: closedChild,
            ));
      },
    );
  }
}

class ProjectItem extends StatefulWidget {
  final Project project;

  final Function onFavoriteTap;
  const ProjectItem(
      {super.key, required this.project, required this.onFavoriteTap});

  @override
  _ProjectItemState createState() => _ProjectItemState();
}

class _ProjectItemState extends State<ProjectItem> {
  final _languageStore = getIt<LanguageStore>();
  @override
  void initState() {
    super.initState();
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
          ],
        ),
      );
    } else {
      var icon = widget.project.isFavorite
          ? const Icon(Icons.favorite)
          : const Icon(Icons.favorite_border);

      var createdText = '';
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
          .toTitleCase();

      var proposalText = 'Proposals: ';
      if (widget.project.proposal != null) {
        if (widget.project.proposal!.length > 6) {
          proposalText +=
              'Less than ${widget.project.proposal!.length.toString()}';
        } else {
          proposalText += widget.project.proposal!.length.toString();
        }
      } else {
        proposalText += '0';
      }

      return _OpenContainerWrapper(
        project: widget.project,
        closedChild: LayoutBuilder(
          builder: (context, c) {
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(createdText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(fontSize: 12)),
                          Text(
                            widget.project.title == ''
                                ? 'No title'
                                : widget.project.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(color: Colors.green.shade400),
                          ),
                          // TODO: dịch
                          Text(
                            'Time: ${widget.project.scope.title}, ${widget.project.numberOfStudents} students needed',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Student are looking for: ",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          SizedBox(
                            height: c.maxHeight / 5,
                            child: AutoSizeText(
                              widget.project.description == ''
                                  ? 'No description'
                                  : widget.project.description,
                              style: const TextStyle(
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
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
                    IconButton(
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        setState(() {
                          widget.onFavoriteTap();
                        });
                      },
                      icon: icon,
                    ),
                  ],
                ),
              );
          }
        ),
        

        //  Card(
        //   child: InkWell(
        //     onTap: () {
        //       //NavbarNotifier2.pushNamed(Routes.projectDetails, 1, widget.project);
        //       Navigator.of(NavigationService.navigatorKey.currentContext!)
        //           .pushNamed(Routes.projectDetailsStudent,
        //               arguments: widget.project);
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Row(
        //         children: [
        //           Expanded(
        //             flex: 9,
        //             child: SingleChildScrollView(
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Text(createdText),
        //                   Text(widget.project.title),
        //                   Text(
        //                     'Time: ${widget.project.scope.title}, ${widget.project.numberOfStudents} students needed',
        //                   ),
        //                   Text(widget.project.description),
        //                   Text(proposalText),
        //                 ],
        //               ),
        //             ),
        //           ),
        //           IconButton(
        //             color: Theme.of(context).colorScheme.primary,
        //             onPressed: () {
        //               setState(() {
        //                 widget.onFavoriteTap();
        //               });
        //             },
        //             icon: icon,
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      );
    }
  }
}
