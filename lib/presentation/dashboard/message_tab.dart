import 'dart:async';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/core/widgets/floating_search_bar/src/floating_search_bar.dart';
import 'package:boilerplate/core/widgets/floating_search_bar/src/floating_search_bar_actions.dart';
import 'package:boilerplate/core/widgets/floating_search_bar/src/floating_search_bar_transition.dart';
import 'package:boilerplate/core/widgets/refresh_indicator/indicators/plane_indicator.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/presentation/dashboard/chat/chat_store.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class MessageTab extends StatefulWidget {
  const MessageTab({super.key, required this.scrollController});
  final ScrollController scrollController;
  @override
  State<MessageTab> createState() => Singapore();
}

class Singapore extends State<MessageTab> {
  // final List<Map<String, dynamic>> messages = [
  //   {
  //     'icon': Icons.message,
  //     'name': 'Luis Pham',
  //     'role': 'Senior frontend developer (Fintech)',
  //     'message': 'Clear expectation about your project or deliverables',
  //     'date': '6/6/2024'
  //   },
  //   {
  //     'icon': Icons.message,
  //     'name': 'John Doe',
  //     'role': 'Junior backend developer (Healthcare)',
  //     'message': 'Looking forward to working with you',
  //     'date': '7/6/2024'
  //   },
  //   {
  //     'icon': Icons.message,
  //     'name': 'Singapore',
  //     'role': 'Sey',
  //     'message': 'Clear expectation about your project or deliverables',
  //     'date': '6/6/2024'
  //   },
  //   {
  //     'icon': Icons.message,
  //     'name': 'Malaysia Nguyen',
  //     'role': 'Doctor',
  //     'message': 'Looking forward to working with you',
  //     'date': '7/6/2024'
  //   },
  //   // Add more messages here
  // ];

