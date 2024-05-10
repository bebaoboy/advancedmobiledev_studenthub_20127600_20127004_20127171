import 'dart:developer';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/proposal_list.dart';
import 'package:boilerplate/presentation/dashboard/chat/chat_store.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:boilerplate/presentation/dashboard/components/proposal_card_item.dart';
import 'package:boilerplate/presentation/dashboard/components/swiper_button.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/dashboard/view_proposal/store/card_state_store.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:toastification/toastification.dart';

class ProposalSwiper extends StatefulWidget {
  final Project project;

  const ProposalSwiper({super.key, required this.project});

  @override
  State<StatefulWidget> createState() => _ProposalSwiperState();
}

class _ProposalSwiperState extends State<ProposalSwiper>
    with SingleTickerProviderStateMixin {
  // ignore: unused_field
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final UserStore _userStore = getIt<UserStore>();
  final ProjectStore _projectStore = getIt<ProjectStore>();
  final ChatStore chatStore = getIt<ChatStore>();
  final CardStateStore _cardStateStore = getIt<CardStateStore>();
  final AppinioSwiperController controller = AppinioSwiperController();

  late Future<ProposalList> future;
  static const double maxAngle = 12;
  double defaultOffSetX = 13.1;
  late Proposal current;
  int index = 0;

  @override
  void initState() {
    // if (widget.project.proposal != null &&
    //     widget.project.proposal!.isNotEmpty) {
    //   future = _projectStore.getProjectProposals(widget.project,
    //       filter: (element) => element.hiredStatus == HireStatus.notHired);
    // } else {
    future = Future.value(ProposalList(
            proposals: widget.project.proposal!
                .where((element) => element.hiredStatus == HireStatus.notHired)
                .toList()))
        .then((value) {
      current = value.proposals!.first;
      print(
          "current future ${current.toJson()} student ${current.student.toJson()}");
      return value;
    });
    // }

    // _shakeCard();
    super.initState();
  }

  onLeftButtonPress() {
    if (current.hiredStatus == HireStatus.notHired) {
      changeStatus(HireStatus.pending);
      var p = widget.project.proposal!.firstWhereOrNull(
        (element) => element.objectId == current.objectId,
      );
      p?.hiredStatus = HireStatus.pending;
      current.hiredStatus = HireStatus.pending;
      if (p != null) current = p;
    }
    // ToDo
    Navigator.push(
        context,
        MaterialPageRoute2(routeName: Routes.message, arguments: [
          true,
          WrapMessageList(
            messages: [],
            project: widget.project,
            chatUser: ChatUser(
                id: current.student.userId!,
                firstName: current.student.fullName),
          )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  int initialIndex = 0;

  setInitialIndex(newIndex) {
    setState(() {
      initialIndex = newIndex;
      controller.setCardIndex(newIndex);
    });
    print(current.hiredStatus);
    print(initialIndex);
  }

  Future changeStatus(HireStatus status) async {
    _projectStore.changeToStatus(
        status, widget.project.proposal![_cardStateStore.index]);
    widget.project.proposal![_cardStateStore.index].hiredStatus = status;
    _projectStore.currentProps.proposals![_cardStateStore.index].hiredStatus =
        status;
    setState(() {});
  }

  bool isUpdatingProposal = false;

  Widget _buildBody() {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            // Color(0xFF4051A9), Color(0xFF9354B9)
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        margin: const EdgeInsets.only(top: 10),
        child: FutureBuilder<ProposalList>(
            future: future,
            builder:
                (BuildContext context, AsyncSnapshot<ProposalList> snapshot) {
              Widget children;
              if (snapshot.hasData) {
                if (snapshot.data!.proposals!.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    child: const Text('There is no cards to display'),
                  );
                } else {
                  snapshot.data!.proposals?.forEach(
                    (element) => print(element.hiredStatus),
                  );

                  return Stack(children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 600,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 50,
                              bottom: 40,
                            ),
                            child: AppinioSwiper(
                              invertAngleOnBottomDrag: true,
                              backgroundCardCount: 3,
                              swipeOptions: const SwipeOptions.symmetric(
                                  horizontal: true),
                              controller: controller,
                              initialIndex: initialIndex,
                              onCardPositionChanged: (
                                SwiperPosition position,
                              ) {
                                if (position.offset ==
                                    Offset(defaultOffSetX, 0)) {
                                  ();
                                  _cardStateStore.reset();
                                }

                                _cardStateStore.changeOpacity(
                                    (position.angle.abs().roundToDouble() /
                                            maxAngle)
                                        .clamp(0.2, 1));

                                if (position.offset.toAxisDirection() ==
                                    AxisDirection.left) {
                                  _cardStateStore.changeStateToReject(
                                      HireStatus.notHired.title);
                                }

                                if (position.offset.toAxisDirection() ==
                                    AxisDirection.right) {
                                  _cardStateStore.changeStateToHire(
                                      HireStatus.offer.title);
                                }

                                // debugPrint(
                                //     '${position.offset.toAxisDirection()}, '
                                //     '${position.offset}, '
                                //     '${position.angle}');
                              },
                              onSwipeEnd:
                                  (previousIndex, targetIndex, activity) {
                                _swipeEnd(previousIndex, targetIndex, activity);
                                var nnnindex =
                                    current.hiredStatus == HireStatus.offer ||
                                            current.hiredStatus ==
                                                HireStatus.notHired
                                        ? targetIndex
                                        : previousIndex;
                                print("nmindex $nnnindex");
                                current = snapshot.data!.proposals![nnnindex %
                                    snapshot.data!.proposals!.length];
                                _cardStateStore.reset();
                                _cardStateStore.index = nnnindex;
                                print(
                                    "current future ${current.toJson()} student ${current.student.toJson()}");
                                controller.setCardIndex(nnnindex);

                                setState(() {});
                              },
                              onEnd: _onEnd,
                              cardCount: snapshot.data!.proposals?.length ?? 0,
                              cardBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute2(
                                            routeName: Routes
                                                .companyViewStudentProfile,
                                            arguments: snapshot.data!
                                                .proposals?[index].student));
                                  },
                                  child: Stack(children: [
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    Stack(
                                      children: [
                                        ProposalCardItem(
                                          proposal:
                                              snapshot.data!.proposals![index],
                                        ),
                                        SizedBox(
                                          height: 470,
                                          child: Observer(
                                            builder: (context) => IgnorePointer(
                                              child: AnimatedOpacity(
                                                opacity:
                                                    _cardStateStore.opacity,
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: Card(
                                                  elevation: 8,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              32)),
                                                  color: _cardStateStore
                                                              .index ==
                                                          index
                                                      ? _cardStateStore.color
                                                      : null,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    alignment: _cardStateStore
                                                                .actionName ==
                                                            HireStatus
                                                                .notHired.title
                                                        ? Alignment.topRight
                                                        : Alignment.topLeft,
                                                    child: _cardStateStore
                                                                .index ==
                                                            index
                                                        ? (Text(
                                                            _cardStateStore
                                                                .actionName,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        30)))
                                                        : Container(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        IconTheme.merge(
                          data: const IconThemeData(size: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // TutorialAnimationButton(_shakeCard),
                              const SizedBox(
                                width: 20,
                              ),
                              if (!isUpdatingProposal)
                                customSwipeLeftButton(controller,
                                    onLeftButtonPress, current.hiredStatus),
                              const SizedBox(
                                width: 10,
                              ),
                              if (!isUpdatingProposal &&
                                  current.hiredStatus != HireStatus.offer)
                                customSwipeRightButton(controller, () {
                                  changeStatus(HireStatus.offer);
                                }),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        IconTheme.merge(
                          data: const IconThemeData(size: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // TutorialAnimationButton(_shakeCard),
                              const SizedBox(
                                width: 20,
                              ),
                              MaterialButton(
                                enableFeedback: index != 0,
                                onPressed: () {
                                  setState(() {
                                    var newIndex = (_cardStateStore.index - 1) %
                                        snapshot.data!.proposals!.length;
                                    _cardStateStore.index = newIndex;
                                    setInitialIndex(newIndex);
                                    current =
                                        snapshot.data!.proposals![newIndex];
                                  });
                                  print(
                                      "current ${current.toJson()} student ${current.student.toJson()}");
                                },
                                textColor: Colors.black,
                                color: Colors.grey.shade300,
                                child: const Text('Previous'),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              MaterialButton(
                                enableFeedback:
                                    index != widget.project.proposal!.length,
                                onPressed: () {
                                  setState(() {
                                    var newIndex = (_cardStateStore.index + 1) %
                                        snapshot.data!.proposals!.length;
                                    _cardStateStore.index = newIndex;
                                    setInitialIndex(newIndex);
                                    current =
                                        snapshot.data!.proposals![newIndex];
                                  });
                                  print(
                                      "current ${current.toJson()} student ${current.student.toJson()}");
                                },
                                textColor: Colors.black,
                                color: Colors.grey.shade300,
                                child: const Text('Next'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ]);
                }
              } else if (snapshot.hasError) {
                return const Text("Error fetching proposals");
              } else {
                children = const LoadingScreenWidget();
              }
              return children;
            }),
      ),
    );
  }

  void _swipeEnd(
      int previousIndex, int targetIndex, SwiperActivity activity) async {
    switch (activity) {
      case Swipe():
        print(
            "prev = $previousIndex cur=$targetIndex card=${_cardStateStore.index} ${current.student.toJson()}");
        var p = widget.project.proposal!.indexWhere(
          (element) => element.objectId == current.objectId,
        );
        if (_projectStore.currentProps.proposals![p].hiredStatus !=
            HireStatus.notHired) {
          // _cardStateStore.reset();
          // _cardStateStore.index = previousIndex;
          break;
        }
        setState(() {
          isUpdatingProposal = true;
        });
        log('The card was swiped to the : ${activity.direction}');

        log("card: ${_cardStateStore.index}");
        if (_projectStore.currentProps.proposals == null ||
            _projectStore.currentProps.proposals!.isEmpty) return;

        if (activity.direction == AxisDirection.right) {
          // ToDo: update proposal status value = 2

          if (p != -1) {
            _projectStore.currentProps.proposals![p].hiredStatus =
                HireStatus.offer;
            widget.project.proposal![p].hiredStatus = HireStatus.offer;
            current.hiredStatus = HireStatus.offer;
            // await _projectStore.updateProposal(
            //     _projectStore.currentProps.proposals![p],
            //     _userStore.user!.studentProfile!.objectId!);
            Toastify.show(context, "", "Sent hired successfully",
                ToastificationType.success, () {});
          }
        } else {
          // Reject proposal
          var p = widget.project.proposal!.indexWhere(
            (element) => element.objectId == current.objectId,
          );
          if (p != -1) {
            _projectStore.currentProps.proposals![p].enabled = false;
            _projectStore.currentProps.proposals![p].hiredStatus =
                HireStatus.notHired;
            widget.project.proposal![p].hiredStatus = HireStatus.notHired;
            current.hiredStatus = HireStatus.notHired;

            // await _projectStore.updateProposal(
            //     _projectStore.currentProps.proposals![p],
            //     _userStore.user!.studentProfile!.objectId!);

            Toastify.show(context, "", "Reject successfully",
                ToastificationType.success, () {});
          }
        }
        // int newIndex = (targetIndex + 1) % widget.project.proposal!.length;
        // _cardStateStore.index = newIndex;
        // setInitialIndex(newIndex);
        isUpdatingProposal = false;
        setState(() {});

        log('previous index: $previousIndex, target index: $targetIndex');
        break;
      case Unswipe():
        _cardStateStore.reset();
        log('A ${activity.direction.name} swipe was undone.');
        log('previous index: $previousIndex, target index: $targetIndex');
        break;
      case CancelSwipe():
        _cardStateStore.reset();
        log('A swipe was cancelled');
        break;
      case DrivenActivity():
        _cardStateStore.reset();
        log('Driven Activity');
        break;
    }
  }

  void _onEnd() {
    log('end reached!');
    _cardStateStore.reset();
    controller.setCardIndex(0);
    // Navigator.pop(context);
  }

  // Animates the card back and forth to teach the user that it is swipeable.
  // ignore: unused_element
  Future<void> _shakeCard() async {
    const double distance = 30;
    // We can animate back and forth by chaining different animations.
    await controller.animateTo(
      const Offset(-distance, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    await controller.animateTo(
      const Offset(distance, 0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    // We need to animate back to the center because `animateTo` does not center
    // the card for us.
    await controller.animateTo(
      const Offset(0, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return MainAppBar(
      theme: true,
      name: _userStore.user != null ? _userStore.user!.name : "",
    );
  }
}
