// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'dart:math';

import 'package:boilerplate/domain/entity/project/proposal_list.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';
import 'package:boilerplate/presentation/video_call/managers/call_manager.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:choice/choice.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
// ignore: depend_on_referenced_packages
import 'package:sliver_tools/sliver_tools.dart';
import 'dart:math' as math;

// import 'options/grouped_scroll_view_options.dart';
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
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/notification/store/notification_store.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/page_transformer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:grouped_scroll_view/grouped_scroll_view.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import 'package:badges/badges.dart' as badges;
// ignore: implementation_imports
import 'package:flutter_floating_bottom_bar/src/bottom_bar_scroll_controller_provider.dart';

/// [width] & [height] can be used to animate the size of the back to top icon.
/// You can also not use them to keep your icon a constant size.
typedef BackToTopIconBuilder = Widget Function(double width, double height);

/// A floating bottom navigation bar that hides on scroll
/// up and down on the page, with powerful options
/// for controlling the look and feel.
class BottomBar extends StatefulWidget {
  /// The widget displayed below the `BottomBar`.
  ///
  /// This is useful, if the `BottomBar` should react
  /// to scroll events (i.e. hide from view when a [Scrollable]
  /// is being scrolled down and show it again when scrolled up).
  ///
  /// For that, use this exposed `ScrollController` and
  /// you can also add listeners on this `ScrollController`.
  final Widget Function(BuildContext context, ScrollController controller) body;

  ///
  /// This is the child inside the `BottomBar`.
  /// Add a TabBar or any other thing that you want to be floating here.
  final Widget child;

  ///
  /// This is the scroll to top button. It will be hidden when the
  /// `BottomBar` is scrolled up. It will be shown when the `BottomBar`
  /// is scrolled down. Clicking it will scroll the bar on top.
  ///
  /// You can hide this by using the `showIcon` property.
  ///
  /// `width` & `height` can be used to animate the size of the back to top icon.
  /// You can also not use them to keep your icon a constant size.
  final BackToTopIconBuilder? icon;

  ///
  /// The width of the scroll to top button.
  final double iconWidth;

  ///
  /// The height of the scroll to top button.
  final double iconHeight;

  ///
  /// The color of the `BottomBar`.
  final Color barColor;

  ///
  /// The BoxDecoration for the `BottomBar`.
  final BoxDecoration? barDecoration;

  ///
  /// The BoxDecoration for the scroll to top icon shown when `BottomBar` is hidden.
  final BoxDecoration? iconDecoration;

  ///
  /// The end position in `y-axis` of the SlideTransition of the `BottomBar`.
  final double end;

  ///
  /// The start position in `y-axis` of the SlideTransition of the `BottomBar`.
  final double start;

  ///
  /// The padding/offset from all sides of the bar in double.
  final double offset;

  ///
  /// The duration of the `SlideTransition` of the `BottomBar`.
  final Duration duration;

  ///
  /// The curve of the `SlideTransition` of the `BottomBar`.
  final Curve curve;

  ///
  /// The width of the `BottomBar`.
  final double width;

  ///
  /// The border radius of the `BottomBar`.
  final BorderRadius borderRadius;

  ///
  /// If you don't want the scroll to top button to be visible,
  /// set this to `false`.
  final bool showIcon;

  ///
  /// The alignment of the Stack in which the `BottomBar` is placed.
  final Alignment alignment;

  ///
  /// The alignment of the Bar and the icon in the Stack in which the `BottomBar` is placed.
  final Alignment barAlignment;

  ///
  /// The callback when the `BottomBar` is shown i.e. on response to scroll events.
  final Function()? onBottomBarShown;

  ///
  /// The callback when the `BottomBar` is hidden i.e. on response to scroll events.
  final Function()? onBottomBarHidden;

  ///
  /// To reverse the direction in which the scroll reacts, i.e. if you want to make
  /// the bar visible when you scroll down and hide it when you scroll up, set this
  /// to `true`.
  final bool reverse;

  ///
  /// To reverse the direction in which the scroll to top button scrolls, i.e. if
  /// you want to scroll to bottom, set this to `true`.
  final bool scrollOpposite;

  ///
  /// If you don't want the bar to be hidden ever, set this to `false`.
  final bool hideOnScroll;

