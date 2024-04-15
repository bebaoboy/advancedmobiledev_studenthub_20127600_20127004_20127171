import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';

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

  Widget _buildAlertsContent() {
    return Column(
      children: <Widget>[
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
  Navigator.of(context)
      .push(
    ModalExprollableRouteBuilder(
      pageBuilder: (_, __, ___) => AlbumDetailsDialog(index: index),
      // Increase the transition durations and take a closer look at what's going on!
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      // The next two lines are not required, but are recommended for better performance.
      dismissThresholdInset: const DismissThresholdInset(dragMargin: 10000)
    ),
  )
      .then(
    (value) {
      NavbarNotifier2.hideBottomNavBar = false;
    },
  );
}

class AlbumDetailsDialog extends StatefulWidget {
  AlbumDetailsDialog({
    super.key,
    required this.index,
  });

  final int index;
  final List<String> albums = ["1", "2", "3", "4", "5"];

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
            const ViewportInset.fractional(0.1),
            const ViewportInset.fractional(0.3),
            const ViewportInset.fractional(0.5),
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
        itemCount: widget.albums.length,
        itemBuilder: (context, page) {
          return PageGutter(
            gutterWidth: 8,
            child: AlbumDetailsContainer(
              album: widget.albums[page],
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

  final String album;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            top: 20,
            child: ListView.builder(
              controller: controller,
              itemCount: 50,
              itemBuilder: (_, index) {
                return ListTile(
                  onTap: () => debugPrint("onTap(index=$index, page=$index)"),
                  title: Text("Item#$index"),
                  subtitle: Text("Page#$index"),
                );
              },
            ),
          ),
          Text(
            album,
          ),
          const Positioned(
            top: 0.0,
            right: 0.0,
            child: CloseButton(),
          ),
        ],
      ),
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
