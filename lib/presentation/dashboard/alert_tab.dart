import 'dart:math';

import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:boilerplate/core/widgets/easy_timeline/easy_date_timeline.dart';
import 'package:boilerplate/core/widgets/easy_timeline/src/easy_infinite_date_time/widgets/easy_infinite_date_timeline_controller.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/page_transformer.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';

var colorss = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.amber,
  Colors.black,
  Colors.cyan,
  Colors.blueGrey,
  Colors.deepOrange,
  Colors.purple,
  Colors.indigo,
  Colors.lime,
  ...Colors.accents,
];

List<Color> colors = [];

class AlertTab extends StatefulWidget {
  const AlertTab({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  State<AlertTab> createState() => _AlertTabState();
}

class _AlertTabState extends State<AlertTab> {
  final List<Map<String, dynamic>> alerts = [
    {
      'icon': Icons.star,
      'title': 'You have submitted to join project "Javis - AI Copilot"',
      'subtitle': '6/6/2024',
      'action': null,
    },
    {
      'icon': Icons.star,
      'title':
          'You have invited to interview for project "Javis - AI Copilot" at 14:00 March 20, Thursday',
      'subtitle': '6/6/2024',
      'action': 'Join',
    },
    {
      'icon': Icons.star,
      'title': 'You have offer to join project "Javis - AI Copilot"',
      'subtitle': '6/6/2024',
      'action': 'View offer',
    },
    {
      'icon': Icons.star,
      'title': 'Alex Jor',
      'subtitle':
          'I have read your requirement but I dont seem to...?\n6/6/2024',
      'action': null,
    },
    {
      'icon': Icons.star,
      'title': 'Alex Jor',
      'subtitle': 'Finish your project?\n6/6/2024',
      'action': null,
    },
    {
      'icon': Icons.star,
      'title': 'Alex Jor',
      'subtitle': 'How are you doing?\n6/6/2024',
      'action': null,
    },

    {
      'icon': Icons.star,
      'title': 'You have an offer to join project "Quantum Physics"',
      'subtitle': '6/6/2024',
      'action': 'View offer',
    },
    {
      'icon': Icons.star,
      'title': 'You have an offer to join project "HCMUS - Administration"',
      'subtitle': '6/6/2024',
      'action': 'View offer',
    },
    // Add more alerts here
  ];
  var userStore = getIt<UserStore>();
  bool hasOfferProposal = false;

  List<Proposal> getOffer() {
    if (hasOfferProposal) {
      var p = userStore.user!.studentProfile!.proposalProjects!
          .where(
            (element) => element.hiredStatus == HireStatus.offer,
          )
          .toList();
      return p;
    } else {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    hasOfferProposal = userStore.user != null &&
        userStore.user!.studentProfile != null &&
        userStore.user!.studentProfile!.proposalProjects != null &&
        userStore.user!.studentProfile!.proposalProjects!.isNotEmpty;
    colors = List.filled(getOffer().length, Colors.white);
    for (int i = 0; i < (getOffer().length); i++) {
      colors[i] = colorss[Random().nextInt(colorss.length)];
    }
    var today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    selectedDate = today;
    activeDates
        .addAll([for (int i = -7; i < 7; i++) today.add(Duration(days: i))]);
    print(activeDates);
    Future.delayed(const Duration(seconds: 1), () {
      // dateController.animateToFocusDate(duration: const Duration(seconds: 1));
    });
    dateStyle = datePickerStyle;
    monthStyle = monthPickerStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: _buildAlertsContent());
  }

  var projectStore = getIt<ProjectStore>();
  var topRowController = ScrollController();

  Widget _buildTopRowList() {
    if (hasOfferProposal) {
      return Stack(
        children: [
          for (int index = getOffer().length - 1; index >= 0; index--)
            Center(
              child: Container(
                margin: EdgeInsets.only(
                    left: index == 1 ? 10 : 15, right: index == 2 ? 7 : 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: HeroFlutterLogo(
                    color: index == 2 ? Colors.white : colors[index],
                    tag: index,
                    size: 145,
                    onTap: () {
                      print(index);
                      NavbarNotifier2.hideBottomNavBar = true;

                      Navigator.of(
                              NavigationService.navigatorKey.currentContext ??
                                  context)
                          .push(
                        ModalExprollableRouteBuilder(
                            pageBuilder: (_, __, ___) => OfferDetailsDialog(
                                  index: index,
                                  proposal: getOffer(),
                                  onAcceptCallback: (proposal) {
                                    var userStore = getIt<UserStore>();
                                    var id = userStore
                                        .user?.studentProfile?.objectId;
                                    if (id != null && proposal != null) {
                                      projectStore
                                          .updateProposal(proposal, id)
                                          .then(
                                        (value) {
                                          setState(() {});
                                        },
                                      );
                                    }
                                  },
                                ),
                            // Increase the transition durations and take a closer look at what's going on!
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 300),
                            // The next two lines are not required, but are recommended for better performance.
                            dismissThresholdInset:
                                const DismissThresholdInset(dragMargin: 10000)),
                      )
                          .then(
                        (value) {
                          NavbarNotifier2.hideBottomNavBar = false;
                        },
                      );
                    },
                  ),
                ),
              ),
            )
        ],
      );

      // Scrollbar(
      //   controller: topRowController,
      //   child: ListView.builder(
      //     controller: topRowController,
      //     shrinkWrap: true,
      //     reverse: true,
      //     itemCount: getOffer().length,
      //     itemBuilder: (context, index) {
      //       return Container(
      //         margin: const EdgeInsets.only(right: 15, left: 5, top: 15),
      //         child: ClipRRect(
      //           borderRadius: BorderRadius.circular(12),
      //           child: HeroFlutterLogo(
      //             color: colors[index],
      //             tag: index,
      //             size: 125,
      //             onTap: () {
      //               print(index);
      //               NavbarNotifier2.hideBottomNavBar = true;

      //               Navigator.of(
      //                       NavigationService.navigatorKey.currentContext ??
      //                           context)
      //                   .push(
      //                 ModalExprollableRouteBuilder(
      //                     pageBuilder: (_, __, ___) => OfferDetailsDialog(
      //                           index: index,
      //                           proposal: getOffer(),
      //                           onAcceptCallback: (proposal) {
      //                             var userStore = getIt<UserStore>();
      //                             var id =
      //                                 userStore.user?.studentProfile?.objectId;
      //                             if (id != null && proposal != null) {
      //                               projectStore
      //                                   .updateProposal(proposal, id)
      //                                   .then(
      //                                 (value) {
      //                                   setState(() {});
      //                                 },
      //                               );
      //                             }
      //                           },
      //                         ),
      //                     // Increase the transition durations and take a closer look at what's going on!
      //                     transitionDuration: const Duration(milliseconds: 500),
      //                     reverseTransitionDuration:
      //                         const Duration(milliseconds: 300),
      //                     // The next two lines are not required, but are recommended for better performance.
      //                     dismissThresholdInset:
      //                         const DismissThresholdInset(dragMargin: 10000)),
      //               )
      //                   .then(
      //                 (value) {
      //                   NavbarNotifier2.hideBottomNavBar = false;
      //                 },
      //               );
      //             },
      //           ),
      //         ),
      //       );
      //     },
      //   ),
      // );
    } else {
      return Container(
        margin: const EdgeInsets.only(left: 15, right: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: HeroFlutterLogo(
            color: Colors.white,
            tag: -1,
            size: 125,
            onTap: () {},
          ),
        ),
      );
    }
  }

  TextStyle get datePickerStyle {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }

  TextStyle get monthPickerStyle {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.grey,
    );
  }

