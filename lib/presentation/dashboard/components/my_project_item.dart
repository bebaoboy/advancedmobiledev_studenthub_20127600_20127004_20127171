import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
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
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black, width: 1.0),
          ),
        ),
        child: Card(
          child: InkWell(
            onTap: () {
              //NavbarNotifier2.pushNamed(Routes.projectDetails, 1, widget.project);
              Navigator.of(NavigationService.navigatorKey.currentContext!)
                  .pushNamed(Routes.projectDetails,
                      arguments: widget.project);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.horizontal_padding,
                  vertical: Dimens.vertical_padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
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
                        Text(widget.project.description,
                            style: Theme.of(context).textTheme.bodyText1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (widget.project.proposal?.length ?? 0)
                                      .toString(),
                                  style:
                                      Theme.of(context).textTheme.bodyText1,
                                ),
                                Text(
                                  'Proposals',
                                  style:
                                      Theme.of(context).textTheme.bodyText1,
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
                                  style:
                                      Theme.of(context).textTheme.bodyText1,
                                ),
                                Text(
                                  'Messages',
                                  style:
                                      Theme.of(context).textTheme.bodyText1,
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (widget.project.hired?.length ?? 0)
                                      .toString(),
                                  style:
                                      Theme.of(context).textTheme.bodyText1,
                                ),
                                Text(
                                  'Hired',
                                  style:
                                      Theme.of(context).textTheme.bodyText1,
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  // ToDo: implement show bottom sheet
                  IconButton(
                      onPressed: () =>
                          widget.onShowBottomSheet!(widget.project),
                      icon: const Icon(Icons.more_horiz_outlined))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
