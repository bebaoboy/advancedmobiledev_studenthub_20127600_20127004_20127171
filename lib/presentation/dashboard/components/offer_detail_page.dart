
import 'package:boilerplate/core/widgets/material_dialog/dialog_widget.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/alert_tab.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:lottie/lottie.dart';

class OfferDetailsDialog extends StatefulWidget {
  const OfferDetailsDialog({
    super.key,
    required this.index,
    required this.proposal,
    required this.onAcceptCallback,
  });

  final int index;
  final List<Proposal> proposal;
  final Function(Proposal?) onAcceptCallback;

  @override
  State<StatefulWidget> createState() => _OfferDetailsDialogState();
}

class _OfferDetailsDialogState extends State<OfferDetailsDialog> {
  late final ExprollablePageController controller;

  @override
  void initState() {
    super.initState();
    controller = ExprollablePageController(
        initialPage: widget.index,
        viewportConfiguration: ViewportConfiguration(
          extraSnapInsets: [
            const ViewportInset.fractional(0.2),
          ],
          extendPage: true,
          overshootEffect: true,
        ));
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExprollablePageView(
        controller: controller,
        itemCount: widget.proposal.length,
        itemBuilder: (context, page) {
          return PageGutter(
              gutterWidth: 8,
              child: Stack(
                children: [
                  Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Stack(children: [
                        Container(
                          margin: const EdgeInsets.only(top: 00),
                          child: ListView.builder(
                            controller: PageContentScrollController.of(context),
                            itemCount: 4,
                            itemBuilder: (_, index) {
                              if (index == 0) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 35),
                                      child: Text(
                                          "${widget.proposal[page].isHired ? "Accepted" : Lang.get("new_offer")} #$page"),
                                    ),
                                    const Align(
                                        alignment: Alignment.topRight,
                                        child: CloseButton()),
                                  ],
                                );
                              }
                              if (index == 1) {
                                return Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(30, 10, 30, 30),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: HeroFlutterLogo(
                                      color: colors[page],
                                      tag: page,
                                      size: MediaQuery.of(context).size.height *
                                          0.4,
                                      onTap: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                );
                              } else if (index == 2) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                          "Project Name: \n${widget.proposal[page].project?.title}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0, vertical: 20),
                                          child: Text(
                                            "${widget.proposal[page].coverLetter} \n${Lang.get('profile_common_body')}\n",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer,
                                                surfaceTintColor:
                                                    Colors.transparent,
                                                minimumSize: Size(
                                                    MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2 -
                                                        48,
                                                    40), // NEW
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () {
                                                // Navigator.of(context).pushNamed(
                                                //     Routes.submitProposal,
                                                //     arguments: widget.project);
                                              },
                                              child: Text(
                                                Lang.get('save'),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .merge(TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary)),
                                              ),
                                            ),
                                            if (widget.proposal[page]
                                                    .hiredStatus ==
                                                HireStatus.offer)
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                  surfaceTintColor:
                                                      Colors.transparent,
                                                  minimumSize: Size(
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2 -
                                                          48,
                                                      40), // NEW
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  // Navigator.of(context).pushNamed(
                                                  //     Routes.submitProposal,
                                                  //     arguments: widget.project);
                                                  AnimatedDialog
                                                      .showAnimatedDialog(
                                                    context,
                                                    onClose: (p0) =>
                                                        setState(() {}),
                                                    contentTextAlign:
                                                        TextAlign.center,
                                                    contentText:
                                                        'You can\'t undo this',
                                                    title: "Accept this offer?",
                                                    color: Colors.white,
                                                    dialogWidth:
                                                        kIsWeb ? 0.3 : null,
                                                    lottieBuilder: Lottie.asset(
                                                      'assets/animations/loading_animation.json',
                                                      fit: BoxFit.contain,
                                                    ),
                                                    positiveText: "Delete",
                                                    positiveIcon:
                                                        Icons.delete_forever,
                                                    onPositiveClick: (context) {
                                                      widget.proposal[page]
                                                              .hiredStatus =
                                                          HireStatus.hired;
                                                      widget.onAcceptCallback(
                                                          widget
                                                              .proposal[page]);
                                                    },
                                                    negativeText: "Cancel",
                                                    negativeIcon:
                                                        Icons.close_sharp,
                                                    onNegativeClick: (context) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  Lang.get('accept_offer'),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .merge(TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary)),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        Lang.get('profile_question_title_1'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Text(
                                              Lang.get(
                                                  'profile_question_title_4'),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            Lang.get('profile_common_body'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Lang.get(
                                                'profile_question_title_4'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            Lang.get('profile_common_body'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      // _buildEmailField(context),
                                      // const SizedBox(
                                      //   height: 25,
                                      // ),
                                      Text(
                                        Lang.get('profile_common_body'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Lang.get(
                                                'profile_question_title_4'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            Lang.get('profile_common_body'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Lang.get(
                                                'profile_question_title_4'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            Lang.get('profile_common_body'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const ListTile(
                                  // onTap: () =>
                                  //     debugPrint("onTap(index=$index, page=$index)"),
                                  // title: Text("Item#$index"),
                                  // subtitle: Text("Page#$index"),
                                  );
                            },
                          ),
                        ),
                      ])),
                ],
              ));
        });
  }
}

class CloseButton extends StatelessWidget {
  const CloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptivePagePadding(
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.cancel,
          color: Colors.black45,
        ),
      ),
    );
  }
}
