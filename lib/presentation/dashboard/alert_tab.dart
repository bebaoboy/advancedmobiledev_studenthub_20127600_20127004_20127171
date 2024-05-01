// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/core/widgets/easy_timeline/easy_date_timeline.dart';
import 'package:boilerplate/core/widgets/easy_timeline/src/easy_infinite_date_time/widgets/easy_infinite_date_timeline_controller.dart';
import 'package:boilerplate/core/widgets/material_dialog/dialog_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/page_transformer.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:toastification/toastification.dart';

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

final List<NotificationObject> alerts = [
  NotificationObject(
      type: NotificationType.text,
      id: "",
      receiver: StudentProfile(objectId: "", fullName: "student 1"),
      sender: CompanyProfile(
        objectId: "",
        companyName: "company 1",
      ),
      content: 'You have submitted to join project "Javis - AI Copilot',
      createdAt: DateTime.now()),
  NotificationObject(
      id: "",
      receiver: StudentProfile(objectId: "", fullName: "student 1"),
      sender: CompanyProfile(
        objectId: "",
        companyName: "company 1",
      ),
      type: NotificationType.joinInterview,
      content:
          'You have invited to interview for project "Javis - AI Copilot" at 14:00 March 20, Thursday',
      createdAt: DateTime.now().subtract(const Duration(days: 7))),
  OfferNotification(
      projectId: "",
      id: "",
      receiver: StudentProfile(objectId: "", fullName: "student 1"),
      sender: CompanyProfile(
        objectId: "",
        companyName: "company 1",
      ),
      content: 'You have submitted to join project "Javis - AI Copilot',
      createdAt: DateTime.now()),
  NotificationObject(
      type: NotificationType.message,
      id: "",
      receiver: StudentProfile(objectId: "", fullName: "student 1"),
      sender: CompanyProfile(
        objectId: "",
        companyName: "Alex Jor",
      ),
      content: 'I have read your requirement but I dont seem to...?\n6/6/2024',
      createdAt: DateTime.now()),
  NotificationObject(
      type: NotificationType.message,
      id: "",
      receiver: StudentProfile(objectId: "", fullName: "student 1"),
      sender: CompanyProfile(
        objectId: "",
        companyName: "Alex Jor",
      ),
      content: 'Finish your project?',
      createdAt: DateTime.now()),
  NotificationObject(
      type: NotificationType.message,
      id: "",
      receiver: StudentProfile(objectId: "", fullName: "student 1"),
      sender: CompanyProfile(
        objectId: "",
        companyName: "Alex Jor",
      ),
      content: 'How are you doing?',
      createdAt: DateTime.now()),
  OfferNotification(
      projectId: "",
      id: "",
      receiver: StudentProfile(objectId: "", fullName: "student 1"),
      sender: CompanyProfile(
        objectId: "",
        companyName: "company 1",
      ),
      content: 'You have an offer to join project "HCMUS - Administration"',
      createdAt: DateTime.now()),
  OfferNotification(
      projectId: "",
      id: "",
      receiver: StudentProfile(objectId: "", fullName: "student 1"),
      sender: CompanyProfile(
        objectId: "",
        companyName: "company 1",
      ),
      content: 'You have an offer to join project "Quantum Physics"',
      createdAt: DateTime.now()),
];

// final List<Map<String, dynamic>> alerts = [
//   // OfferNotification(
//   //     projectId: "",
//   //     id: "",
//   //     receiver: Profile(objectId: ""),
//   //     sender: Profile(objectId: ""),
//   //     content: 'You have submitted to join project "Javis - AI Copilot'),

//   {
//     'icon': Icons.star,
//     'title': 'You have submitted to join project "Javis - AI Copilot"',
//     'subtitle': '6/6/2024',
//     'action': null,
//   },
//   {
//     'icon': Icons.star,
//     'title':
//         'You have invited to interview for project "Javis - AI Copilot" at 14:00 March 20, Thursday',
//     'subtitle': '6/6/2024',
//     'action': 'Join',
//   },
//   {
//     'icon': Icons.star,
//     'title': 'You have offer to join project "Javis - AI Copilot"',
//     'subtitle': '6/6/2024',
//     'action': 'View offer',
//   },
//   {
//     'icon': Icons.star,
//     'title': 'Alex Jor',
//     'subtitle': 'I have read your requirement but I dont seem to...?\n6/6/2024',
//     'action': null,
//   },
//   {
//     'icon': Icons.star,
//     'title': 'Alex Jor',
//     'subtitle': 'Finish your project?\n6/6/2024',
//     'action': null,
//   },
//   {
//     'icon': Icons.star,
//     'title': 'Alex Jor',
//     'subtitle': 'How are you doing?\n6/6/2024',
//     'action': null,
//   },