  ///
  /// The fit property of the `Stack` in which the `BottomBar` is placed.
  final StackFit fit;

  ///
  /// The clipBehaviour property of the `Stack` in which the `BottomBar` is placed.
  final Clip clip;

  const BottomBar({
    required this.body,
    required this.child,
    this.icon,
    this.iconWidth = 30,
    this.iconHeight = 30,
    this.barColor = Colors.black,
    this.barDecoration,
    this.iconDecoration,
    this.end = 0,
    this.start = 2,
    this.offset = 10,
    this.duration = const Duration(milliseconds: 120),
    this.curve = Curves.linear,
    this.width = 300,
    this.borderRadius = BorderRadius.zero,
    this.showIcon = true,
    @Deprecated(
        'Use barAlignment instead, this will be removed in a future release')
    this.alignment = Alignment.bottomCenter,
    this.barAlignment = Alignment.bottomCenter,
    this.onBottomBarShown,
    this.onBottomBarHidden,
    this.reverse = false,
    this.scrollOpposite = false,
    this.hideOnScroll = true,
    this.fit = StackFit.loose,
    this.clip = Clip.hardEdge,
    super.key,
  });

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  ScrollController scrollBottomBarController = ScrollController();
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late bool isScrollingDown;
  late bool isOnTop;

