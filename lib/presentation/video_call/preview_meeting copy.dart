// // ignore_for_file: no_logic_in_create_state

// import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
// import 'package:boilerplate/domain/entity/project/entities.dart';
// import 'package:boilerplate/presentation/home/loading_screen.dart';
// import 'package:boilerplate/presentation/video_call/conversation_screen.dart';
// import 'package:boilerplate/presentation/video_call/utils/platform_utils.dart';
// import 'package:floating/floating.dart';
// import 'package:flutter/material.dart';

// import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';
// // import 'package:sembast/sembast.dart';

// import 'managers/call_manager.dart';

// class PreviewMeetingScreen extends StatefulWidget {
//   final CubeUser currentUser;
//   final List<CubeUser> users;
//   final InterviewSchedule interviewSchedule;
//   final P2PSession _callSession;

//   @override
//   State<PreviewMeetingScreen> createState() =>
//       _PreviewMeetingScreenState(_callSession);

//   const PreviewMeetingScreen(this.currentUser, this._callSession,
//       {super.key, required this.users, required this.interviewSchedule});
// }

// class _PreviewMeetingScreenState extends State<PreviewMeetingScreen>
//     with WidgetsBindingObserver {
//   final P2PSession _callSession;

//   // ignore: unused_field
//   static const String TAG = "PREVIEW_SCREEN";

//   final floating = Floating();

//   _PreviewMeetingScreenState(this._callSession);

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     try {
//       checkSystemAlertWindowPermission(context);
//     } catch (e) {
//       print("error");
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     try {
//       stopBackgroundExecution();
//     } catch (e) {
//       ///
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: MainAppBar(
//         name:
//             'Logged in as ${CubeChatConnection.instance.currentUser!.fullName}',
//       ),
//       body: OrientationBuilder(
//         builder: (context, orientation) {
//           if (orientation == Orientation.portrait) {
//             return Column(children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
//                 child: Column(
//                   children: [
//                     Text('Meeting: ${widget.interviewSchedule.title}'),
//                     Text(
//                         'Meeting id: ${widget.interviewSchedule.meetingRoomId}'),
//                     Text(
//                         'Meeting code: ${widget.interviewSchedule.meetingRoomCode}'),
//                   ],
//                 ),
//               ),
//               Expanded(
//                   child: BodyLayout(widget.currentUser, _callSession,
//                       users: widget.users,
//                       interviewInfo: widget.interviewSchedule)),
//             ]);
//           } else {
//             return Row(
//               children: [
//                 Expanded(
//                     child: BodyLayout(widget.currentUser, _callSession,
//                         users: widget.users,
//                         interviewInfo: widget.interviewSchedule)),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                   child: Column(
//                     children: [
//                       Text('Meeting: ${widget.interviewSchedule.title}'),
//                       Text(
//                           'Meeting id: ${widget.interviewSchedule.meetingRoomId}'),
//                       Text(
//                           'Meeting code: ${widget.interviewSchedule.meetingRoomCode}'),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// class BodyLayout extends StatefulWidget {
//   final CubeUser currentUser;
//   final List<CubeUser> users;
//   final InterviewSchedule interviewInfo;
//   final P2PSession _callSession;

//   @override
//   State<StatefulWidget> createState() => _BodyLayoutState();

//   const BodyLayout(this.currentUser, this._callSession,
//       {super.key, required this.users, required this.interviewInfo});
// }

// class _BodyLayoutState extends State<BodyLayout> {
//   late Set<int> _selectedUsers;

//   // bool _isCameraEnabled = true;
//   // bool _isSpeakerEnabled = Platform.isIOS ? false : true;
//   // bool _isMicMute = false;
//   // bool _isFrontCameraUsed = true;
//   late int _currentUserId;

//   // ToDo: check why this is null
//   MapEntry<int, RTCVideoRenderer>? primaryRenderer;
//   Map<int, RTCVideoRenderer> minorRenderers = {};
//   RTCVideoViewObjectFit primaryVideoFit =
//       RTCVideoViewObjectFit.RTCVideoViewObjectFitCover;
//   final CubeStatsReportsManager _statsReportsManager =
//       CubeStatsReportsManager();
//   late Future future;
//   @override
//   void initState() {
//     super.initState();
//     _selectedUsers = {};
//     _currentUserId = widget.currentUser.id!;
//     future = Future.value(() {
//       return Future.delayed(const Duration(seconds: 1), () {
//         return true;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("build");
//     return Container(
//         padding:
//             const EdgeInsets.only(top: 48, left: 48, right: 48, bottom: 12),
//         child: Column(
//           children: [
//             const Text(
//               "Select users to call:",
//               style: TextStyle(fontSize: 22),
//             ),
//             Expanded(
//               child: FutureBuilder(
//                 future: future,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return ConversationCallScreen(
//                       widget._callSession,
//                       false,
//                     );
//                   } else {
//                     return const LoadingScreenWidget();
//                   }
//                 },
//               ),
//             ),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: FloatingActionButton(
//                     heroTag: "VideoCall",
//                     backgroundColor: Colors.blue,
//                     onPressed: () => CallManager.instance.startNewCall(
//                         context, CallType.VIDEO_CALL, _selectedUsers),
//                     child: const Icon(
//                       Icons.videocam,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: FloatingActionButton(
//                     heroTag: "AudioCall",
//                     backgroundColor: Colors.green,
//                     onPressed: () => CallManager.instance.startNewCall(
//                         context, CallType.AUDIO_CALL, _selectedUsers),
//                     child: const Icon(
//                       Icons.call,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ));
//   }
// }