//   {
//     'icon': Icons.star,
//     'title': 'You have an offer to join project "Quantum Physics"',
//     'subtitle': '6/6/2024',
//     'action': 'View offer',
//   },
//   {
//     'icon': Icons.star,
//     'title': 'You have an offer to join project "HCMUS - Administration"',
//     'subtitle': '6/6/2024',
//     'action': 'View offer',
//   },
//   // Add more alerts here
// ];

class _AlertTabState extends State<AlertTab> {
  var userStore = getIt<UserStore>();
  bool hasOfferProposal = false;
  List<NotificationObject> viewOffers = [],
      texts = [],
      messages = [],
      joinInterviews = [];

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
    joinInterviews =
        alerts.where((e) => e.type == NotificationType.joinInterview).toList();
    viewOffers =
        alerts.where((e) => e.type == NotificationType.viewOffer).toList();
    texts = alerts.where((e) => e.type == NotificationType.text).toList();
    messages = alerts.where((e) => e.type == NotificationType.message).toList();
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
    showTime = List.filled(activeDates.length, true);

    Future.delayed(const Duration(seconds: 1), () {
      // dateController.animateToFocusDate(duration: const Duration(seconds: 1));
    });
    dateStyle = datePickerStyle;
    monthStyle = monthPickerStyle;
    listController = List.filled(activeDates.length, ScrollController());
    for (var element in listController) {
      element.addListener(
        () {
          if (element.position.userScrollDirection == ScrollDirection.reverse) {
            hideBar(true);
          } else {
            hideBar(false);
          }
        },
      );
    }
  }

  hideBar(b) {
    NavbarNotifier2.hideBottomNavBar = b;
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
      return InkWell(
        child: Stack(
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
                        if (userStore.user != null &&
                            userStore.user!.type != UserType.student) {
                          return;
                        }
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
                                            Toastify.show(
                                                context,
                                                "",
                                                "Succeed!",
                                                aboveNavbar: !NavbarNotifier2
                                                    .isNavbarHidden,
                                                ToastificationType.success,
                                                () {});
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
                                  const DismissThresholdInset(
                                      dragMargin: 10000)),
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
        ),
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
  List<ScrollController> listController = [];

  DateTime selectedDate = DateTime.now();
  IndexController alertPageController = IndexController();
  final List<DateTime> activeDates = [];
  final EasyInfiniteDateTimelineController dateController =
      EasyInfiniteDateTimelineController();
  int oldIndex = 7;
  List<bool> showTime = [];

  _datePickerSection() {
    return Container(
        // decoration: BoxDecoration(
        //     border: Border.all(
        //       color: Theme.of(context).colorScheme.primary,
        //     ),
        //     borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(),
        child: EasyInfiniteDateTimeLine(
          selectionMode: const SelectionMode.alwaysFirst(),
          controller: dateController,
          firstDate: activeDates.first,
          focusDate: selectedDate,
          lastDate: activeDates.last,
          locale: getIt<LanguageStore>().locale,
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
          dayProps: EasyDayProps(
            height: 60,
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
          height: 108,
          width: 120,
          margin: const EdgeInsets.only(
            top: 2,
          ),
          child: _buildTopRowList()),
      Container(
          margin: const EdgeInsets.only(top: 10, left: 120),
          height: 110,
          child: _datePickerSection()),
      Container(
        margin: const EdgeInsets.only(top: 120),
        height: MediaQuery.of(context).size.height * 0.9,
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
          itemBuilder: (context, i) {
            return SingleChildScrollView(
              controller: listController[i],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "New",
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: joinInterviews.length,
                    itemBuilder: (context, index) {
                      return CustomFollowNotification(
                        notificationObject: joinInterviews[index],
                        showTime: showTime[i],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Today",
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: viewOffers.length,
                    itemBuilder: (context, index) {
                      return CustomFollowNotification(
                        notificationObject: viewOffers[index],
                        showTime: showTime[i],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Older",
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: texts.length,
                    itemBuilder: (context, index) {
                      return CustomLikedNotifcation(
                        notificationObject: texts[index],
                        showTime: showTime[i],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Oldest",
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return CustomLikedNotifcation(
                        notificationObject: messages[index],
                        showTime: showTime[i],
                      );
                    },
                  ),
                ],
              ),
            );

            // ListView.separated(
            //     controller: listController[index],
            //     itemCount: alerts.length,
            //     separatorBuilder: (context, index) =>
            //         const Divider(color: Colors.black),
            //     itemBuilder: (context, index) {
            //       return GestureDetector(
            //         onTap: () {
            //           //print('Tile clicked');
            //           // You can replace the print statement with your function
            //         },
            //         child: ListTile(
            //           leading: Icon(alerts[index]['icon']),
            //           title: Text(alerts[index]['title']),
            //           subtitle: Text(alerts[index]['subtitle']),
            //           trailing: alerts[index]['action'] != null
            //               ? ElevatedButton(
            //                   onPressed: () {
            //                     //print('${alerts[index]['action']} button clicked');
            //                     if (alerts[index]['action'] != null) {
            //                       if (alerts[index]['action'] == "Join") {
            //                         Navigator.of(NavigationService
            //                                 .navigatorKey.currentContext!)
            //                             .push(MaterialPageRoute2(
            //                                 routeName: Routes.message,
            //                                 arguments: "Javis - AI Copilot"));
            //                       } else if (alerts[index]['action'] ==
            //                           "View offer") {
            //                         // showOfferDetailsDialog(context, 2);
            //                         // NavbarNotifier2.hideBottomNavBar = true;
            //                       }
            //                     }
            //                     // You can replace the print statement with your function
            //                   },
            //                   child: Text(Lang.get(alerts[index]['action'])),
            //                 )
            //               : null,
            //         ),
            //       );
            //     });
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

class CustomFollowNotification extends StatefulWidget {
  const CustomFollowNotification(
      {super.key, required this.notificationObject, required this.showTime});
  final NotificationObject notificationObject;
  final bool showTime;

  @override
  State<CustomFollowNotification> createState() =>
      _CustomFollowNotificationState();
}

class _CustomFollowNotificationState extends State<CustomFollowNotification> {
  bool follow = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20, backgroundColor: Colors.blue,
              backgroundImage: Image.network(
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error_outline,
                  size: 45,
                ),
                width: 50,
                height: 50,
                'https://docs.flutter.dev/assets/images/404/dash_nest.png',
                fit: BoxFit.cover,
              ).image,
              // backgroundImage: const AssetImage("assets/imges/Avatar.png"),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(widget.notificationObject.sender.getName,
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(fontSize: 13)),
                      const SizedBox(
                        width: 20,
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: widget.showTime ? 1 : 0,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                              textAlign: TextAlign.center,
                              DateFormat("HH:mm")
                                  .format(widget.notificationObject.createdAt!)
                                  .toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3!
                                  .copyWith(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w300)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  LimitedBox(
                    maxHeight: 200,
                    child: AutoSizeText(widget.notificationObject.content,
                        maxLines: 2,
                        maxFontSize: 10,
                        minFontSize: 9,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText1!),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: RoundedButtonWidget(
                  height: 40,
                  buttonColor: Theme.of(context).colorScheme.primary,
                  buttonTextSize: 10,
                  // textColor: follow == false ? Colors.white : mainText,
                  onPressed: () {
                    setState(() {
                      follow = !follow;
                    });
                  },
                  buttonText: widget.notificationObject.type ==
                          NotificationType.viewOffer
                      ? "View"
                      : "Join",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomLikedNotifcation extends StatefulWidget {
  const CustomLikedNotifcation(
      {super.key, required this.notificationObject, required this.showTime});
  final NotificationObject notificationObject;
  final bool showTime;

  @override
  State<CustomLikedNotifcation> createState() => _CustomLikedNotifcationState();
}

class _CustomLikedNotifcationState extends State<CustomLikedNotifcation> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 8, 8, 8),
        child: Row(
          children: [
            SizedBox(
              height: 80,
              width: 50,
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(
                    widget.notificationObject.type == NotificationType.text
                        ? Icons.text_snippet
                        : Icons.chat,
                    size: 45,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  child: CircleAvatar(
                    radius: 20, backgroundColor: Colors.blue,
                    backgroundImage: Image.network(
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error_outline,
                        size: 45,
                      ),
                      width: 50,
                      height: 50,
                      'https://docs.flutter.dev/assets/images/404/dash_nest.png',
                      fit: BoxFit.cover,
                    ).image,
                    // backgroundImage: AssetImage("assets/imges/Avatar2.png"),
                  ),
                ),
              ]),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    children: [
                      RichText(
                        maxLines: 2,
                        text: TextSpan(
                            text: widget.notificationObject.sender.getName,
                            style: Theme.of(context)
                                .textTheme
                                .headline3!
                                .copyWith(fontSize: 13),
                            children: [
                              TextSpan(
                                text: " and ",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(fontSize: 9),
                              ),
                              const TextSpan(text: "you")
                            ]),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: widget.showTime ? 1 : 0,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                              textAlign: TextAlign.center,
                              DateFormat("HH:mm")
                                  .format(widget.notificationObject.createdAt!)
                                  .toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3!
                                  .copyWith(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w300)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(widget.notificationObject.content,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 10))
                ],
              ),
            ),
            Image.network(
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.error_outline,
                size: 45,
              ),
              "https://docs.flutter.dev/assets/images/404/dash_nest.png",
              height: 64,
              width: 64,
            ),
          ],
        ),
      ),
    );
  }
}