  @override
  void initState() {
    isScrollingDown = widget.reverse;
    isOnTop = !widget.reverse;
    myScroll();
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, widget.start),
      end: Offset(0, widget.end),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ))
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    _controller.forward();
    NavbarNotifier2.bottomNavbarVisibilityListener.addListener(hide);
  }

  hide() {
    try {
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      ///
    }
  }

  void showBottomBar() {
    if (mounted) {
      setState(() {
        _controller.forward();
      });
    }
    NavbarNotifier2.hideBottomNavBar = false;
    if (widget.onBottomBarShown != null) widget.onBottomBarShown!();
  }

  void hideBottomBar() {
    if (mounted && widget.hideOnScroll) {
      setState(() {
        _controller.reverse();
      });
    }
    NavbarNotifier2.hideBottomNavBar = true;

    if (widget.onBottomBarHidden != null) widget.onBottomBarHidden!();
  }

  Future<void> myScroll() async {
    scrollBottomBarController.addListener(() {
      if (scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        isScrollingDown = true;
        isOnTop = false;
        showBottomBar();
      } else if (scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.forward) {
        isScrollingDown = true;
        isOnTop = false;
        showBottomBar();
      }
    });
  }

  @override
  void dispose() {
    scrollBottomBarController.removeListener(() {});
    NavbarNotifier2.bottomNavbarVisibilityListener.removeListener(hide);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: widget.fit,
      alignment: widget.alignment,
      clipBehavior: widget.clip,
      children: [
        BottomBarScrollControllerProvider(
          scrollController: scrollBottomBarController,
          child: widget.body(context, scrollBottomBarController),
        ),
        if (widget.showIcon)
          Align(
            alignment: widget.barAlignment,
            child: Container(
              padding: EdgeInsets.all(widget.offset),
              child: AnimatedOpacity(
                duration: widget.duration,
                curve: widget.curve,
                opacity: isOnTop == true ? 0 : 1,
                child: AnimatedContainer(
                  margin: EdgeInsets.only(
                      bottom: NavbarNotifier2.isNavbarHidden ? 0 : 60),
                  duration: widget.duration,
                  curve: widget.curve,
                  width: isOnTop == true ? 0 : widget.iconWidth,
                  height: isOnTop == true ? 0 : widget.iconHeight,
                  decoration: widget.iconDecoration ??
                      BoxDecoration(
                        color: widget.barColor,
                        shape: BoxShape.circle,
                      ),
                  padding: EdgeInsets.zero,
                  child: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          NavbarNotifier2.hideBottomNavBar = false;

                          scrollBottomBarController
                              .animateTo(
                            (!widget.scrollOpposite)
                                ? scrollBottomBarController
                                    .position.minScrollExtent
                                : scrollBottomBarController
                                    .position.maxScrollExtent,
                            duration: widget.duration,
                            curve: widget.curve,
                          )
                              .then((value) {
                            if (mounted) {
                              setState(() {
                                isOnTop = true;
                                isScrollingDown = false;
                              });
                            }
                            showBottomBar();
                          });
                        },
                        child: () {
                          if (widget.icon != null) {
                            return widget.icon!(
                                isOnTop == true ? 0 : widget.iconWidth / 2,
                                isOnTop == true ? 0 : widget.iconHeight / 2);
                          } else {
                            return Center(
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: null,
                                icon: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Colors.white,
                                  size: isOnTop == true
                                      ? 0
                                      : widget.iconWidth / 2,
                                ),
                              ),
                            );
                          }
                        }(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Align(
          alignment: widget.barAlignment,
          child: Padding(
            padding: EdgeInsets.all(widget.offset),
            child: SlideTransition(
              position: _offsetAnimation,
              child: Container(
                width: widget.width,
                decoration: widget.barDecoration ??
                    BoxDecoration(
                      color: widget.barColor,
                      borderRadius: widget.borderRadius,
                    ),
                child: Material(
                  color: widget.barColor,
                  borderRadius: widget.borderRadius,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
  var userStore = getIt<UserStore>();
  var notiStore = getIt<NotificationStore>();

  bool hasOfferProposal = false;

  late Future<List<NotificationObject>?> future;

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
        .addAll([for (int i = -14; i < 14; i++) today.add(Duration(days: i))]);
    print(activeDates);
    pages = List.filled(activeDates.length, null);

    future = notiStore
        .getNoti(
            receiverId: userStore.user!.objectId ?? "",
            activeDates: activeDates,
            setStateCb: () {
              setState(() {
                print("move");
                Future.delayed(const Duration(milliseconds: 500), () {
                  setState(() {
                    alertPageController.move(activeDates.length ~/ 2,
                        animation: false);
                  });
                });
              });
            })
        .whenComplete(
          () {},
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

  ScrollController myController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BottomBar(
      icon: (width, height) {
        return const Icon(
          Icons.arrow_upward,
          color: Colors.white,
        );
      },
      onBottomBarHidden: () => print("hidden"),
      onBottomBarShown: () => print("show"),
      hideOnScroll: false,
      scrollOpposite: false,
      showIcon: true,
      body: (context, controller) => Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: _buildAlertsContent(controller)),
      child: const SizedBox(
        height: 0,
        width: 0,
      ),
    );
  }

  var projectStore = getIt<ProjectStore>();
  var topRowController = ScrollController();

  openOfferPage(index) {
    if (userStore.user != null && userStore.user!.type != UserType.student) {
      return;
    }
    print(index);
    NavbarNotifier2.hideBottomNavBar = true;

    Navigator.of(NavigationService.navigatorKey.currentContext ?? context)
        .push(
      ModalExprollableRouteBuilder(
          pageBuilder: (_, __, ___) => OfferDetailsDialog(
                index: index,
                proposal: getOffer(),
                onAcceptCallback: (proposal) {
                  var userStore = getIt<UserStore>();
                  var id = userStore.user?.studentProfile?.objectId;
                  if (id != null && proposal != null) {
                    projectStore.updateProposal(proposal, id).then(
                      (value) {
                        Toastify.show(
                            context,
                            "",
                            "Succeed!",
                            aboveNavbar: !NavbarNotifier2.isNavbarHidden,
                            ToastificationType.success,
                            () {});
                        setState(() {});
                      },
                    );
                  }
                },
              ),
          // Increase the transition durations and take a closer look at what's going on!
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          // The next two lines are not required, but are recommended for better performance.
          dismissThresholdInset:
              const DismissThresholdInset(dragMargin: 10000)),
    )
        .then(
      (value) {
        NavbarNotifier2.hideBottomNavBar = false;
      },
    );
  }

  Widget _buildTopRowList() {
    if (hasOfferProposal && userStore.user!.type == UserType.student) {
      return Observer(builder: (context) {
        return Tooltip(
          message: userStore.user!.type == UserType.student
              ? "${getOffer().length} offers"
              : "",
          padding: const EdgeInsets.symmetric(horizontal: 10),
          verticalOffset: 60,
          child: InkWell(
            child: badges.Badge(
              badgeContent: Text(
                getOffer().length.toString(),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              showBadge: getOffer().isNotEmpty &&
                  userStore.user!.type == UserType.student,
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
                              openOfferPage(index);
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
      });
        ),
      );
    } else {
      return Container();
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
            todayNumStyle:
                TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            inactiveDayNumStyle:
                TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            inactiveDayStyle: DayStyle(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  color: Theme.of(context).colorScheme.onBackground),
            ),
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
  }

  late List<Widget?> pages;
  BuildContext? cc;

  Widget _buildAlertsContent(myController) {
    return CustomScrollView(controller: myController, slivers: [
      SliverToBoxAdapter(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                height: 108,
                width: userStore.user!.type == UserType.student ? 120 : 0,
                margin: const EdgeInsets.only(
                  top: 2,
                ),
                child: _buildTopRowList()),
            Container(
                margin: const EdgeInsets.only(top: 10, left: 0),
                height: 110,
                width: userStore.user!.type == UserType.student
                    ? MediaQuery.of(context).size.width - 150
                    : MediaQuery.of(context).size.width - 20,
                child: _datePickerSection()),
          ],
        ),
      ),
      SliverToBoxAdapter(
        child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return notiStore.isLoading && notiStore.notiList.isEmpty
                  ? const LoadingScreenWidget()
                  : Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: TransformerPageView(
                        itemCount: activeDates.length,
                        index: 14, // middle page
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
                          cc = context;
                          // print("build explorable pv");
                          return KeepAlivePage(
                            key: PageStorageKey("alert_$i"),
                            AlertPage(
                              openOfferPage: () {
                                openOfferPage(0);
                              },
                              listController: listController[i],
                              joinInterviews: notiStore.joinInterviews![i],
                              viewOffers: notiStore.viewOffers![i],
                              messages: notiStore.messages![i],
                              texts: notiStore.texts![i],
                            ),
                          );

                          
                        },
                      ),
                    );

            } else {
              return const LoadingScreenWidget();
            }
          },
        ),
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

class CustomProposalNotification extends StatefulWidget {
  const CustomProposalNotification(
      {super.key,
      required this.notificationObject,
      required this.showTime,
      required this.openOfferPage});
  final NotificationObject notificationObject;
  final bool showTime;
  final Function openOfferPage;

  @override
  State<CustomProposalNotification> createState() =>
      _CustomProposalNotificationState();
}

class _CustomProposalNotificationState
    extends State<CustomProposalNotification> {
  bool follow = false;
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
                widget.notificationObject.type == NotificationType.proposal
                    ? const CircleAvatar(
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
                      )
                    : const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.mail_lock,
                          size: 45,
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
                      onPressed: () async {
                        var userStore = getIt<UserStore>();
                        if (widget.notificationObject.type ==
                            NotificationType.proposal) {
                              // cty nhận thbao student đã nộp proposal
                          var proposal = widget.notificationObject.metadata!;
                          var projectStore = getIt<ProjectStore>();
                          if (userStore.user!.type == UserType.company &&
                              projectStore.companyProjects.isEmpty) {
                            await projectStore.getProjectByCompany(
                                userStore.user!.companyProfile!.objectId!);
                          }
                          if (projectStore.companyProjects.isNotEmpty) {
                            print("");
                            var project =
                                projectStore.companyProjects.firstWhereOrNull(
                              (element) =>
                                  element.objectId ==
                                  proposal["projectId"].toString(),
                            );
                            if (project != null) {
                              projectStore.currentProps =
                                  ProposalList(proposals: project.proposal);
                              Navigator.of(NavigationService
                                      .navigatorKey.currentContext!)
                                  .push(MaterialPageRoute2(
                                      routeName:
                                          "${Routes.projectDetails}/${proposal["projectId"]}",
                                      arguments: {
                                    "project": project,
                                    "index": -1
                                  }));
                            }
                          }
                        } else {
                          if (userStore.user!.type == UserType.student) {
                            // student xem offer
                            widget.openOfferPage();
                          } else {
                            // cty nhận dc thbao offer đã dc accept
                            var proposal = widget.notificationObject.metadata!;
                            var projectStore = getIt<ProjectStore>();

                            await projectStore.getProjectByCompany(
                                userStore.user!.companyProfile!.objectId!);
                            if (projectStore.companyProjects.isNotEmpty) {
                              print("");
                              var project =
                                  projectStore.companyProjects.firstWhereOrNull(
                                (element) =>
                                    element.objectId ==
                                    proposal["projectId"].toString(),
                              );
                              if (project != null) {
                                projectStore.currentProps =
                                    ProposalList(proposals: project.proposal);
                                Navigator.of(NavigationService
                                        .navigatorKey.currentContext!)
                                    .push(MaterialPageRoute2(
                                        routeName:
                                            "${Routes.projectDetails}/${proposal["projectId"]}",
                                        arguments: {
                                      "project": project,
                                      "index": 3
                                    }));
                              }
                            }

                          }
                        }
                      },
                      buttonText: widget.notificationObject.type ==
                              NotificationType.proposal
                          ? "View"
                          : "Check",
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
                  const SizedBox(
                    height: 5,
                  ),
                  LimitedBox(
                    maxHeight: 200,
                    child: AutoSizeText(
                        "Project id${widget.notificationObject.metadata!["projectId"]}",
                        maxLines: 2,
                        maxFontSize: 10,
                        minFontSize: 9,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText1!),
                  ),
                ],
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
      {super.key,
      required this.notificationObject,
      required this.showTime,
      required this.enterInterview});
  final NotificationObject notificationObject;
  final bool showTime;
  final Function enterInterview;

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
                      : interview!.isCancel
                          ? Text(
                              "Canceled",
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
                                      // follow = !follow;
                                      widget.enterInterview();
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
                    // ignore: prefer_interpolation_to_compose_strings
                    child: AutoSizeText(
                        "${widget.notificationObject.title}: ${widget.notificationObject.metadata!["title"]}",
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

class CustomMessageNotifcation extends StatefulWidget {
  const CustomMessageNotifcation(
      {super.key, required this.notificationObject, required this.showTime});
  final NotificationObject notificationObject;
  final bool showTime;

  @override
  State<CustomMessageNotifcation> createState() =>
      _CustomMessageNotifcationState();
}

class _CustomMessageNotifcationState extends State<CustomMessageNotifcation> {
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
                    widget.notificationObject.type == NotificationType.proposal
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
          ],
        ),
      ),
    );
  }
}

class AlertPage extends StatefulWidget {
  final ScrollController listController;
  final List<NotificationObject> viewOffers, texts, messages, joinInterviews;
  final Function openOfferPage;

  const AlertPage(
      {super.key,
      required this.listController,
      required this.viewOffers,
      required this.joinInterviews,
      required this.messages,
      required this.texts,
      required this.openOfferPage});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  var notiStore = getIt<NotificationStore>();
  var currentNotiType = NotificationType.viewOffer;
  var userStore = getIt<UserStore>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: widget.joinInterviews.isEmpty &&
              widget.viewOffers.isEmpty &&
              widget.texts.isEmpty &&
              widget.messages.isEmpty
          ? Center(
              child: Text(
                Lang.get("nothing_here"),
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            )
          : Observer(builder: (context) {
              return GroupedScrollView<NotificationObject,
                  NotificationType>.list(
                onChipChanged: (p0) {
                  setState(() {
                    currentNotiType = p0;
                  });
                },
                chipsValue: ChoiceSingle.value(currentNotiType),
                observerController:
                    SliverObserverController(controller: widget.listController),
                scrollController: widget.listController,
                itemAtIndex: (index, total, groupedIndex) {},
                groupedOptions: GroupedScrollViewOptions(
                    itemGrouper: (NotificationObject person) {
                      return person.type;
                    },
                    stickyHeaderSorter: (a, b) {
                      return a.index.compareTo(b.index);
                    },
                    stickyHeaderBuilder: (BuildContext context,
                            NotificationType year, int groupedIndex) =>
                        Container(
                          color: Theme.of(context).colorScheme.background,
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            year.title,
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        )),
                itemBuilder: (BuildContext context, NotificationObject item) {
                  return switch (item.type) {
                    NotificationType.viewOffer => CustomProposalNotification(
                        openOfferPage: widget.openOfferPage,
                        notificationObject: item,
                        showTime: false,
                      ),
                    NotificationType.joinInterview =>
                      CustomInterviewNotification(
                        enterInterview: () async {
                          if (item.metadata != null) {
                            CallManager.instance.startPreviewMeeting(
                                NavigationService.navigatorKey.currentContext ??
                                    context,
                                CallType.VIDEO_CALL,
                                {int.parse(item.sender.objectId!)},
                                InterviewSchedule.fromJsonApi(item.metadata!));
                          }
                        },
                        notificationObject: item,
                        showTime: false,
                      ),
                    NotificationType.proposal => CustomProposalNotification(
                        openOfferPage: () => widget.openOfferPage(),
                        notificationObject: item,
                        showTime: false,
                      ),
                    NotificationType.message => CustomMessageNotifcation(
                        notificationObject: item,
                        showTime: false,
                      ),
                  };
                },
                data: [
                  ...widget.joinInterviews,
                  ...widget.viewOffers,
                  ...widget.messages,
                  ...widget.texts
                ],
              );
            }),
    );
  }
}

int kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;

typedef HeaderBuilder = Widget Function(BuildContext context);
typedef FooterBuilder = Widget Function(BuildContext context);
typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);
typedef ItemAtIndex<T> = void Function(int index, int total, int groupedIndex);

