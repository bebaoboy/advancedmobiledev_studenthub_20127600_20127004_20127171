// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/core/widgets/easy_timeline/easy_date_timeline.dart';
import 'package:boilerplate/core/widgets/easy_timeline/src/easy_infinite_date_time/widgets/easy_infinite_date_timeline_controller.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/dashboard/components/offer_detail_page.dart';
import 'package:boilerplate/presentation/dashboard/dashboard.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/notification/store/notification_store.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/page_transformer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:stacked_notification_cards/stacked_notification_cards.dart';
import 'package:toastification/toastification.dart';
import 'package:badges/badges.dart' as badges;

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

// final List<NotificationObject> alerts = [
//   NotificationObject(
//       type: NotificationType.text,
//       id: "",
//       receiver: StudentProfile(objectId: "", fullName: "student 1"),
//       sender: CompanyProfile(
//         objectId: "",
//         companyName: "company 1",
//       ),
//       content: 'You have submitted to join project "Javis - AI Copilot',
//       createdAt: DateTime.now()),
//   NotificationObject(
//       id: "",
//       receiver: StudentProfile(objectId: "", fullName: "student 1"),
//       sender: CompanyProfile(
//         objectId: "",
//         companyName: "company 1",
//       ),
//       type: NotificationType.joinInterview,
//       content:
//           'You have invited to interview for project "Javis - AI Copilot" at 14:00 March 20, Thursday',
//       createdAt: DateTime.now().subtract(const Duration(days: 7))),
//   OfferNotification(
//       projectId: "",
//       id: "",
//       receiver: StudentProfile(objectId: "", fullName: "student 1"),
//       sender: CompanyProfile(
//         objectId: "",
//         companyName: "company 1",
//       ),
//       content: 'You have submitted to join project "Javis - AI Copilot',
//       createdAt: DateTime.now()),
//   NotificationObject(
//       type: NotificationType.message,
//       id: "",
//       receiver: StudentProfile(objectId: "", fullName: "student 1"),
//       sender: CompanyProfile(
//         objectId: "",
//         companyName: "Alex Jor",
//       ),
//       content: 'I have read your requirement but I dont seem to...?\n6/6/2024',
//       createdAt: DateTime.now()),
//   NotificationObject(
//       type: NotificationType.message,
//       id: "",
//       receiver: StudentProfile(objectId: "", fullName: "student 1"),
//       sender: CompanyProfile(
//         objectId: "",
//         companyName: "Alex Jor",
//       ),
//       content: 'Finish your project?',
//       createdAt: DateTime.now()),
//   NotificationObject(
//       type: NotificationType.message,
//       id: "",
//       receiver: StudentProfile(objectId: "", fullName: "student 1"),
//       sender: CompanyProfile(
//         objectId: "",
//         companyName: "Alex Jor",
//       ),
//       content: 'How are you doing?',
//       createdAt: DateTime.now()),
//   OfferNotification(
//       projectId: "",
//       id: "",
//       receiver: StudentProfile(objectId: "", fullName: "student 1"),
//       sender: CompanyProfile(
//         objectId: "",
//         companyName: "company 1",
//       ),
//       content: 'You have an offer to join project "HCMUS - Administration"',
//       createdAt: DateTime.now()),
//   OfferNotification(
//       projectId: "",
//       id: "",
//       receiver: StudentProfile(objectId: "", fullName: "student 1"),
//       sender: CompanyProfile(
//         objectId: "",
//         companyName: "company 1",
//       ),
//       content: 'You have an offer to join project "Quantum Physics"',
//       createdAt: DateTime.now()),
// ];

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
  var notiStore = getIt<NotificationStore>();

  bool hasOfferProposal = false;

  late Future<List<NotificationObject>> future;

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

  initNotiList() {
    notiStore.categorize(activeDates);
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
    pages = List.filled(activeDates.length, null);

    future = notiStore
        .getNoti(
            receiverId: userStore.user!.objectId ?? "",
            activeDates: activeDates)
        .whenComplete(
      () {
        print("move");
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            alertPageController.move(7, animation: false);
          });
        });
      },
    );

    showTime = List.filled(activeDates.length, true);

    Future.delayed(const Duration(seconds: 1), () {
      // dateController.animateToFocusDate(duration: const Duration(seconds: 1));
    });
    dateStyle = datePickerStyle;
    monthStyle = monthPickerStyle;
    listController =
        List.generate(activeDates.length, (_) => ScrollController());

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
      return Tooltip(
        message: "${getOffer().length} offers",
        padding: const EdgeInsets.symmetric(horizontal: 10),
        verticalOffset: 60,
        child: InkWell(
          child: badges.Badge(
            badgeContent: Text(
              getOffer().length.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            position: badges.BadgePosition.topStart(start: 10, top: -10),
            badgeStyle: badges.BadgeStyle(
                badgeColor: Theme.of(context).colorScheme.primary),
            child: Stack(
              children: [
                for (int index = getOffer().length - 1; index >= 0; index--)
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(
                          left: index == 1 ? 10 : 15,
                          right: index == 2 ? 7 : 15),
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

                            Navigator.of(NavigationService
                                        .navigatorKey.currentContext ??
                                    context)
                                .push(
                              ModalExprollableRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      OfferDetailsDialog(
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
                                                    aboveNavbar:
                                                        !NavbarNotifier2
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
                  ),
              ],
            ),
          ),
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
    print("build date");
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

  late List<Widget?> pages;

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
      FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
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
                  print("build explorable pv");
                  return KeepAlivePage(
                    key: PageStorageKey("alert_$i"),
                    AlertPage(
                      listController: listController[i],
                      joinInterviews: notiStore.joinInterviews![i],
                      viewOffers: notiStore.viewOffers![i],
                      messages: notiStore.messages![i],
                      texts: notiStore.texts![i],
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
            );
          } else {
            return const LoadingScreenWidget();
          }
        },
      )
    ]);
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

