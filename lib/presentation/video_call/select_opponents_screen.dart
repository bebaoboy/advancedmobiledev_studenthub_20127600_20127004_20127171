// ignore_for_file: no_logic_in_create_state

import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/presentation/video_call/utils/platform_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';
// import 'package:sembast/sembast.dart';

import 'managers/call_manager.dart';
import 'managers/push_notifications_manager.dart';
import 'utils/configs.dart' as utils;
import 'utils/pref_util.dart';

class SelectOpponentsScreen extends StatefulWidget {
  final CubeUser currentUser;
  final List<CubeUser> users;

  @override
  State<SelectOpponentsScreen> createState() => _SelectOpponentsScreenState();

  const SelectOpponentsScreen(this.currentUser,
      {super.key, required this.users});
}

class _SelectOpponentsScreenState extends State<SelectOpponentsScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    try {
      checkSystemAlertWindowPermission(context);
    } catch (e) {
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Logged in as ${CubeChatConnection.instance.currentUser!.fullName}',
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => _logOut(context),
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 58.0),
            child: TextFieldWidget(
              hint: "Type in their email",
              inputType: TextInputType.emailAddress,
              icon: Icons.account_box,
              textController: _textController,
              inputAction: TextInputAction.next,
              autoFocus: false,
              onFieldSubmitted: (value) async {
                if (_textController.text.trim().isNotEmpty) {
                  await getUsers({"login": _textController.text})
                      .then((cubeUser) => {
                            if (cubeUser != null)
                              // ignore: avoid_function_literals_in_foreach_calls
                              cubeUser.items.forEach(
                                (element) {
                                  try {
                                    setState(() {
                                      if (widget.users.firstWhereOrNull(
                                            (e) => e.id == element.id,
                                          ) ==
                                          null) {
                                        widget.users.add(element);
                                      }
                                    });
                                    if (utils.users.firstWhereOrNull(
                                          (e) => e.id == element.id,
                                        ) ==
                                        null) {
                                      utils.users.add(element);
                                    }
                                  } catch (e) {
                                    print("");
                                  }
                                },
                              )
                          });
                }
              },
              errorText: null,
            ),
          ),
          Expanded(child: BodyLayout(widget.currentUser, users: widget.users)),
        ],
      ),
    );
  }

  _logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Lang.get('logout')),
          content: Text(Lang.get("logout_confirm")),
          actions: <Widget>[
            TextButton(
              child: Text(Lang.get('cancel')),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(Lang.get("ok")),
              onPressed: () async {
                CallManager.instance.destroy();
                CubeChatConnection.instance.destroy();
                await PushNotificationsManager.instance.unsubscribe();
                await SharedPrefs.deleteUserData();
                await signOut();

                Navigator.pop(context); // cancel current Dialog
                _navigateToLoginScreen(context);
              },
            ),
          ],
        );
      },
    );
  }

  _navigateToLoginScreen(BuildContext context) {
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => LoginScreen(),
    //   ),
    //   (r) => false,
    // );
  }
}

class BodyLayout extends StatefulWidget {
  final CubeUser currentUser;
  final List<CubeUser> users;

  @override
  State<StatefulWidget> createState() => _BodyLayoutState();

  const BodyLayout(this.currentUser, {super.key, required this.users});
}

class _BodyLayoutState extends State<BodyLayout> {
  late Set<int> _selectedUsers;

  @override
  Widget build(BuildContext context) {
    print("build");
    return Container(
        padding:
            const EdgeInsets.only(top: 48, left: 48, right: 48, bottom: 12),
        child: Column(
          children: [
            const Text(
              "Select users to call:",
              style: TextStyle(fontSize: 22),
            ),
            Expanded(
              child: _getOpponentsList(context),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FloatingActionButton(
                    heroTag: "VideoCall",
                    backgroundColor: Colors.blue,
                    onPressed: () {},
                    // CallManager.instance.startNewCall(
                    //     context, CallType.VIDEO_CALL, _selectedUsers),
                    child: const Icon(
                      Icons.videocam,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FloatingActionButton(
                    heroTag: "AudioCall",
                    backgroundColor: Colors.green,
                    onPressed: () {},
                    // CallManager.instance.startNewCall(
                    //     context, CallType.AUDIO_CALL, _selectedUsers, widget._),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _getOpponentsList(BuildContext context) {
    // CubeUser? currentUser = CubeChatConnection.instance.currentUser;

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      controller: ScrollController(),
      itemCount: widget.users.length,
      shrinkWrap: false,
      itemBuilder: (context, index) {
        return Card(
          child: CheckboxListTile(
            title: Center(
              child: Text(
                widget.users[index].fullName!,
              ),
            ),
            value: _selectedUsers.contains(widget.users[index].id),
            onChanged: ((checked) {
              setState(() {
                if (checked!) {
                  _selectedUsers.add(widget.users[index].id!);
                } else {
                  _selectedUsers.remove(widget.users[index].id);
                }
              });
            }),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedUsers = {};
    print("init");

  }
}
