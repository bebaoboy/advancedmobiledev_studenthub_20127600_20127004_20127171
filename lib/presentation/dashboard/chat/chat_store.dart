// ignore_for_file: unused_field, prefer_final_fields

import 'dart:io';
import 'dart:math';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/usecase/chat/disable_interview.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/usecase/chat/check_avail.dart';

import 'package:boilerplate/domain/usecase/chat/get_all_chat.dart';
import 'package:boilerplate/domain/usecase/chat/get_interview.dart';
import 'package:boilerplate/domain/usecase/chat/get_message_by_project_and_user.dart';
import 'package:boilerplate/domain/usecase/chat/schedule_interview.dart';
import 'package:boilerplate/domain/usecase/chat/update_interview.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:boilerplate/presentation/dashboard/chat/message_notifier.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/message/schedule_message.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/notification/notification.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';

part 'chat_store.g.dart';

class ChatStore = _ChatStore with _$ChatStore;

abstract class _ChatStore with Store {
  _ChatStore(
      this._getMessageByProjectAndUsersUseCase,
      this._getAllChatsUseCase,
      this._scheduleInterviewUseCase,
      this._checkAvailUseCase,
      this._disableInterviewUseCase,
      this._updateInterviewUseCase,
      this._getInterviewUseCase);

  // student
  final GetMessageByProjectAndUsersUseCase _getMessageByProjectAndUsersUseCase;
  final GetAllChatsUseCase _getAllChatsUseCase;
  final ScheduleInterviewUseCase _scheduleInterviewUseCase;
  final DisableInterviewUseCase _disableInterviewUseCase;
  final UpdateInterviewUseCase _updateInterviewUseCase;
  final GetInterviewUseCase _getInterviewUseCase;
  final CheckMeetingAvailabilityUseCase _checkAvailUseCase;

  final ErrorStore errorStore = getIt<ErrorStore>();
  final userStore = getIt<UserStore>();

  @observable
  Map<String, MessageNotifierProvider> _messageNotifiers = {};
  MessageNotifierProvider? getMessageNotifiers(WrapMessageList chatObject) {
    var p = _messageNotifiers[chatObject.project!.objectId];
    if (p != null) {
      return p;
    } else {
      _messageNotifiers[chatObject.project!.objectId!] =
          MessageNotifierProvider(
              project: chatObject.project,
              addInboxCb: (Map<String, dynamic> data, inbox, bool isInterview) {
                return addInbox(
                    data,
                    inbox,
                    chatObject.project!,
                    ChatUser(
                        id: data["notification"]["sender"] != null
                            ? data["notification"]["sender"]["id"].toString()
                            : "-1",
                        firstName: data["notification"]["sender"] != null
                            ? data["notification"]["sender"]["fullname"]
                                .toString()
                            : "null"),
                    isInterview);
              });
      return _messageNotifiers[chatObject.project!.objectId!];
    }
  }

  var rand = Random();

  Set<String> msgIdDict = {};

