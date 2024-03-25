import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';

import 'managers/call_manager.dart';
import 'managers/push_notifications_manager.dart';
import 'utils/configs.dart' as utils;
import 'utils/pref_util.dart';

class SelectOpponentsScreen extends StatelessWidget {
  final CubeUser currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: BodyLayout(currentUser),
    );
  }

  _logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(Lang.get('logout')),
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

  const SelectOpponentsScreen(this.currentUser, {super.key});
}

class BodyLayout extends StatefulWidget {
  final CubeUser currentUser;

  @override
  State<StatefulWidget> createState() {
    return _BodyLayoutState(currentUser);
  }

  const BodyLayout(this.currentUser, {super.key});
}

class _BodyLayoutState extends State<BodyLayout> {
  final CubeUser currentUser;
  late Set<int> _selectedUsers;

  _BodyLayoutState(this.currentUser);

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => CallManager.instance.startNewCall(
                        context, CallType.VIDEO_CALL, _selectedUsers),
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
                    onPressed: () => CallManager.instance.startNewCall(
                        context, CallType.AUDIO_CALL, _selectedUsers),
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
    CubeUser? currentUser = CubeChatConnection.instance.currentUser;
    final users =
        utils.users.where((user) => user.id != currentUser!.id).toList();

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Card(
          child: CheckboxListTile(
            title: Center(
              child: Text(
                users[index].fullName!,
              ),
            ),
            value: _selectedUsers.contains(users[index].id),
            onChanged: ((checked) {
              setState(() {
                if (checked!) {
                  _selectedUsers.add(users[index].id!);
                } else {
                  _selectedUsers.remove(users[index].id);
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
  }
}