@immutable
// ignore: must_be_immutable
class GroupedScrollView<T, H> extends StatelessWidget {
  /// data
  final List<T> data;

  /// Header
  final HeaderBuilder? headerBuilder;

  /// Footer
  final FooterBuilder? footerBuilder;

  /// Optional [Function] that helps sort the groups by comparing the [T] items.
  final Comparator<T>? itemsSorter;

  /// itemBuilder
  final ItemBuilder<T> itemBuilder;

  /// ItemAtIndex
  final ItemAtIndex? itemAtIndex;

  /// The delegate that controls the size and position of the children.
  final SliverGridDelegate? gridDelegate;

  /// findChildIndexCallback for [SliverChildBuilderDelegate].
  final ChildIndexGetter? findChildIndexCallback;

  /// AutomaticKeepAlive for [SliverChildBuilderDelegate].
  final bool addAutomaticKeepAlives;

  /// addRepaintBoundaries for [SliverChildBuilderDelegate].
  final bool addRepaintBoundaries;

  /// addSemanticIndexes for [SliverChildBuilderDelegate].
  final bool addSemanticIndexes;

  /// semanticIndexOffset for [SliverChildBuilderDelegate].
  final int semanticIndexOffset;

  /// semanticIndexCallback for [SliverChildBuilderDelegate].
  final SemanticIndexCallback semanticIndexCallback;

