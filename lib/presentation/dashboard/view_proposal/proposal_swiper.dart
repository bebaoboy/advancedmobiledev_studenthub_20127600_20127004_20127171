import 'dart:developer';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/proposal_list.dart';
import 'package:boilerplate/presentation/dashboard/components/proposal_card_item.dart';
import 'package:boilerplate/presentation/dashboard/components/swiper_button.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class ProposalSwiper extends StatefulWidget {
  final Project project;

  const ProposalSwiper({super.key, required this.project});

  @override
  State<StatefulWidget> createState() => _ProposalSwiperState();
}

class _ProposalSwiperState extends State<ProposalSwiper> {
  // ignore: unused_field
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final UserStore _userStore = getIt<UserStore>();
  final ProjectStore _projectStore = getIt<ProjectStore>();
  final AppinioSwiperController controller = AppinioSwiperController();

  late Future<ProposalList> future;

  @override
  void initState() {
    if (widget.project.proposal == null) {
      future = _projectStore.getProjectProposals(widget.project);
    } else {
      future = Future.value(ProposalList(proposals: widget.project.proposal));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9354B9),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF4051A9), Color(0xFF9354B9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 0.9])),
        margin: const EdgeInsets.only(top: 10),
        child: FutureBuilder<ProposalList>(
            future: future,
            builder:
                (BuildContext context, AsyncSnapshot<ProposalList> snapshot) {
              Widget children;
              if (snapshot.hasData) {
                return Stack(
                  children: [
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
                              onSwipeBegin: _swipeBegin,
                              invertAngleOnBottomDrag: true,
                              backgroundCardCount: 3,
                              swipeOptions: const SwipeOptions.symmetric(
                                  horizontal: true),
                              controller: controller,
                              onCardPositionChanged: (
                                SwiperPosition position,
                              ) {
                                //debugPrint('${position.offset.toAxisDirection()}, '
                                //    '${position.offset}, '
                                //    '${position.angle}');
                              },
                              onSwipeEnd: _swipeEnd,
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
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 100,
                                        ),
                                        ProposalCardItem(
                                          proposal:
                                              snapshot.data!.proposals![index],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 120),
                                      child: Hero(
                                        tag:
                                            "studentImage${snapshot.data!.proposals![index].student.objectId}",
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const FlutterLogo(
                                            size: 200,
                                          ),
                                        ),
                                      ),
                                    )
                                  ]),
                                );
                              },
                            ),
                          ),
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
                              customSwipeLeftButton(controller, () {}),
                              const SizedBox(
                                width: 10,
                              ),
                              customSwipeRightButton(controller, () {}),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Positioned(
                      width: 200,
                      height: 800,
                      child: AnimatedOpacity(
                          duration: Duration.zero,
                          opacity: 0,
                          child: Container(
                            color: Colors.amber,
                          )),
                    )
                  ],
                );
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

  void _swipeBegin(
      int previousIndex, int targetIndex, SwiperActivity activity) {}

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    switch (activity) {
      case Swipe():
        log('The card was swiped to the : ${activity.direction}');

        if (activity.direction == AxisDirection.down ||
            activity.direction == AxisDirection.up) {
          return;
        } else if (activity.direction == AxisDirection.right) {
          // ToDo: update proposal status
        }

        log('previous index: $previousIndex, target index: $targetIndex');
        break;
      case Unswipe():
        log('A ${activity.direction.name} swipe was undone.');
        log('previous index: $previousIndex, target index: $targetIndex');
        break;
      case CancelSwipe():
        log('A swipe was cancelled');
        break;
      case DrivenActivity():
        log('Driven Activity');
        break;
    }
  }

  void _onEnd() {
    log('end reached!');
    Navigator.pop(context);
  }

  // Animates the card back and forth to teach the user that it is swipable.
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