  TextStyle get datePickerStyleToday {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.red,
    );
  }

  TextStyle get monthPickerStyleToday {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.red,
    );
  }

  TextStyle dateStyle = const TextStyle(), monthStyle = const TextStyle();

  DateTime selectedDate = DateTime.now();
  IndexController alertPageController = IndexController();
  final List<DateTime> activeDates = [];
  final EasyInfiniteDateTimelineController dateController =
      EasyInfiniteDateTimelineController();
  int oldIndex = 7;

  _datePickerSection() {
    return Container(
        margin: const EdgeInsets.only(),
        child: EasyInfiniteDateTimeLine(
          selectionMode: const SelectionMode.autoCenter(),
          controller: dateController,
          firstDate: activeDates.first,
          focusDate: selectedDate,
          lastDate: activeDates.last,
          onDateChange: (date) {
            setState(() {
              selectedDate = date;
              print(date);
            });
            var i = activeDates.indexWhere(
              (element) =>
                  element.millisecondsSinceEpoch == date.millisecondsSinceEpoch,
            );
            if (i != -1) {
              alertPageController.move(i, animation: (oldIndex - i).abs() == 1);
              oldIndex = i;
              print(i);
            }
          },
          // timeLineProps: EasyTimeLineProps(
          //     decoration:
          //         BoxDecoration(borderRadius: BorderRadius.circular(12))),
          dayProps: EasyDayProps(
            activeDayStyle: DayStyle(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    const Color.fromARGB(255, 255, 170, 170),
                  ],
                ),
              ),
            ),
          ),
        ));
    //   DatePicker(
    //     controller: dateController,
    //     activeDates[0],
    //     height: 130,
    //     width: 80,
    //     daysCount: activeDates.length, // fortnight
    //     locale: getIt<LanguageStore>().locale,
    //     initialSelectedDate: selectedDate,
    //     selectionColor: const Color.fromARGB(255, 255, 48, 48),
    //     selectedTextColor: Colors.white,
    //     dateTextStyle: datePickerStyle,
    //     monthTextStyle: monthPickerStyle,
    //     onDateChange: (date) {
    //       setState(() {
    //         selectedDate = date;
    //         print(date);
    //       });
    //       var i = activeDates.indexWhere(
    //         (element) =>
    //             element.millisecondsSinceEpoch == date.millisecondsSinceEpoch,
    //       );
    //       if (i != -1) {
    //         alertPageController.move(i, animation: (oldIndex - i).abs() == 1);
    //         oldIndex = i;
    //         print(i);
    //       }
    //     },
    //   ),
    // );
  }

  Widget _buildAlertsContent() {
    return Stack(children: [
      Container(
          height: 155,
          width: 120,
          margin: const EdgeInsets.only(
            top: 2,
          ),
          child: _buildTopRowList()),
      Container(
          margin: const EdgeInsets.only(top: 0, left: 120),
          height: 170,
          child: _datePickerSection()),
      Container(
        margin: const EdgeInsets.only(top: 170),
        height: MediaQuery.of(context).size.height * 0.9 - 230,
        child: TransformerPageView(
          itemCount: activeDates.length,
          index: 7, // middle page
          controller: alertPageController,
          transformer: DepthPageTransformer(),
          onPageChanged: (value) {
            dateController.animateToDate(activeDates[value ?? 0]);
            setState(() {
              selectedDate = activeDates[value ?? 0];
            });
            print(selectedDate);
          },
          itemBuilder: (context, index) {
            return ListView.separated(
                itemCount: alerts.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.black),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      //print('Tile clicked');
                      // You can replace the print statement with your function
                    },
                    child: ListTile(
                      leading: Icon(alerts[index]['icon']),
                      title: Text(alerts[index]['title']),
                      subtitle: Text(alerts[index]['subtitle']),
                      trailing: alerts[index]['action'] != null
                          ? ElevatedButton(
                              onPressed: () {
                                //print('${alerts[index]['action']} button clicked');
                                if (alerts[index]['action'] != null) {
                                  if (alerts[index]['action'] == "Join") {
                                    Navigator.of(NavigationService
                                            .navigatorKey.currentContext!)
                                        .push(MaterialPageRoute2(
                                            routeName: Routes.message,
                                            arguments: "Javis - AI Copilot"));
                                  } else if (alerts[index]['action'] ==
                                      "View offer") {
                                    // showOfferDetailsDialog(context, 2);
                                    // NavbarNotifier2.hideBottomNavBar = true;
                                  }
                                }
                                // You can replace the print statement with your function
                              },
                              child: Text(Lang.get(alerts[index]['action'])),
                            )
                          : null,
                    ),
                  );
                });
          },
        ),
      ),
    ]);
  }
}

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
                                                  widget.proposal[page]
                                                          .hiredStatus =
                                                      HireStatus.hired;
                                                  widget.onAcceptCallback(
                                                      widget.proposal[page]);
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

class HeroFlutterLogo extends StatelessWidget {
  const HeroFlutterLogo({
    super.key,
    required this.color,
    required this.tag,
    required this.size,
    required this.onTap,
  });

  final int tag;
  final Color color;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      transitionOnUserGestures: true,
      tag: tag,
      child: Material(
        color: color,
        child: InkWell(
          onTap: onTap,
          child: FlutterLogo(
            size: size,
          ),
        ),
      ),
    );
  }
}