class CustomOfferNotification extends StatefulWidget {
  const CustomOfferNotification(
      {super.key, required this.notificationObject, required this.showTime});
  final NotificationObject notificationObject;
  final bool showTime;

  @override
  State<CustomOfferNotification> createState() =>
      _CustomOfferNotificationState();
}

class _CustomOfferNotificationState extends State<CustomOfferNotification> {
  bool follow = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20, backgroundColor: Colors.blue,
              backgroundImage: CachedNetworkImageProvider(
                // errorBuilder: (context, error, stackTrace) => const Icon(
                //   Icons.error_outline,
                //   size: 45,
                // ),
                cacheKey: "flutter",

                maxWidth: 50,
                maxHeight: 50,
                'https://docs.flutter.dev/assets/images/404/dash_nest.png',
                // fit: BoxFit.cover,
              ),
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
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                            textAlign: TextAlign.center,
                            DateFormat("HH:mm - dd/MM")
                                .format(widget.notificationObject.createdAt!)
                                .toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headline3!
                                .copyWith(
                                    fontSize: 9, fontWeight: FontWeight.w300)),
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

class CustomInterviewNotification extends StatefulWidget {
  const CustomInterviewNotification(
      {super.key, required this.notificationObject, required this.showTime});
  final NotificationObject notificationObject;
  final bool showTime;

  @override
  State<CustomInterviewNotification> createState() =>
      _CustomInterviewNotificationState();
}