  /// scrollDirection for [CustomScrollView]
  final Axis scrollDirection;

  /// reverse for [CustomScrollView]
  final bool reverse;

  /// controller for [CustomScrollView]
  final ScrollController? scrollController;

  /// primary for [CustomScrollView]
  final bool? primary;

  /// physics for [CustomScrollView]
  final ScrollPhysics? physics;

  /// scrollBehavior for [CustomScrollView]
  final ScrollBehavior? scrollBehavior;

  /// shrinkWrap for [CustomScrollView]
  final bool shrinkWrap;

  /// center for [CustomScrollView]
  final Key? center;

  /// anchor for [CustomScrollView]
  final double anchor;

  /// cacheExtent for [CustomScrollView]
  final double? cacheExtent;

  /// semanticChildCount for [CustomScrollView]
  final int? semanticChildCount;

  /// dragStartBehavior for [CustomScrollView]
  final DragStartBehavior dragStartBehavior;

  /// keyboardDismissBehavior for [CustomScrollView]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// restorationId for [CustomScrollView]
  final String? restorationId;

  /// clipBehavior for [CustomScrollView]
  final Clip clipBehavior;

  /// separatorBuilder for [List]
  final IndexedWidgetBuilder? separatorBuilder;

  /// Grouped by groupedOptions.
  final GroupedScrollViewOptions<T, H>? groupedOptions;