  AbstractChatMessage? addInbox(
      Map<String, dynamic> msg,
      List<AbstractChatMessage> _,
      Project project,
      ChatUser user,
      bool isInterview) {
    Map<String, dynamic> message = msg["notification"]["message"];
    if (message["receiverId"].toString() != userStore.user!.objectId) {
      return null;
    }
    if (message["projectId"].toString() != project.objectId) {
      return null;
    }
    String mess = message["id"].toString();
    print("receive id dict: $mess");

    if (!msgIdDict.contains(message["id"].toString())) {
      msgIdDict.add(message["id"].toString());
      print("project ${project.objectId},message sentttttttttttt: $message");

      if (!isInterview) {
        NotificationHelper.createMessageNotification(
            id: mess.isNotEmpty
                ? int.tryParse(mess) ?? rand.nextInt(100000)
                : rand.nextInt(100000),
            projectId: project.objectId ?? "-1",
            msg: MessageObject(
                project: project,
                id: mess,
                content: message["content"] ?? message["title"],
                receiver: Profile(objectId: "-1", name: "Quan"),
                sender: Profile(
                    objectId: user.id, name: user.firstName ?? "null")));

        // text msg
        var e = <String, dynamic>{
          ...message,
          "createdAt":
              (DateTime.tryParse(message['createdAt'] ?? "") ?? DateTime.now())
                  .millisecondsSinceEpoch,
          "updatedAt":
              (DateTime.tryParse(message['updatedAt'] ?? "") ?? DateTime.now())
                  .millisecondsSinceEpoch,
          "id": mess,
          'type': message['messageFlag'] == 0 ? 'text' : 'interview',
          'text': message['content'],
          'status': 'seen',
          'interview': message['interview'] ?? {},
          'author': {
            "firstName": message["senderId"].toString() == user.id
                ? user.firstName
                : userStore.user!.name,
            "id": message["senderId"].toString(),
          }
        };

        var m = AbstractChatMessage.fromJson(e);
        // var pp = _messages.firstWhereOrNull(
        //   (element) =>
        //       element.project?.objectId == project.objectId &&
        //       element.chatUser.id == user.id,
        // );
        // if (pp != null) {
        //   pp.messages?.first = MessageObject(
        //       createdAt: DateTime.tryParse(message['createdAt'] ?? "") ??
        //           DateTime.now(),
        //       updatedAt: DateTime.tryParse(message['updatedAt'] ?? "") ??
        //           DateTime.now(),
        //       project: project,
        //       id: mess,
        //       content: message["content"] ?? message["title"],
        //       receiver: Profile(objectId: "-1", name: "null"),
        //       sender:
        //           Profile(objectId: user.id, name: user.firstName ?? "null"));
        //   _messages.sort(
        //     (a, b) => (b.messages == null || a.messages == null)
        //         ? 0
        //         : b.messages!.first.updatedAt!
        //             .compareTo(a.messages!.first.updatedAt!),
        //   );
        //   // pp.lastSeenTime =
        //   //     pp.messages?.first.updatedAt ?? pp.messages?.first.createdAt;
        // }
        insertMessage(user, project, m, false, incoming: true);

        // ignore: invalid_use_of_protected_member
        _messages.sort(
          (a, b) => (b.messages == null || a.messages == null)
              ? 0
              : b.messages!.first.updatedAt!
                  .compareTo(a.messages!.first.updatedAt!),
        );
        return m;
      } else {
        // TODO: làm bấm vô nó vào msg
        NotificationHelper.createTextNotification(
          id: mess.isNotEmpty
              ? int.tryParse(mess) ?? rand.nextInt(100000)
              : rand.nextInt(100000),
          body: "New interview: ${msg["notification"]["interview"]['title']}",
        );

        // interview msg
        // var id = message["interviewId"].toString();
        // var projectStore = getIt<ChatStore>();
        // var interview = await projectStore.getInterview(interviewId: id);
        var interview = msg["notification"]["interview"];
        var meeting = msg["notification"]["meeting"];

        var e = <String, dynamic>{
          ...message,
          "id": mess,
          'type': 'schedule',
          'text': message['content'],
          'status': 'seen',
          'interview': interview,
          "createdAt":
              (DateTime.tryParse(message['createdAt'] ?? "") ?? DateTime.now())
                  .millisecondsSinceEpoch,
          "updatedAt":
              (DateTime.tryParse(message['updatedAt'] ?? "") ?? DateTime.now())
                  .millisecondsSinceEpoch,
          'author': {
            "firstName": message["senderId"].toString() == user.id
                ? user.firstName
                : userStore.user!.name,
            "id": message["senderId"].toString(),
          },
          "metadata": {
            "title": interview?['title'],
            "projectId": project.objectId ?? "-1",
            "senderId": user.id,
            "receiverId": userStore.user!.objectId!, // notification
            "createdAt": interview?["createdAt"],
            "updatedAt": interview?["updatedAt"],
            "meeting_room_code": meeting?["meeting_code_id"],
            "meeting_room_id": meeting?["meeting_room_id"],
          }
        };

        var m = AbstractChatMessage.fromJson(e);
        // var pp = _messages.firstWhereOrNull(
        //   (element) =>
        //       element.project?.objectId == project.objectId &&
        //       element.chatUser.id == user.id,
        // );
        // if (pp != null) {
        //   pp.messages?.first = MessageObject(
        //       createdAt: DateTime.tryParse(message['createdAt'] ?? "") ??
        //           DateTime.now(),
        //       updatedAt: DateTime.tryParse(message['updatedAt'] ?? "") ??
        //           DateTime.now(),
        //       project: project,
        //       id: mess,
        //       content: message["content"] ?? message["title"],
        //       receiver: Profile(objectId: "-1", name: "null"),
        //       interviewSchedule: interview != null
        //           ? InterviewSchedule.fromJsonApi(interview)
        //           : null,
        //       sender:
        //           Profile(objectId: user.id, name: user.firstName ?? "null"));
        //   // pp.lastSeenTime =
        //   //     pp.messages?.first.updatedAt ?? pp.messages?.first.createdAt;
        //   _messages.sort(
        //     (a, b) => (b.messages == null || a.messages == null)
        //         ? 0
        //         : b.messages!.first.updatedAt!
        //             .compareTo(a.messages!.first.updatedAt!),
        //   );
        // }
        insertMessage(user, project, m, false, incoming: true);

        // ignore: invalid_use_of_protected_member
        return m;
      }
    } else {
      print("trùng message id ${message["id"]}");
      return null;
    }
  }

