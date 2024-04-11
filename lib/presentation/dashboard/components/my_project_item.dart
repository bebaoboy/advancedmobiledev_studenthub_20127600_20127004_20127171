import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/project_details.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
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
        borderRadius: BorderRadius.all(Radius.circular(12)),
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
            if (project.enabled == Status.inactive) return;
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

  final Widget icon;
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
      duration: const Duration(milliseconds: 500),
      padding: padding,
      child: Material(
        color: Colors.transparent,
        // child: Icon(
        //   Icons.abc,
        //   size: 36,
        //   color: iconColor,
        // ),
        child: icon,
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
          icon: Text(Lang.get("archive"),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              )),
          backgroundColor: Theme.of(context).colorScheme.primary,
          iconColor: Colors.amber,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsetsDirectional.only(start: 20),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            // TODO: bỏ vô archive
            // if (onStarredInbox) {
            //   return true;
            // }
            // onStar();
            return false;
          } else {
            return false;
          }
        },
        secondaryBackground: _DismissibleContainer(
          icon: Text(Lang.get("archive"),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              )),
          backgroundColor: Colors.green,
          iconColor: Colors.amber,
          alignment: Alignment.centerRight,
          padding: const EdgeInsetsDirectional.only(end: 20),
        ),
        child: buildItem(MediaQuery.of(context).size.width),
      ),
    );
  }

  final _languageStore = getIt<LanguageStore>();

  buildItem(width) {
    var createdText = '';
    // int differenceWithToday = widget.project.getModifiedTimeCreated();
    // if (differenceWithToday == 0) {
    //   createdText = Lang.get("created_now");
    // } else if (differenceWithToday == 1) {
    //   createdText = 'Created 1 day ago';
    // } else {
    //   createdText = 'Created $differenceWithToday${Lang.get('day_ago')}';
    // }
    createdText = timeago.format(
        locale: _languageStore.locale, widget.project.timeCreated);

    return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimens.horizontal_padding, vertical: 5),
        child: ClipRect(
            child: Container(
          foregroundDecoration: widget.project.enabled == Status.inactive
              ? RotatedCornerDecoration.withColor(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  spanBaselineShift: 4,
                  badgeSize: const Size(64, 64),
                  badgeCornerRadius: const Radius.circular(8),
                  badgePosition: BadgePosition.topEnd,
                  textSpan: TextSpan(
                      text: Lang.get("closed"),
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          BoxShadow(color: Colors.yellowAccent, blurRadius: 8),
                        ],
                      )))
              : null,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: widget.project.enabled == Status.inactive
                    ? Colors.grey.shade300
                    : null,
                border: Border.all(
                    color: Colors.black54,
                    width: 0.3,
                    style: BorderStyle.solid)),
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
                            .bodyMedium!
                            .copyWith(color: Colors.green.shade400),
                      ),
                      Text(createdText,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(fontWeight: FontWeight.w200)),
                      SizedBox(
                        width: width * 8,
                        child: AutoSizeText(widget.project.description,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.project.countProposals.toString(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Proposals',
                                style: Theme.of(context).textTheme.bodyLarge,
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Add a message length here
                              Text(
                                widget.project.countMessages.toString(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Messages',
                                style: Theme.of(context).textTheme.bodyLarge,
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.project.countHired.toString(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Hired',
                                style: Theme.of(context).textTheme.bodyLarge,
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  // ToDo: implement show bottom sheet
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () =>
                            widget.onShowBottomSheet!(widget.project),
                        icon: const Icon(Icons.more_horiz_outlined)),
                  ),
                  // if (widget.project.enabled == Status.inactive)
                  //   Positioned.fill(
                  //     child: ClipRect(
                  //         child: CornerBanner(
                  //             bannerText: Lang.get("closed"),
                  //             bannerPosition: BannerPosition.topLeft,
                  //             bannerSize: 80,
                  //             bannerColor:
                  //                 Theme.of(context).colorScheme.primaryContainer,
                  //             child: Container())),
                  //   ),
                ],
              ),
            ),
          ),
        )));
  }
}