  GroupedScrollView({
    super.key,
    required this.data,
    this.headerBuilder,
    this.footerBuilder,
    required this.itemBuilder,
    this.itemAtIndex,
    this.itemsSorter,

    /// grid
    this.gridDelegate,

    /// list
    this.separatorBuilder,

    /// grouped
    this.groupedOptions,

    /// SliverChildBuilderDelegate
    this.findChildIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback = kDefaultSemanticIndexCallback,
    this.semanticIndexOffset = 0,

    /// CustomScrollView
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.scrollBehavior,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    required this.observerController,
    required this.chipsValue,
    required this.onChipChanged,
  });

  GroupedScrollView.grid({
    super.key,
    required this.data,
    required this.itemBuilder,
    required this.gridDelegate,
    this.headerBuilder,
    this.footerBuilder,
    this.itemsSorter,
    this.itemAtIndex,

    /// grouped
    this.groupedOptions,

    /// SliverChildBuilderDelegate
    this.findChildIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback = kDefaultSemanticIndexCallback,
    this.semanticIndexOffset = 0,

    /// CustomScrollView
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.scrollBehavior,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    required this.observerController,
    required this.chipsValue,
    required this.onChipChanged,
  }) : separatorBuilder = null;

  GroupedScrollView.list({
    super.key,
    required this.data,
    required this.itemBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.itemsSorter,
    this.itemAtIndex,
    this.separatorBuilder,

    /// grouped
    this.groupedOptions,

    /// SliverChildBuilderDelegate
    this.findChildIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback = kDefaultSemanticIndexCallback,
    this.semanticIndexOffset = 0,

    /// CustomScrollView
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.scrollBehavior,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    required this.observerController,
    required this.chipsValue,
    required this.onChipChanged,
  }) : gridDelegate = null;
  final SliverObserverController observerController;

