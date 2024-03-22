import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/dashboard/project_details.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
        return InkWell(
          onTap: () {
            // Provider.of<EmailStore>(
            //   context,
            //   listen: false,
            // ).currentlySelectedEmailId = id;
            openContainer();
          },
          child: closedChild,
        );
      },
    );
  }
}

class _DismissibleContainer extends StatelessWidget {
  const _DismissibleContainer({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.alignment,
    required this.padding,
  });

  final String icon;
  final Color backgroundColor;
  final Color iconColor;
  final Alignment alignment;
  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: alignment,
      color: backgroundColor,
      curve: standardEasing,
      duration: const Duration(seconds: 1),
      padding: padding,
      child: Material(
        color: Colors.transparent,
        child: Icon(
          Icons.abc,
          size: 36,
          color: iconColor,
        ),
      ),
    );
  }
}

class MyProjectItem extends StatefulWidget {
  final void Function(Project project)? onShowBottomSheet;
  final Project project;
  const MyProjectItem(
      {super.key, required this.project, required this.onShowBottomSheet});

  @override
  State<MyProjectItem> createState() => _MyProjectItemState();
}

class _MyProjectItemState extends State<MyProjectItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _OpenContainerWrapper(
      project: widget.project,
      closedChild: Dismissible(
        key: const ObjectKey(""),
        dismissThresholds: const {
          DismissDirection.startToEnd: 0.8,
          DismissDirection.endToStart: 0.4,
        },
        onDismissed: (direction) {
          switch (direction) {
            case DismissDirection.endToStart:
              // if (onStarredInbox) {
              //   onStar();
              // }
              break;
            case DismissDirection.startToEnd:
              // onDelete();
              break;
            default:
          }
        },
        background: _DismissibleContainer(
          icon: 'twotone_delete',
          backgroundColor: Theme.of(context).colorScheme.primary,
          iconColor: Colors.amber,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsetsDirectional.only(start: 20),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            // if (onStarredInbox) {
            //   return true;
            // }
            // onStar();
            return false;
          } else {
            return true;
          }
        },
        secondaryBackground: _DismissibleContainer(
          icon: 'twotone_star',
          backgroundColor: Theme.of(context).colorScheme.background,
          iconColor: Colors.amber,
          alignment: Alignment.centerRight,
          padding: const EdgeInsetsDirectional.only(end: 20),
        ),
        child: buildItem(MediaQuery.of(context).size.width
        ),
      ),
    );
  }

  buildItem(width) {
    var createdText = '';
    int differenceWithToday = widget.project.getModifiedTimeCreated();
    if (differenceWithToday == 0) {
      createdText = 'Created just now';
    } else if (differenceWithToday == 1) {
      createdText = 'Created 1 day ago';
    } else {
      createdText = 'Created $differenceWithToday days ago';
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimens.horizontal_padding),
      child: Container(
        width: width,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black, width: 1.0),
          ),
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimens.horizontal_padding,
                vertical: Dimens.vertical_padding),
            child: Stack(
              
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(color: Colors.green.shade400),
                    ),
                    Text(createdText,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.w200)),
                    Container(
                      width: width * 8,
                      child: AutoSizeText(widget.project.description,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (widget.project.proposal?.length ?? 0)
                                  .toString(),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            Text(
                              'Proposals',
                              style: Theme.of(context).textTheme.bodyText1,
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Add a message length here
                            Text(
                              (widget.project.messages?.length ?? 0)
                                  .toString(),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            Text(
                              'Messages',
                              style: Theme.of(context).textTheme.bodyText1,
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (widget.project.hired?.length ?? 0).toString(),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            Text(
                              'Hired',
                              style: Theme.of(context).textTheme.bodyText1,
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
                // ToDo: implement show bottom sheet
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () => widget.onShowBottomSheet!(widget.project),
                      icon: const Icon(Icons.more_horiz_outlined)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