  @observable
  List<WrapMessageList> _messages = [];
  @computed
  List<WrapMessageList> get messages => _messages;

  @observable
  ObservableMap<String, ObservableMap<String, List<AbstractChatMessage>>>
      _currentProjectMessages = ObservableMap(name: "currentProjectMessages");
  @computed
  List<AbstractChatMessage> get currentProjectMessages {
    return _currentProjectMessages[_currentProject]?[_currentUser] ?? [];
  }

  Map<String, Map<String, List<AbstractChatMessage>>>
      get currentProjectMessageMap => _currentProjectMessages;

  String _currentUser = "", _currentProject = "";

  changeMessageScreen(String userId, String projectId) {
    _currentProject = projectId;
    _currentUser = userId;
  }

  @observable
  Map<String, WrapMessageList> _projectMessages = {};

  static ObservableFuture<List?> emptyFetchResponse =
      ObservableFuture.value(null);

  static ObservableFuture<Response?> emptyCheckResponse =
      ObservableFuture.value(null);

  @observable
  ObservableFuture<List?> fetchChatHistoryFuture = emptyFetchResponse;

  bool get isFetching => fetchChatHistoryFuture.status == FutureStatus.pending;
  @observable
  ObservableFuture<List?> fetchAllChatFuture = emptyFetchResponse;

  bool get isFetchingAll => fetchAllChatFuture.status == FutureStatus.pending;
  @observable
  ObservableFuture<Response?> checkFuture = emptyCheckResponse;

  /// for check availability meeting
  bool get isChecking => checkFuture.status == FutureStatus.pending;

  /// for checking code from student
  String meetingCode = '';

  void setCode(String value) {
    meetingCode = value.trim();
  }

  sort() {
    _messages.sort(
      (a, b) => b.messages!.firstOrNull!.updatedAt!
          .compareTo(a.messages!.firstOrNull!.updatedAt!),
    );
  }

  @computed
  bool get canCall => meetingCode.isNotEmpty;

  // ToDo:
  // for storing sent message while in fetching mode
  // or better other type of media
  // could consider adding connectivity to it
  @observable
  Map<ChatUser, String> pendingMessage = <ChatUser, String>{};

  // List<MessageObject> getProjectMessages(String id) =>
  //     _projectMessages.containsKey(id)
  //         ? _projectMessages[id]!.messages ?? []
  //         : [];