  @override
  Widget build(BuildContext context) {
    return SliverViewObserver(
      controller: observerController,
      child: CustomScrollView(
        key: key,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: scrollController,
        primary: primary,
        physics: physics,
        scrollBehavior: scrollBehavior,
        shrinkWrap: shrinkWrap,
        center: center,
        anchor: anchor,
        cacheExtent: cacheExtent,
        semanticChildCount: semanticChildCount,
        dragStartBehavior: dragStartBehavior,
        keyboardDismissBehavior: keyboardDismissBehavior,
        restorationId: restorationId,
        clipBehavior: clipBehavior,
        slivers: null != groupedOptions
            ? _buildGroupMode(context)
            : _buildNormalMode(context),
      ),
      // sliverListContexts: () {
      //   return realKeys!.map((e) => e.currentContext!).toList();
      // },
    );
  }

  final Function(H) onChipChanged;

  List<Widget> _buildNormalMode(BuildContext context) {
    if (itemsSorter != null) {
      data.sort(itemsSorter);
    }
    List<Widget> section = [];
    if (null != headerBuilder) {
      section.add(SliverToBoxAdapter(child: headerBuilder!(context)));
    }
    section.add(null != gridDelegate
        ? SliverGrid(
            delegate: _buildSliverChildDelegate(data, 0),
            gridDelegate: gridDelegate!)
        : SliverList(delegate: _buildSliverChildDelegate(data, 0)));
    if (null != footerBuilder) {
      section.add(SliverToBoxAdapter(
        child: footerBuilder!(context),
      ));
    }
    return section;
  }

  List<BuildContext?>? realKeys = [];
  final List<NotificationType> chipsValue;
  var userStore = getIt<UserStore>();

