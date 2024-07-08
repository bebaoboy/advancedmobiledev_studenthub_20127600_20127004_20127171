import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/core/extensions/cap_extension.dart';
import 'package:boilerplate/core/widgets/open_container.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/project_details.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
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
      routeSettings: RouteSettings(
          name: "${Routes.projectDetails}/${project.objectId}",
          arguments: {"project": project}),
      openColor: theme.cardColor,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      closedElevation: 0,
      closedColor: theme.cardColor,
      closedBuilder: (context, openContainer) {
        return InkWell(
          splashColor: project.isArchive ? Colors.transparent : null,
          onTap: () {
            // Provider.of<EmailStore>(
            //   context,
            //   listen: false,
            // ).currentlySelectedEmailId = id;
            // if (project.isArchive) return;
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
  final bool Function(Project project, bool endToStart)? onDismissed;
  final Project project;
  final bool dismissable;

  const MyProjectItem(
      {super.key,
      required this.project,
      required this.onShowBottomSheet,
      this.onDismissed,
      this.dismissable = true});

  @override
  State<MyProjectItem> createState() => _MyProjectItemState();
}

class _MyProjectItemState extends State<MyProjectItem> {
  var createdText = '';
  var updatedText = '';
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
  }

  @override
  Widget build(BuildContext context) {
    createdText = timeago
        .format(locale: _languageStore.locale, widget.project.timeCreated)
        .inCaps;

    if (widget.project.updatedAt != null &&
        widget.project.updatedAt! != widget.project.timeCreated) {
      // updatedText =
      //     "\t(Updated: ${DateFormat("HH:mm").format(widget.project.updatedAt!.toLocal())})";
      updatedText =
          "Updated ${timeago.format(locale: _languageStore.locale, widget.project.updatedAt!.toLocal())}";
    } else {
      updatedText = createdText;
    }
    return _OpenContainerWrapper(
      project: widget.project,
      closedChild: widget.dismissable
          ? Dismissible(
              key: UniqueKey(),
              dismissThresholds: const {
                DismissDirection.startToEnd: 0.8,
                DismissDirection.endToStart: 0.8,
              },
              direction: widget.project.isWorking
                  ? DismissDirection.endToStart
                  : DismissDirection.startToEnd,
              onDismissed: (direction) {},
              background: _DismissibleContainer(
                icon: Text(
                    widget.project.isWorking
                        ? Lang.get("archive")
                        : Lang.get("unarchive"),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    )),
                backgroundColor: Colors.green,
                iconColor: Colors.amber,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsetsDirectional.only(start: 20),
              ),
              confirmDismiss: (direction) async {
                if (!widget.dismissable) return false;
                if (widget.onDismissed != null) {
                  switch (direction) {
                    case DismissDirection.endToStart:
                      {
                        return widget.onDismissed!(widget.project, true);
                      }
                    case DismissDirection.startToEnd:
                      {
                        return widget.onDismissed!(widget.project, false);
                      }
                    default:
                      return false;
                  }
                }
                return false;
              },
              secondaryBackground: widget.project.isArchive
                  ? null
                  : _DismissibleContainer(
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
            )
          : buildItem(MediaQuery.of(context).size.width),
    );
  }

  final _languageStore = getIt<LanguageStore>();

  buildItem(width) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.symmetric(
            horizontal: Dimens.horizontal_padding, vertical: 5),
        child: ClipRect(
            child: Container(
          foregroundDecoration: widget.project.isArchive
              ? RotatedCornerDecoration.withColor(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  spanBaselineShift: 4,
                  badgeSize: const Size(84, 84),
                  badgeCornerRadius: const Radius.circular(8),
                  badgePosition: BadgePosition.topEnd,
                  textSpan: TextSpan(
                      text: Lang.get("closed"),
                      style: const TextStyle(
                        fontSize: 14,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          BoxShadow(color: Colors.yellowAccent, blurRadius: 8),
                        ],
                      )))
              : widget.project.countProposals > 10
                  ? const RotatedCornerDecoration.withColor(
                      color: Colors.orangeAccent,
                      spanBaselineShift: 4,
                      badgeSize: Size(84, 84),
                      badgeCornerRadius: Radius.circular(8),
                      badgePosition: BadgePosition.topEnd,
                      textSpan: TextSpan(
                          text: "HOT!",
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              BoxShadow(
                                  color: Colors.orangeAccent, blurRadius: 8),
                            ],
                          )))
                  : widget.project.isWorking
                      ? const RotatedCornerDecoration.withColor(
                          color: Colors.green,
                          spanBaselineShift: 4,
                          badgeSize: Size(84, 84),
                          badgeCornerRadius: Radius.circular(8),
                          badgePosition: BadgePosition.topEnd,
                          textSpan: TextSpan(
                              text: "Working",
                              style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  BoxShadow(
                                      color: Colors.yellowAccent,
                                      blurRadius: 8),
                                ],
                              )))
                      : null,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: widget.project.isArchive
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.1)
                    : Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.2)
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
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        widget.project.title.trim().toTitleCase() +
                            (widget.project.isArchive
                                ? widget.project.closeStatus ==
                                        ProjectStatusFlag.fail
                                    ? "(❌)"
                                    : "(✅)"
                                : ""),
                        style: TextStyle(
                            color: widget.project.closeStatus ==
                                    ProjectStatusFlag.fail
                                ? Colors.red
                                : Colors.green.shade400,
                            fontWeight: widget.project.isWorking
                                ? FontWeight.bold
                                : null),
                      ),
                      Text(updatedText,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(fontWeight: FontWeight.w200)),
                      SizedBox(
                        height: !widget.project.isArchive ? null : 20,
                        width: width * 8,
                        child: AutoSizeText(widget.project.description,
                            maxLines: !widget.project.isArchive ? 5 : 1,
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
                                'Total',
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
                  // if (widget.project.isArchive)
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
