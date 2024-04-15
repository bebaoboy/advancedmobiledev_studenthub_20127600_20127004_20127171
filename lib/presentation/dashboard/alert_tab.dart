import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/under_text_field_widget.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';

var colors = [
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

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: _buildAlertsContent());
  }

  Widget _buildTopRowList() {
    return Scrollbar(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: HeroFlutterLogo(
              color: colors[index],
              tag: index,
              size: 100,
              onTap: () => showAlbumDetailsDialog(context, index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertsContent() {
    return Column(
      children: <Widget>[
        SizedBox(height: 120, child: _buildTopRowList()),
        Expanded(
          child: ListView.separated(
            controller: widget.scrollController,
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
                                showAlbumDetailsDialog(context, 2);
                                NavbarNotifier2.hideBottomNavBar = true;
                              }
                            }
                            // You can replace the print statement with your function
                          },
                          child: Text(Lang.get(alerts[index]['action'])),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

void showAlbumDetailsDialog(BuildContext context, int index) {
  print(index);
  NavbarNotifier2.hideBottomNavBar = true;

  Navigator.of(NavigationService.navigatorKey.currentContext ?? context)
      .push(
    ModalExprollableRouteBuilder(
        pageBuilder: (_, __, ___) => AlbumDetailsDialog(
              index: index,
            ),
        // Increase the transition durations and take a closer look at what's going on!
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        // The next two lines are not required, but are recommended for better performance.
        dismissThresholdInset: const DismissThresholdInset(dragMargin: 10000)),
  )
      .then(
    (value) {
      NavbarNotifier2.hideBottomNavBar = false;
    },
  );
}

class AlbumDetailsDialog extends StatefulWidget {
  const AlbumDetailsDialog({
    super.key,
    required this.index,
  });

  final int index;

  @override
  State<StatefulWidget> createState() => _AlbumDetailsDialogState();
}

class _AlbumDetailsDialogState extends State<AlbumDetailsDialog> {
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
        itemCount: colors.length,
        itemBuilder: (context, page) {
          return PageGutter(
            gutterWidth: 8,
            child: AlbumDetailsContainer(
              album: page,
              controller: PageContentScrollController.of(context),
            ),
          );
        });
  }
}

class AlbumDetailsContainer extends StatelessWidget {
  const AlbumDetailsContainer({
    super.key,
    required this.album,
    required this.controller,
  });

  final int album;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                margin: const EdgeInsets.only(top: 20),
                child: ListView.builder(
                  controller: controller,
                  itemCount: 3,
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return Container(
                        margin: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: HeroFlutterLogo(
                            color: colors[album],
                            tag: album,
                            size: 400,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    } else if (index == 2) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Center(
                              child: Text(
                                "Student Name",
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
                              child: Text(
                                Lang.get('profile_common_body'),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              Lang.get('profile_question_title_1'),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    Lang.get('profile_question_title_4'),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                BorderTextField(
                                  inputDecoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black))),
                                  onChanged: (value) {},
                                  textController: TextEditingController(),
                                  // onSubmitted: (value) =>
                                  //     {FocusScope.of(context).requestFocus(_companyFocusNode)},
                                  minLines: 3,
                                  maxLines: 5,
                                  errorText: null,
                                  isIcon: false,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Lang.get('profile_question_title_4'),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                BorderTextField(
                                  textController: TextEditingController(),
                                  inputDecoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black))),
                                  onChanged: (value) {},
                                  // onSubmitted: (value) =>
                                  //     {FocusScope.of(context).requestFocus(_companyFocusNode)},
                                  minLines: 3,
                                  maxLines: 5,
                                  errorText: null,
                                  isIcon: false,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            // _buildEmailField(context),
                            // const SizedBox(
                            //   height: 25,
                            // ),
                            Container(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RoundedButtonWidget(
                                    buttonText: Lang.get('continue'),
                                    buttonColor:
                                        Theme.of(context).colorScheme.primary,
                                    textColor: Colors.white,
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Lang.get('profile_question_title_4'),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                BorderTextField(
                                  textController: TextEditingController(),
                                  inputDecoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black))),
                                  onChanged: (value) {},
                                  // onSubmitted: (value) =>
                                  //     {FocusScope.of(context).requestFocus(_companyFocusNode)},
                                  minLines: 3,
                                  maxLines: 5,
                                  errorText: null,
                                  isIcon: false,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Lang.get('profile_question_title_4'),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                BorderTextField(
                                  textController: TextEditingController(),
                                  inputDecoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black))),
                                  onChanged: (value) {},
                                  // onSubmitted: (value) =>
                                  //     {FocusScope.of(context).requestFocus(_companyFocusNode)},
                                  minLines: 3,
                                  maxLines: 5,
                                  errorText: null,
                                  isIcon: false,
                                ),
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
              const CloseButton(),
            ])),
      ],
    );
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
