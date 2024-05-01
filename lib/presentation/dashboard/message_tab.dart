import 'package:boilerplate/core/widgets/refresh_indicator/indicators/plane_indicator.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/presentation/dashboard/chat/chat_store.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(milliseconds: 500), () async {
    getAllChatFuture = chatStore.getAllChat(setStateCallback: () {
      setState(() {});
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
          itemCount: 18,
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => print("flutter"),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 60.0,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: Image.network(
                            'https://docs.flutter.dev/assets/images/404/dash_nest.png',
                            fit: BoxFit.cover,
                          ).image,
                          radius: 50.0,
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
                return chatStore.messages.isEmpty
                    ? const Center(
                        child: Text("No message"),
                      )
                    : Positioned.fill(
                        top: 60,
                        child: PlaneIndicator(
                          onRefresh: () =>
                              Future.delayed(const Duration(seconds: 3)),
                          child: Stack(children: [
                            Positioned.fill(
                              top: 30,
                              child: ListView.separated(
                                controller: widget.scrollController,
                                itemCount: chatStore.messages.length + 1,
                                separatorBuilder: (context, index) =>
                                    const Divider(color: Colors.black),
                                itemBuilder: (context, i) {
                                  if (i == 0) {
                                    return Container(
                                        margin: const EdgeInsets.only(top: 15),
                                        child: _buildTopRowList());
                                  }
                                  int index = i - 1;
                                  if (chatStore.messages[index].lastSeenTime !=
                                          null &&
                                      chatStore.messages.fold(
                                              0,
                                              (sum, item) =>
                                                  sum + item.newMessageCount) >
                                          0) {
                                    Future.delayed(const Duration(seconds: 1),
                                        () {
                                      if (NavbarNotifier2
                                              .badges[
                                                  NavbarNotifier2.currentIndex]
                                              .showBadge ==
                                          false) {
                                        NavbarNotifier2.updateBadge(
                                            2,
                                            NavbarBadge(
                                                showBadge: true,
                                                badgeText:
                                                    "${chatStore.messages.fold(0, (sum, item) => sum + item.newMessageCount)}"));
                                      }
                                      if (mounted) setState(() {});
                                    });
                                    // print(
                                    //     "new message count after ${chatStore.messages[index].lastSeenTime}: ${chatStore.messages[index].newMessageCount}");
                                  } else {
                                    Future.delayed(const Duration(seconds: 1),
                                        () {
                                      if (NavbarNotifier2
                                              .badges[
                                                  NavbarNotifier2.currentIndex]
                                              .showBadge ==
                                          true) {
                                        NavbarNotifier2.makeBadgeVisible(
                                            2, false);
                                      }
                                    });
                                  }
                                  return InkWell(
                                    onTap: () {
                                      //print('Tile clicked');
                                      String id = chatStore
                                          .messages[index]
                                          .chatUser
                                          .id; // id này chỉ để test socket

                                      chatStore.getMessageByProjectAndUsers(
                                          userId: chatStore
                                              .messages[index].chatUser.id,
                                          projectId: chatStore.messages[index]
                                              .project!.objectId!);
                                      /*
                                                                        {
                                          "result": [
                                            {
                                              "id": 249,
                                              "createdAt": "2024-04-23T16:09:43.731Z",
                                              "content": "Something",
                                              "sender": {
                                                "id": 34,
                                                "fullname": "bao bao"
                                              },
                                              "receiver": {
                                                "id": 94,
                                                "fullname": "quan"
                                              },
                                              "interview": null
                                            },
                                            {
                                              "id": 251,
                                              "createdAt": "2024-04-23T16:27:26.848Z",
                                              "content": "Hi",
                                              "sender": {
                                                "id": 34,
                                                "fullname": "bao bao"
                                              },
                                              "receiver": {
                                                "id": 94,
                                                "fullname": "quan"
                                              },
                                              "interview": null
                                            },
                                                                         */
                                      Navigator.of(NavigationService
                                              .navigatorKey.currentContext!)
                                          .push(MaterialPageRoute2(
                                              routeName:
                                                  "${Routes.message}/${chatStore.messages[index].project?.objectId}-${userStore.user?.objectId}-$id",
                                              arguments: WrapMessageList(
                                                  project: chatStore
                                                      .messages[index].project,
                                                  messages: chatStore
                                                      .messages[index].messages,
                                                  chatUser: chatStore
                                                      .messages[index]
                                                      .chatUser)))
                                          .then(
                                        (value) {
                                          setState(() {
                                            chatStore.sort();
                                          });
                                        },
                                      );
                                      // You can replace the print statement with your function
                                    },
                                    child: ListTile(
                                      tileColor: Colors.transparent,
                                      leading: const Icon(Icons
                                          .message), // Replace with actual icons
                                      title: Text(
                                        "Project ${chatStore.messages[index].project?.title} (${chatStore.messages[index].project?.objectId}) - ${chatStore.messages[index].chatUser.firstName} (${chatStore.messages[index].chatUser.id})",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: chatStore.messages[index]
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
                                            chatStore
                                                        .messages[index]
                                                        .messages!
                                                        .first
                                                        .sender
                                                        .objectId !=
                                                    userStore.user!.objectId
                                                ? chatStore.messages[index]
                                                    .messages!.first.content
                                                : "You: ${chatStore.messages[index].messages!.first.content}",
                                            style: TextStyle(
                                                fontWeight: chatStore
                                                            .messages[index]
                                                            .newMessageCount >
                                                        0
                                                    ? FontWeight.bold
                                                    : null),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            chatStore.messages[index].messages
                                                    ?.firstOrNull?.updatedAt
                                                    ?.toLocal()
                                                    .toString() ??
                                                "null",
                                            style:
                                                const TextStyle(fontSize: 12),
                                            textAlign: TextAlign.end,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ]),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: Lang.get("search"),
              hintText: Lang.get("search"),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