  List<Widget> _buildGroupMode(BuildContext context) {
    final options = groupedOptions!;
    List<Widget> slivers = [];
    Map<H, List<T>> groupItems = groupBy(data, options.itemGrouper);
    groupItems.putIfAbsent(NotificationType.joinInterview as H, () => []);
    if (userStore.user!.type == UserType.student) {
      groupItems.putIfAbsent(NotificationType.viewOffer as H, () => []);
    }
    if (userStore.user!.type == UserType.company) {
      groupItems.putIfAbsent(NotificationType.proposal as H, () => []);
    }
    groupItems.putIfAbsent(NotificationType.message as H, () => []);
    groupItems.removeWhere(
      (key, value) => groupItems[key]!.isEmpty,
    );
    List<H> keys = groupItems.keys.toList();
    if (options.stickyHeaderSorter != null) {
      keys.sort(options.stickyHeaderSorter);
    }
 
    realKeys = List.generate(keys.length, (i) => null);
    final groups = keys.length;
    // print("build chips");
    // TODO: chips are always built = not good
    slivers.add(SliverPinnedHeader(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Choice<NotificationType>.inline(
          clearable: false,
          value: chipsValue,
          onChanged: ChoiceSingle.onChanged((t) {
            if (t != null) {
              print(t);
              // Scrollable.ensureVisible(
              //   realKeys![t.index].currentContext!,
              //   duration: const Duration(seconds: 1),
              // );
              onChipChanged(t as H);
              // chipsValue = ChoiceSingle.value(t);
              // print(realKeys);
              var k = keys
                  .indexWhere((e) => (e as NotificationType).title == t.title);
              if (k == -1) {
                scrollController?.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                observerController.animateTo(
                  sliverContext: realKeys![k],
                  index: 0,
                  offset: (t) => 140,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          }),
          itemCount: realKeys!.length,
          itemBuilder: (state, i) {
            return ChoiceChip(
              selectedColor: Colors.redAccent.shade100,
              selected: state.selected((groupItems.keys.firstWhere(
                      (element) => element == (keys[i] as NotificationType))
                  as NotificationType)),
              onSelected: state.onSelected((groupItems.keys.firstWhere(
                      (element) => element == (keys[i] as NotificationType))
                  as NotificationType)),
              label: Text((groupItems.keys.firstWhere(
                          (element) => element == (keys[i] as NotificationType))
                      as NotificationType)
                  .title),
            );
          },
          listBuilder: ChoiceList.createScrollable(
            spacing: 2,
            padding: const EdgeInsets.symmetric(
              vertical: 20,
            ),
          ),
        ),
      ),
    ));

    for (var i = 0; i < groups; i++) {
      H header = keys[i];
      List<T> items = groupItems[header]!;
      if (itemsSorter != null) {
        items.sort(itemsSorter);
      }
      List<Widget> section = [];
      if (0 == i && null != headerBuilder) section.add(headerBuilder!(context));
      section.add(SliverPinnedHeader(
        // key: realKeys![i],
        child: options.stickyHeaderBuilder(context, header, i),
      ));
      section.add(null != gridDelegate
          ? SliverGrid(
              delegate: _buildSliverChildDelegate(items, i),
              gridDelegate: gridDelegate!)
          : SliverList(delegate: _buildSliverChildDelegate(items, i)));
      if (items.isEmpty) {
        section.add(const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(13),
            child: Text("Nothing here <3"),
          ),
        ));
      }
      if (options.sectionFooterBuilder != null) {
        section.add(options.sectionFooterBuilder!(context, header, i));
      }
      if (groups - 1 == i && null != footerBuilder) {
        section.add(footerBuilder!(context));
      }
      slivers.add(
          MultiSliver(key: key, pushPinnedChildren: true, children: section));
    }
    return slivers;
  }

  SliverChildBuilderDelegate _buildSliverChildDelegate(
      List<T> items, int groupedIndex) {
    return SliverChildBuilderDelegate(
        (context, idx) =>
            _sliverChildBuilder(context, idx, items, groupedIndex),
        addRepaintBoundaries: addRepaintBoundaries,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addSemanticIndexes: addSemanticIndexes,
        findChildIndexCallback: findChildIndexCallback,
        semanticIndexOffset: semanticIndexOffset,
        semanticIndexCallback: semanticIndexCallback,
        childCount: _isHasListSeparatorBuilder()
            ? _computeActualChildCount(items.length)
            : items.length);
  }

  // Helper method to compute the actual child count for the separated constructor.
  static int _computeActualChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }

  bool _isHasListSeparatorBuilder() {
    return null == gridDelegate && null != separatorBuilder;
  }

  Widget _sliverChildBuilder(
      BuildContext context, int index, List<T> items, int groupedIndex) {
    realKeys![groupedIndex] = context;

    if (_isHasListSeparatorBuilder()) {
      final int itemIndex = index ~/ 2;
      if (index.isEven) {
        if (null != itemAtIndex) {
          itemAtIndex!(itemIndex, items.length, groupedIndex);
        }
        return itemBuilder(context, items[itemIndex]);
      }
      return separatorBuilder!(context, itemIndex);
    }
    if (null != itemAtIndex) itemAtIndex!(index, items.length, groupedIndex);
    return itemBuilder(context, items[index]);
  }
}
