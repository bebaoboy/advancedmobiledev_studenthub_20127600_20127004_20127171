import 'dart:io';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
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
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/notification/notification.dart';
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
  // ignore: prefer_final_fields
  Map<(String, String, String), MessageNotifierProvider> _messageNotifiers = {};
  MessageNotifierProvider? getMessageNotifiers(WrapMessageList chatObject) {
    var p = _messageNotifiers[(
      chatObject.project!.objectId,
      chatObject.chatUser.id,
      userStore.user!.objectId
    )];
    if (p != null) {
      return p;
    } else {
      _messageNotifiers[(
        chatObject.project!.objectId!,
        chatObject.chatUser.id,
        userStore.user!.objectId!
      )] = MessageNotifierProvider(
          user: chatObject.chatUser, project: chatObject.project);
      return _messageNotifiers[(
        chatObject.project!.objectId!,
        chatObject.chatUser.id,
        userStore.user!.objectId!
      )];
    }
  }

  @observable
  List<WrapMessageList> _messages = [];

  List<WrapMessageList> get messages => _messages;

  List<AbstractChatMessage> _currentProjectMessages = [];
  List<AbstractChatMessage> get currentProjectMessages =>
      _currentProjectMessages;

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
  ObservableFuture<Response?> checkFuture = emptyCheckResponse;

  bool get isChecking => checkFuture.status == FutureStatus.pending;

  @observable
  String meetingCode = '';

  void setCode(String value) {
    meetingCode = value.trim();
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
      return _getAllChatsUseCase
          .call(params: GetMessageByProjectAndUserParams())
          .then<List<WrapMessageList>>(
        (value) async {
          if (value.isNotEmpty) {
            print(value);

            for (var v in value) {
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
            }
            _messages.sort(
              (a, b) => (b.lastSeenTime == null || a.lastSeenTime == null)
                  ? 0
                  : b.lastSeenTime!.compareTo(a.lastSeenTime!),
            );
            // sharedPrefsHelper.saveCompanyMessages(_companyMessages);
            if (setStateCallback != null) setStateCallback();
            return _messages;
          } else {
            print(value);
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
    // //print(value);
  }

  /// userId của người NHẬN (sender)
  /// takes in userId and projectId
  /// this should fetch back the new content
  /// whenever user switch account type
  @action
  Future<List<AbstractChatMessage>> getMessageByProjectAndUsers(
      {required String userId,
      required String projectId,
      Function? setStateCallback}) async {
    if (projectId.trim().isEmpty || userId.trim().isEmpty) {
      return Future.value([]);
    }
    try {
      final future = _getMessageByProjectAndUsersUseCase
          .call(
              params: GetMessageByProjectAndUserParams(
                  userId: userId, projectId: projectId))
          .then(
        (value) async {
          if (value.isNotEmpty) {
            print(value);

            _currentProjectMessages = value;

            // sharedPrefsHelper.saveCompanyMessages(_companyMessages);

            _currentProjectMessages.sort(
              (a, b) {
                return b.updatedAt!.compareTo(a.updatedAt!);
              },
            );

            if (setStateCallback != null) setStateCallback();
            return _currentProjectMessages;
          } else {
            print(value);
            return Future.value([]);
          }
        },
      ).onError((error, stackTrace) async {
        return Future.value([]);
      });

      fetchChatHistoryFuture = ObservableFuture(future);
    } catch (e) {
      print("Cannot get chat history for this project");
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
    try {
      var params = InterviewParams(
          info.objectId, "", info.meetingRoomId, info.meetingRoomCode,
          title: info.title,
          startDate: info.startDate.toIso8601String(),
          endDate: info.endDate.toIso8601String());

      var future = _checkAvailUseCase.call(params: params);
      checkFuture = ObservableFuture(future);

      var response = await future;
      if (response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.created ||
          response.statusCode == HttpStatus.ok) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);

      errorStore.errorMessage = "Failed to check";
      return false;
    }
  }
}