  @action
  Future<List<WrapMessageList>> getAllChat({Function? setStateCallback}) async {
    try {
      var userStore = getIt<UserStore>();
      msgIdDict.clear();
      if (!isFetchingAll) {
        final future = _getAllChatsUseCase
            .call(params: GetMessageByProjectAndUserParams())
            .then<List<WrapMessageList>>(
          (value) async {
            if (value.isNotEmpty) {
              // print(value);

              for (var v in value) {
                if (v.messages?.firstOrNull != null) {
                  msgIdDict.add(v.messages!.firstOrNull!.id);
                }
                if (v.project != null && v.project!.objectId != null) {
                  _currentProjectMessages[v.project!.objectId!] =
                      ObservableMap();
                }
                var p = _messages.firstWhereOrNull(
                  (element) =>
                      element.project?.objectId == v.project?.objectId &&
                      element.chatUser.id == v.chatUser.id,
                );
                if (p != null) {
                  p.messages = v.messages;

                  p.messages?.sort(
                    (a, b) {
                      return b.updatedAt!.compareTo(a.updatedAt!);
                    },
                  );
                  if (p.messages?.firstOrNull?.sender.objectId ==
                      userStore.user?.objectId) {
                    p.lastSeenTime = p.messages?.firstOrNull?.updatedAt;
                  }
                } else {
                  print("not found $v");
                  _messages.add(v);
                  _messages.last.messages?.sort(
                    (a, b) {
                      return b.updatedAt!.compareTo(a.updatedAt!);
                    },
                  );
                  _messages.last.lastSeenTime =
                      v.messages?.firstOrNull?.updatedAt;

                  // _messages.removeWhere(
                  //   (element) =>
                  //       element.project?.objectId == v.project?.objectId &&
                  //       element.chatUser.id == v.chatUser.id,
                  // );
                }
                getMessageNotifiers(v);
              }
              Future.delayed(Duration.zero, () {
                _messages.removeWhere(
                  (element) =>
                      element.lastSeenTime == null || element.messages == null,
                );
                _messages.sort(
                  (a, b) => b.messages!.firstOrNull!.updatedAt!
                      .compareTo(a.messages!.firstOrNull!.updatedAt!),
                );
                // sharedPrefsHelper.saveCompanyMessages(_companyMessages);
                var c =
                    messages.fold(0, (sum, item) => sum + item.newMessageCount);
                if (c > 0) {
                  NavbarNotifier2.updateBadge(
                      2, NavbarBadge(showBadge: true, badgeText: "$c"));
                }
                if (setStateCallback != null) setStateCallback();
              });

              return _messages;
            } else {
              // print(value);
              // var companies = await sharedPrefsHelper.getCompanyMessages();
              // if (companies.messages != null && companies.messages!.isNotEmpty) {
              //   {
              //     _companyMessages = companies;
              //     _companyMessages.messages?.sort(
              //       (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
              //     );
              //     if (setStateCallback != null) setStateCallback();

              //     return _companyMessages;
              //   }
              // }
              return Future.value(_messages);
            }
          },
        ).onError((error, stackTrace) async {
          // var companies = await sharedPrefsHelper.getCompanyMessages();
          // if (companies.messages != null && companies.messages!.isNotEmpty) {
          //   {
          //     _companyMessages = companies;
          //     _companyMessages.messages?.sort(
          //       (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
          //     );
          //     if (setStateCallback != null) setStateCallback();

          //     return _companyMessages;
          //   }
          // }
          print(error);
          print(stackTrace);
          return Future.value(_messages);
        });
        fetchAllChatFuture = ObservableFuture(future);
      }
    } catch (e) {
      // errorStore.errorMessage = "cannot save student profile";

      // var companies = await sharedPrefsHelper.getCompanyMessages();
      // if (companies.messages != null && companies.messages!.isNotEmpty) {
      //   {
      //     _companyMessages = companies;
      //     _companyMessages.messages?.sort(
      //       (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
      //     );
      //     if (setStateCallback != null) setStateCallback();

      //     return _companyMessages;
      //   }
      // }
      print("cannot get profile company");
      if (setStateCallback != null) setStateCallback();

      return Future.value(_messages);
    }

    return Future.value(_messages);
    // //print(value);
  }