class _CustomInterviewNotificationState
    extends State<CustomInterviewNotification> {
  bool follow = false;
  InterviewSchedule? interview;
  @override
  void initState() {
    super.initState();
    if (widget.notificationObject.metadata != null) {
      interview =
          InterviewSchedule.fromJsonApi(widget.notificationObject.metadata!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Column(
              children: [
                const CircleAvatar(
                  radius: 20, backgroundColor: Colors.blue,
                  backgroundImage: CachedNetworkImageProvider(
                    // errorBuilder: (context, error, stackTrace) => const Icon(
                    //   Icons.error_outline,
                    //   size: 45,
                    // ),
                    cacheKey: "flutter_interview",

                    maxWidth: 50,
                    maxHeight: 50,
                    'https://m.media-amazon.com/images/I/41VnEemazTL.jpg',
                    // fit: BoxFit.cover,
                  ),
                  // backgroundImage: const AssetImage("assets/imges/Avatar.png"),
                ),
                if (interview != null)
                  interview!.endDate.isBefore(DateTime.now())
                      ? Text(
                          "Ended",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        )
                      : Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: RoundedButtonWidget(
                              height: 40,
                              buttonColor:
                                  Theme.of(context).colorScheme.primary,
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
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                            textAlign: TextAlign.center,
                            DateFormat("HH:mm - dd/MM")
                                .format(widget.notificationObject.createdAt!)
                                .toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headline3!
                                .copyWith(
                                    fontSize: 9, fontWeight: FontWeight.w300)),
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
                  if (interview != null) ...[
                    const SizedBox(
                      height: 5,
                    ),
                    LimitedBox(
                      maxHeight: 200,
                      child: AutoSizeText(interview!.meetingRoomCode,
                          maxLines: 2,
                          maxFontSize: 10,
                          minFontSize: 9,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1!),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    LimitedBox(
                      maxHeight: 200,
                      child: AutoSizeText(interview!.meetingRoomId,
                          maxLines: 2,
                          maxFontSize: 10,
                          minFontSize: 9,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1!),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    LimitedBox(
                      maxHeight: 200,
                      child: AutoSizeText(
                          DateFormat("HH-mm dd/MM/yyyy")
                              .format(interview!.startDate),
                          maxLines: 2,
                          maxFontSize: 10,
                          minFontSize: 9,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1!),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    LimitedBox(
                      maxHeight: 200,
                      child: AutoSizeText(
                          DateFormat("HH-mm dd/MM/yyyy")
                              .format(interview!.endDate),
                          maxLines: 2,
                          maxFontSize: 10,
                          minFontSize: 9,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1!),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomInterviewNotificationWidget extends StatefulWidget {
  const CustomInterviewNotificationWidget(
      {super.key, required this.notificationObject, required this.showTime});
  final NotificationObject notificationObject;
  final bool showTime;

  @override
  State<CustomInterviewNotificationWidget> createState() =>
      _CustomInterviewNotificationWidgetState();
}

class _CustomInterviewNotificationWidgetState
    extends State<CustomInterviewNotificationWidget> {
  bool follow = false;
  InterviewSchedule? interview;
  @override
  void initState() {
    super.initState();
    if (widget.notificationObject.metadata != null) {
      interview =
          InterviewSchedule.fromJsonApi(widget.notificationObject.metadata!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 20, backgroundColor: Colors.blue,
                backgroundImage: CachedNetworkImageProvider(
                  // errorBuilder: (context, error, stackTrace) => const Icon(
                  //   Icons.error_outline,
                  //   size: 45,
                  // ),
                  cacheKey: "flutter_interview",

                  maxWidth: 20,
                  maxHeight: 20,
                  'https://m.media-amazon.com/images/I/41VnEemazTL.jpg',
                  // fit: BoxFit.cover,
                ),
                // backgroundImage: const AssetImage("assets/imges/Avatar.png"),
              ),
              if (interview != null)
                interview!.endDate.isBefore(DateTime.now())
                    ? Text(
                        "Ended",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary),
                      )
                    : Align(
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
                const Positioned(
                  bottom: 10,
                  child: CircleAvatar(
                    radius: 20, backgroundColor: Colors.blue,
                    backgroundImage: CachedNetworkImageProvider(
                      // errorBuilder: (context, error, stackTrace) => const Icon(
                      //   Icons.error_outline,
                      //   size: 45,
                      // ),
                      cacheKey: "flutter",
                      maxWidth: 50,
                      maxHeight: 50,
                      'https://docs.flutter.dev/assets/images/404/dash_nest.png',
                      // fit: BoxFit.cover,
                    ),
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
                  Row(
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
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                            textAlign: TextAlign.center,
                            DateFormat("HH:mm - dd/MM")
                                .format(widget.notificationObject.createdAt!)
                                .toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headline3!
                                .copyWith(
                                    fontSize: 9, fontWeight: FontWeight.w300)),
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
            // CachedNetworkImage(
            //   errorWidget: (context, error, stackTrace) => const Icon(
            //     Icons.error_outline,
            //     size: 45,
            //   ),
            //   cacheKey: "flutter",
            //   width: 50,
            //   height: 50,
            //   imageUrl:
            //       'https://docs.flutter.dev/assets/images/404/dash_nest.png',
            //   fit: BoxFit.cover,
            // ),
          ],
        ),
      ),
    );
  }
}

class AlertPage extends StatefulWidget {
  final ScrollController listController;
  final List<NotificationObject> viewOffers, texts, messages, joinInterviews;

  const AlertPage(
      {super.key,
      required this.listController,
      required this.viewOffers,
      required this.joinInterviews,
      required this.messages,
      required this.texts});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  @override
  Widget build(BuildContext context) {
    print("build Page");
    return Observer(builder: (context) {
      return SingleChildScrollView(
        controller: widget.listController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 13),
              child: Text(
                "Interview",
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            widget.joinInterviews.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(left: 13),
                    child: Text("Nothing here <3"),
                  )
                : ImplicitlyAnimatedList<NotificationObject>(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    areItemsTheSame: (oldItem, newItem) =>
                        oldItem.id == newItem.id,
                    items: widget.joinInterviews,
                    itemBuilder: (context, animation, item, i) =>
                        SizeFadeTransition(
                            sizeFraction: 0.7,
                            curve: Curves.easeInOut,
                            animation: animation,
                            child: CustomInterviewNotification(
                              notificationObject: widget.joinInterviews[i],
                              showTime: false,
                            ))),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 13),
              child: Text(
                "Offer",
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            widget.viewOffers.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(left: 13),
                    child: Text("Nothing here <3"),
                  )
                : ImplicitlyAnimatedList<NotificationObject>(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    areItemsTheSame: (oldItem, newItem) =>
                        oldItem.id == newItem.id,
                    items: widget.viewOffers,
                    itemBuilder: (context, animation, item, i) =>
                        SizeFadeTransition(
                            sizeFraction: 0.7,
                            curve: Curves.easeInOut,
                            animation: animation,
                            child: CustomInterviewNotification(
                              notificationObject: widget.viewOffers[i],
                              showTime: false,
                            ))),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 13),
              child: Text(
                "Newest",
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            widget.texts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(left: 13),
                    child: Text("Nothing here <3"),
                  )
                : ImplicitlyAnimatedList<NotificationObject>(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    areItemsTheSame: (oldItem, newItem) =>
                        oldItem.id == newItem.id,
                    items: widget.texts,
                    itemBuilder: (context, animation, item, i) =>
                        SizeFadeTransition(
                            sizeFraction: 0.7,
                            curve: Curves.easeInOut,
                            animation: animation,
                            child: CustomInterviewNotification(
                              notificationObject: widget.texts[i],
                              showTime: false,
                            ))),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 13),
              child: Text(
                "Message",
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            widget.messages.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(left: 13),
                    child: Text("Nothing here <3"),
                  )
                // : SingleChildScrollView(
                //     child: StackedNotificationCards(
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withOpacity(0.25),
                //           blurRadius: 2.0,
                //         )
                //       ],

                //       notificationCards: widget.messages
                //           .map((e) => NotificationCard(
                //               date: e.createdAt!,
                //               title: e.title,
                //               subtitle: e.content,
                //               leading: CustomInterviewNotificationWidget(
                //                 notificationObject: e,
                //                 showTime: false,
                //               )))
                //           .toList(),
                //       cardColor: const Color(0xFFF1F1F1),
                //       padding: 16,
                //       actionTitle: Container(),
                //       notificationCardTitle: 'Notification tile',
                //       titleTextStyle: const TextStyle(
                //         fontSize: 12,
                //         fontWeight: FontWeight.bold,
                //       ),
                //       showLessAction: const Text(
                //         'Show less',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.deepPurple,
                //         ),
                //       ),
                //       onTapClearAll: () {
                //         // setState(() {
                //         //   _listOfNotification.clear();
                //         // });
                //       },
                //       subtitleTextStyle: TextStyle(fontSize: 8),
                //       cardClearButton: const Text('Clear All'),
                //       cardViewButton: const Text('View'),
                //       clearAllNotificationsAction: const Icon(Icons.close),
                //       clearAllStacked: const Text('Clear All'),
                //       onTapClearCallback: (index) {
                //         print(index);
                //         // setState(() {
                //         //   _listOfNotification.removeAt(index);
                //         // });
                //       },
                //       onTapViewCallback: (index) {
                //         print(index);
                //       },
                //     ),
                //   ),

                : ImplicitlyAnimatedList<NotificationObject>(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    areItemsTheSame: (oldItem, newItem) =>
                        oldItem.id == newItem.id,
                    items: widget.messages,
                    itemBuilder: (context, animation, item, i) =>
                        SizeFadeTransition(
                      sizeFraction: 0.7,
                      curve: Curves.easeInOut,
                      animation: animation,
                      child: CustomInterviewNotification(
                        notificationObject: widget.messages[i],
                        showTime: false,
                      ),
                    ),
                  ),
          ],
        ),
      );
    });
  }
}