  late Future getAllChatFuture;
  late Timer timer;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(milliseconds: 500), () async {
    getAllChatFuture = Future.delayed(
        Duration.zero,
        chatStore.messages.isEmpty
            ? chatStore.getAllChat
            : () => chatStore.messages);
    timer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (mounted) {
        setState(() {});
      }
    });
    // chatStore.getMessageByProjectAndUsers(projectId: "1", userId: "9");
    // chatStore.getMessageByProjectAndUsers(projectId: "150", userId: "94");
    // });
  }

  var chatStore = getIt<ChatStore>();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: _buildMessageContent());
  }

  Widget _buildTopRowList() {
    return SizedBox(
      height: 72,
      child: Scrollbar(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: chatStore.messages.length,
          itemBuilder: (context, index) {
            return Container(
              width: 64,
              height: 54,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Tooltip(
                      preferBelow: true,
                      message: chatStore.messages[index].chatUser.firstName ??
                          "Border Radius",
                      verticalOffset: 30,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => print(
                            chatStore.messages[index].chatUser.firstName ??
                                "Border Radius"),
                        child: CircleAvatar(
                          radius: 60,
                          child: Initicon(
                            style: const TextStyle(fontSize: 15),
                            text:
                                chatStore.messages[index].chatUser.firstName ??
                                    "Border Radius",
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(60),
                            size: 59.5,
                          ),
                          // CircleAvatar(
                          //   child: Text(
                          //       chatStore.messages[index].chatUser.firstName!),
                          // ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 1,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  var userStore = getIt<UserStore>();

  Widget _buildMessageContent() {
    return Stack(
      children: <Widget>[
        FutureBuilder(
            future: getAllChatFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return (chatStore.isFetchingAll && chatStore.messages.isEmpty)
                    ? const LoadingScreenWidget()
                    : chatStore.messages.isEmpty
                        ? const Center(
                            child: Text("No message"),
                          )
                        : Positioned.fill(
                            top: 40,
                            child: PlaneIndicator(
                              onRefresh: () => Future.delayed(
                                  const Duration(seconds: 1), () {
                                setState(() {
                                  getAllChatFuture = chatStore.getAllChat(
                                      setStateCallback: () {
                                    setState(() {});
                                  });
                                });
                              }),
                              child: Observer(builder: (context) {
                                return Stack(children: [
                                  Positioned.fill(
                                    top: 30,
                                    child: ListView.separated(
                                      controller: widget.scrollController,
                                      itemCount: chatStore.messages.length + 1,
                                      separatorBuilder: (context, index) =>
                                          const Divider(color: Colors.black),
                                      itemBuilder: (context, i) {
                                        if (i == 0) {
                                          return chatStore.isFetchingAll
                                              ? const LoadingScreenWidget()
                                              : Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 15),
                                                  child: _buildTopRowList());
                                        }
                                        int index = i - 1;

                                        return InkWell(
                                          onTap: () {
                                            //print('Tile clicked');
                                            String id = chatStore
                                                .messages[index]
                                                .chatUser
                                                .id; // id này chỉ để test socket
                                            chatStore.messages[index]
                                                .lastSeenTime = DateTime.now();
                                            var c = chatStore.messages.fold(
                                                0,
                                                (sum, item) =>
                                                    sum + item.newMessageCount);
                                            if (c > 0) {
                                              NavbarNotifier2.updateBadge(
                                                  2,
                                                  NavbarBadge(
                                                      showBadge: true,
                                                      badgeText: "$c"));
                                            }
                                            Navigator.of(NavigationService
                                                    .navigatorKey
                                                    .currentContext!)
                                                .push(MaterialPageRoute2(
                                                    routeName:
                                                        "${Routes.message}/${chatStore.messages[index].project?.objectId}-${userStore.user?.objectId}-$id",
                                                    arguments: [
                                                  false,
                                                  WrapMessageList(
                                                      project: chatStore
                                                          .messages[index]
                                                          .project,
                                                      messages: chatStore
                                                          .messages[index]
                                                          .messages,
                                                      chatUser: chatStore
                                                          .messages[index]
                                                          .chatUser)
                                                ]))
                                                .then(
                                              (value) {
                                                setState(() {
                                                  chatStore.messages[index]
                                                          .lastSeenTime =
                                                      DateTime.now();
                                                });
                                              },
                                            );
                                            // You can replace the print statement with your function
                                          },
                                          child: ListTile(
                                            tileColor: Colors.transparent,
                                            leading: Icon(chatStore
                                                        .messages[index]
                                                        .messages!
                                                        .firstOrNull
                                                        ?.messageType ==
                                                    MessageType.joinInterview
                                                ? Icons.lock_clock
                                                : Icons
                                                    .message), // Replace with actual icons
                                            title: Text(
                                              "Project ${chatStore.messages[index].project?.title} (${chatStore.messages[index].project?.objectId}) - ${chatStore.messages[index].chatUser.firstName} (${chatStore.messages[index].chatUser.id})",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: chatStore
                                                              .messages[index]
                                                              .newMessageCount >
                                                          0
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : null),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                // Text(chatStore.messages[index]['role']),

                                                Text(
                                                  chatStore.messages[index]
                                                          .messages!.isEmpty
                                                      ? ""
                                                      : chatStore
                                                                  .messages[
                                                                      index]
                                                                  .messages!
                                                                  .first
                                                                  .sender
                                                                  .objectId !=
                                                              userStore.user!
                                                                  .objectId
                                                          ? chatStore
                                                                  .messages[
                                                                      index]
                                                                  .messages!
                                                                  .firstOrNull
                                                                  ?.content ??
                                                              ""
                                                          : "You: ${chatStore.messages[index].messages!.first.content}",
                                                  style: TextStyle(
                                                      fontWeight: chatStore
                                                                  .messages[
                                                                      index]
                                                                  .newMessageCount >
                                                              0
                                                          ? FontWeight.bold
                                                          : null),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Text(
                                                  chatStore
                                                          .messages[index]
                                                          .messages
                                                          ?.firstOrNull
                                                          ?.updatedAt
                                                          ?.toLocal()
                                                          .toString() ??
                                                      "null",
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  textAlign: TextAlign.end,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ]);
                              }),
                            ),
                          );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text("No message"),
                );
              } else {
                return const LoadingScreenWidget();
              }
            }),
        // ToDo: implement search chat
        Padding(
            padding: const EdgeInsets.all(0), child: buildFloatingSearchBar()
            // TextField(
            //   onSubmitted: (value) => print(value),
            //   decoration: InputDecoration(
            //     hintText:
            //         "${Lang.get("search")} ${chatStore.messages.length} people",
            //     labelText:
            //         "${Lang.get("search")} ${chatStore.messages.length} people",
            //     prefixIcon: const Icon(Icons.search),
            //     border: const OutlineInputBorder(
            //       borderRadius: BorderRadius.all(Radius.circular(25.0)),
            //     ),
            //   ),
            // ),
            ),
      ],
    );
  }

  final FloatingSearchBarController controller = FloatingSearchBarController();

  Widget buildFloatingSearchBar() {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      onFocusChanged: (isFocused) {
        if (!isFocused) controller.close();
      },
      showCursor: true,
      clearQueryOnClose: false,
      controller: controller,
      backdropColor: Theme.of(context).colorScheme.background,
      borderRadius: const BorderRadius.all(Radius.circular(25.0)),
      border: const BorderSide(),
      hint: "${Lang.get("search")} ${chatStore.messages.length} people",
      title: Text("${Lang.get("search")} ${chatStore.messages.length} people"),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.width * 0.8,
      onKeyEvent: (KeyEvent keyEvent) {
        if (keyEvent.logicalKey == LogicalKeyboardKey.escape) {
          controller.query = '';
          controller.close();
        }
      },
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (String query) {
        // Call your model, bloc, controller here.
        setState(() {
          controller.query = query;
        });
        print(controller.query);
      },
      automaticallyImplyBackButton: true,
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction.back(),
      ],
      actions: <Widget>[
        // FloatingSearchBarAction(
        //   showIfClosed: false,
        //   child: CircularButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {
        //       if (controller.isOpen) {
        //         controller.close();
        //       }
        //     },
        //   ),
        // ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (BuildContext context, Animation<double> transition) {
        return Material(
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ImplicitlyAnimatedList<WrapMessageList>(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              insertDuration: const Duration(milliseconds: 300),
              items: chatStore.messages
                  .where((element) => element.chatUser.firstName!
                      .toLowerCase()
                      .contains(controller.query.toLowerCase()))
                  .toList(),
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.black),
              itemBuilder: (BuildContext context, Animation<double> animation,
                  WrapMessageList item, _) {
                return FadeTransition(
                  opacity: animation,
                  child: InkWell(
                    onTap: () {
                      //print('Tile clicked');
                      String id = item.chatUser.id; // id này chỉ để test socket
                      item.lastSeenTime = DateTime.now();
                      var c = chatStore.messages
                          .fold(0, (sum, item) => sum + item.newMessageCount);
                      if (c > 0) {
                        NavbarNotifier2.updateBadge(
                            2, NavbarBadge(showBadge: true, badgeText: "$c"));
                      }
                      Navigator.of(
                              NavigationService.navigatorKey.currentContext!)
                          .push(MaterialPageRoute2(
                              routeName:
                                  "${Routes.message}/${item.project?.objectId}-${userStore.user?.objectId}-$id",
                              arguments: [
                            false,
                            WrapMessageList(
                                project: item.project,
                                messages: item.messages,
                                chatUser: item.chatUser)
                          ]))
                          .then(
                        (value) {
                          setState(() {
                            item.lastSeenTime = DateTime.now();
                          });
                        },
                      );
                      // You can replace the print statement with your function
                    },
                    child: ListTile(
                      tileColor: Colors.transparent,
                      leading: Icon(item.messages!.firstOrNull?.messageType ==
                              MessageType.joinInterview
                          ? Icons.lock_clock
                          : Icons.message), // Replace with actual icons
                      title: AutoSizeText(
                        minFontSize: 12,
                        maxFontSize: 14,
                        maxLines: 2,
                        words: controller.query.isNotEmpty
                            ? {
                                controller.query: HighlightedWord(
                                  onTap: () {
                                    print("match");
                                  },
                                ),
                              }
                            : null,
                        matchDecoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        "Project ${item.project?.title} (${item.project?.objectId}) - ${item.chatUser.firstName} (${item.chatUser.id})",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.newMessageCount > 0
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Text(item['role']),

                          AutoSizeText(
                            minFontSize: 12,
                            maxFontSize: 14,
                            maxLines: 2,
                            item.messages!.isEmpty
                                ? ""
                                : item.messages!.first.sender.objectId !=
                                        userStore.user!.objectId
                                    ? item.messages!.firstOrNull?.content ?? ""
                                    : "You: ${item.messages!.first.content}",
                            style: TextStyle(
                                fontWeight: item.newMessageCount > 0
                                    ? FontWeight.bold
                                    : null,
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            item.messages?.firstOrNull?.updatedAt
                                    ?.toLocal()
                                    .toString() ??
                                "null",
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.end,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              updateItemBuilder: (BuildContext context,
                  Animation<double> animation, WrapMessageList item) {
                return FadeTransition(
                  opacity: animation,
                  child: InkWell(
                    onTap: () {
                      //print('Tile clicked');
                      String id = item.chatUser.id; // id này chỉ để test socket
                      item.lastSeenTime = DateTime.now();
                      var c = chatStore.messages
                          .fold(0, (sum, item) => sum + item.newMessageCount);
                      if (c > 0) {
                        NavbarNotifier2.updateBadge(
                            2, NavbarBadge(showBadge: true, badgeText: "$c"));
                      }
                      Navigator.of(
                              NavigationService.navigatorKey.currentContext!)
                          .push(MaterialPageRoute2(
                              routeName:
                                  "${Routes.message}/${item.project?.objectId}-${userStore.user?.objectId}-$id",
                              arguments: [
                            false,
                            WrapMessageList(
                                project: item.project,
                                messages: item.messages,
                                chatUser: item.chatUser)
                          ]))
                          .then(
                        (value) {
                          setState(() {
                            item.lastSeenTime = DateTime.now();
                          });
                        },
                      );
                      // You can replace the print statement with your function
                    },
                    child: ListTile(
                      tileColor: Colors.transparent,
                      leading: Icon(item.messages!.firstOrNull?.messageType ==
                              MessageType.joinInterview
                          ? Icons.lock_clock
                          : Icons.message), // Replace with actual icons
                      title: AutoSizeText(
                        minFontSize: 12,
                        maxFontSize: 14,
                        maxLines: 2,
                        words: controller.query.isNotEmpty
                            ? {
                                controller.query: HighlightedWord(
                                  onTap: () {
                                    print("match");
                                  },
                                ),
                              }
                            : null,
                        matchDecoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        "Project ${item.project?.title} (${item.project?.objectId}) - ${item.chatUser.firstName} (${item.chatUser.id})",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.newMessageCount > 0
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Text(item['role']),

                          AutoSizeText(
                            minFontSize: 12,
                            maxFontSize: 14,
                            maxLines: 2,
                            item.messages!.isEmpty
                                ? ""
                                : item.messages!.first.sender.objectId !=
                                        userStore.user!.objectId
                                    ? item.messages!.firstOrNull?.content ?? ""
                                    : "You: ${item.messages!.first.content}",
                            style: TextStyle(
                                fontWeight: item.newMessageCount > 0
                                    ? FontWeight.bold
                                    : null,
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            item.messages?.firstOrNull?.updatedAt
                                    ?.toLocal()
                                    .toString() ??
                                "null",
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.end,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              areItemsTheSame: (a, b) => a == b,
            ),
          ),
        );
        // ClipRRect(
        //   borderRadius: BorderRadius.circular(8),
        //   child: Material(
        //     color: Colors.white,
        //     elevation: 4.0,
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: Colors.accents.map((MaterialAccentColor color) {
        //         return Container(height: 112, color: color);
        //       }).toList(),
        //     ),
        //   ),
        // );
      },
    );
  }
}