  @action
  Future insertMessage(
      ChatUser user, Project project, AbstractChatMessage message, bool isMe,
      {bool incoming = false}) async {
    if (message.type == AbstractMessageType.schedule ||
        message.type == AbstractMessageType.text) {
      if (incoming) {
        if (currentProjectMessageMap[project.objectId!]?[user.id] == null) {
          // currentProjectMessageMap[project.objectId!]![user.id] = [];
          await getMessageByProjectAndUsers(
              chatObject: WrapMessageList(
                  chatUser: user, project: project, messages: []),
              quickUpdate: true);
        }
        currentProjectMessageMap[project.objectId!]?[user.id]
            ?.insert(0, message);
      }
      var pp = _messages.firstWhereOrNull(
        (element) =>
            element.project?.objectId == project.objectId &&
            element.chatUser.id == user.id,
      );

      if (pp != null) {
        pp.messages ??= [];
        if (pp.messages!.isEmpty) {
          print("add msg for ${project.objectId} user ${user.id}");
          pp.messages!.add(MessageObject(
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                  message.createdAt ?? DateTime.now().millisecondsSinceEpoch),
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                  message.updatedAt ?? DateTime.now().millisecondsSinceEpoch),
              project: project,
              id: message.id,
              content: message.type == AbstractMessageType.schedule
                  ? ((message as ScheduleMessageType).metadata?["title"] ??
                      (message).id)
                  : message.type == AbstractMessageType.text
                      ? (message as AbstractTextMessage).text
                      : "type not supported",
              receiver: Profile(objectId: "-1", name: "null"),
              interviewSchedule: message.type == AbstractMessageType.schedule
                  ? InterviewSchedule.fromJsonApi(message.metadata!)
                  : null,
              sender:
                  Profile(objectId: user.id, name: user.firstName ?? "null")));
        } else {
          print("replace msg for ${project.objectId} user ${user.id}");

          pp.messages?.first = MessageObject(
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                  message.createdAt ?? DateTime.now().millisecondsSinceEpoch),
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                  message.updatedAt ?? DateTime.now().millisecondsSinceEpoch),
              project: project,
              id: message.id,
              content: message.type == AbstractMessageType.schedule
                  ? ((message as ScheduleMessageType).metadata?["title"] ??
                      (message).id)
                  : message.type == AbstractMessageType.text
                      ? (message as AbstractTextMessage).text
                      : "type not supported",
              receiver: Profile(objectId: "-1", name: "null"),
              interviewSchedule: message.type == AbstractMessageType.schedule
                  ? InterviewSchedule.fromJsonApi(message.metadata!)
                  : null,
              sender:
                  Profile(objectId: user.id, name: user.firstName ?? "null"));
        }
        if (isMe) {
          pp.lastSeenTime = DateTime.now();
        }
        _messages.sort(
          (a, b) => (b.messages == null || a.messages == null)
              ? 0
              : b.messages!.first.updatedAt!
                  .compareTo(a.messages!.first.updatedAt!),
        );
      } else {
        _messages.insert(
            0,
            WrapMessageList(chatUser: user, project: project, messages: [
              MessageObject(
                  createdAt: DateTime.fromMillisecondsSinceEpoch(
                      message.createdAt ??
                          DateTime.now().millisecondsSinceEpoch),
                  updatedAt: DateTime.fromMillisecondsSinceEpoch(
                      message.updatedAt ??
                          DateTime.now().millisecondsSinceEpoch),
                  project: project,
                  id: message.id,
                  content: message.type == AbstractMessageType.schedule
                      ? ((message as ScheduleMessageType).metadata?["title"] ??
                          (message).id)
                      : message.type == AbstractMessageType.text
                          ? (message as AbstractTextMessage).text
                          : "type not supported",
                  receiver: Profile(objectId: "-1", name: "null"),
                  interviewSchedule:
                      message.type == AbstractMessageType.schedule
                          ? InterviewSchedule.fromJsonApi(message.metadata!)
                          : null,
                  sender: Profile(
                      objectId: user.id, name: user.firstName ?? "null"))
            ]));
      }
    } else {
      currentProjectMessageMap[project.objectId!]?[user.id]?.insert(0, message);
    }
    var c = messages.fold(0, (sum, item) => sum + item.newMessageCount);
    if (c > 0) {
      NavbarNotifier2.updateBadge(
          2, NavbarBadge(showBadge: true, badgeText: "$c"));
    }
  }

  /// userId của người NHẬN (sender)
  /// takes in userId and projectId
  /// this should fetch back the new content
  /// whenever user switch account type
  @action
  Future<List<AbstractChatMessage>> getMessageByProjectAndUsers(
      {required WrapMessageList chatObject,
      Function? setStateCallback,
      bool quickUpdate = false}) async {
    String userId = chatObject.chatUser.id,
        projectId = chatObject.project!.objectId!;
    if (projectId.trim().isEmpty || userId.trim().isEmpty) {
      return Future.value([]);
    }
    if (!quickUpdate) {
      _currentProject = projectId;
      _currentUser = userId;
    }
    getMessageNotifiers(chatObject);
    // TODO: lưu vào sharedpref
    if (_currentProjectMessages[projectId] == null ||
        _currentProjectMessages[projectId]?[userId] == null) {
      try {
        final future = _getMessageByProjectAndUsersUseCase
            .call(
                params: GetMessageByProjectAndUserParams(
                    userId: userId, projectId: projectId))
            .then(
          (value) async {
            // print(value);
            if (_currentProjectMessages[projectId] == null) {
              _currentProjectMessages[projectId] = ObservableMap();
            }
            if (_currentProjectMessages[projectId]![userId] == null &&
                _messages.firstWhereOrNull(
                      (element) =>
                          element.project?.objectId == projectId &&
                          element.chatUser.id == userId,
                    ) ==
                    null) {
              print("add msg because $userId not have");
              _messages.insert(0, chatObject..messages = []);
              _messages.first.lastSeenTime = DateTime(0);
            }
            _currentProjectMessages[projectId]![userId] = value;

            // sharedPrefsHelper.saveCompanyMessages(_companyMessages);

            _currentProjectMessages[projectId]![userId]?.sort(
              (a, b) {
                return b.updatedAt!.compareTo(a.updatedAt!);
              },
            );

            if (setStateCallback != null) setStateCallback();
            return _currentProjectMessages[projectId]![userId];
          },
        ).onError((error, stackTrace) async {
          return Future.value(_currentProjectMessages[projectId]![userId]);
        });
        if (!quickUpdate) {
          fetchChatHistoryFuture = ObservableFuture(future);
          await fetchChatHistoryFuture;
        } else {
          await future;
        }
      } catch (e) {
        print("Cannot get chat history for this project");
      }
    } else {
      return Future.value(currentProjectMessages);
    }
    return Future.value([]);

    // //print(value);
  }

  @action
  Future<bool> scheduleInterview(
      {required int projectId,
      required String title,
      required DateTime startTime,
      required DateTime endTime}) async {
    var params = InterviewParams("", "", "", "",
        title: title,
        startDate: startTime.toIso8601String(),
        endDate: endTime.toIso8601String());

    return await _scheduleInterviewUseCase.call(params: params).then((value) {
      if (value == null) {
        print('Schedule fail');
        return false;
      } else {
        // Todo: schedule notification before interview 15min
        Duration diff = endTime.difference(startTime);

        NotificationHelper.scheduleNewNotification(
            diff.inMinutes, diff.inHours, diff.inDays);
        return true;
      }
    });
  }

  @action
  Future<InterviewSchedule?> getInterview({
    required String interviewId,
  }) async {
    var params = InterviewParams(interviewId, "", "", "",
        title: "", endDate: "", startDate: "");

    return await _getInterviewUseCase.call(params: params).then((value) {
      if (value == null) {
        print('Get fail');
        return null;
      } else {
        // Todo: schedule notification before interview 15min
        // Duration diff = endTime.difference(startTime);

        // NotificationHelper.scheduleNewNotification(
        //     diff.inMinutes, diff.inHours, diff.inDays);
        print(value);
        return value;
      }
    });
  }

  @action
  Future<bool> disableInterview({
    required String interviewId,
  }) async {
    var params = InterviewParams(interviewId.toString(), "", "", "",
        title: "", endDate: "", startDate: "");

    try {
      var response = await _disableInterviewUseCase.call(params: params);
      if (response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        // var data = response.data['result'];
        print(response.data);
        return true;
      } else {
        print(response.data);
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  @action
  Future<bool> updateInterview(
      {required String interview,
      required String title,
      required DateTime startTime,
      required DateTime endTime}) async {
    var params = InterviewParams(interview, "", "", "",
        title: title,
        endDate: endTime.toUtc().toIso8601String(),
        startDate: startTime.toUtc().toIso8601String());

    try {
      var response = await _updateInterviewUseCase.call(params: params);
      if (response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        // var data = response.data['result'];
        print(response.data);
        return true;
      } else {
        print(response.data);
        return false;
      }
    } catch (e) {
      print(e);

      errorStore.errorMessage = "Failed to check";
      return false;
    }
  }

  Future<bool> checkMeetingAvailability(
      InterviewSchedule info, String projectId) async {
    if (!canCall) {
      errorStore.errorMessage = "Empty code";
      return Future.value(false);
    }
    try {
      var params = InterviewParams(
          info.objectId, "", info.meetingRoomId, meetingCode,
          title: info.title,
          startDate: info.startDate.toIso8601String(),
          endDate: info.endDate.toIso8601String());

      var future = _checkAvailUseCase.call(params: params);
      checkFuture = ObservableFuture(future);
      await checkFuture;

      var response = await future;
      if (response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.created ||
          response.statusCode == HttpStatus.ok) {
        return true;
      } else {
        print(response.data['errorDetails']);
        errorStore.errorMessage = "Wrong meeting code!";
        return false;
      }
    } catch (e) {
      print(e);

      errorStore.errorMessage = "Failed to check";
      return false;
    }
  }
}
