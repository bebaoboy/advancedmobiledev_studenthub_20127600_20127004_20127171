import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';

import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/usecase/chat/get_all_chat.dart';
import 'package:boilerplate/domain/usecase/chat/get_message_by_project_and_user.dart';
import 'package:boilerplate/domain/usecase/chat/schedule_interview.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:boilerplate/utils/notification/notification.dart';
import 'package:mobx/mobx.dart';

part 'chat_store.g.dart';

class ChatStore = _ChatStore with _$ChatStore;

abstract class _ChatStore with Store {
  _ChatStore(this._getMessageByProjectAndUsersUseCase, this._getAllChatsUseCase,
      this._scheduleInterviewUseCase);

  // student
  final GetMessageByProjectAndUsersUseCase _getMessageByProjectAndUsersUseCase;
  final GetAllChatsUseCase _getAllChatsUseCase;
  final ScheduleInterviewUseCase _scheduleInterviewUseCase;

  final ErrorStore errorStore = getIt<ErrorStore>();

  @observable
  List<WrapMessageList> _messages = [];

  List<WrapMessageList> get messages => _messages;

  List<AbstractChatMessage> _currentProjectMessages = [];
  List<AbstractChatMessage> get currentProjectMessages =>
      _currentProjectMessages;

  @observable
  Map<String, WrapMessageList> _projectMessages = {};

  static ObservableFuture<List?> emptyLoginResponse =
      ObservableFuture.value(null);

  @observable
  ObservableFuture<List?> fetchChatHistoryFuture = emptyLoginResponse;

  bool get isFetching => fetchChatHistoryFuture.status == FutureStatus.pending;

  // ToDo:
  // for storing sent message while in fetching mode
  // or better other type of media
  // could consider adding connectivity to it
  @observable
  Map<ChatUser, String> pendingMessage = <ChatUser, String>{};

  List<MessageObject> getProjectMessages(String id) =>
      _projectMessages.containsKey(id)
          ? _projectMessages[id]!.messages ?? []
          : [];

  @action
  Future<List<WrapMessageList>> getAllChat({Function? setStateCallback}) async {
    try {
      return _getAllChatsUseCase
          .call(params: GetMessageByProjectAndUserParams())
          .then<List<WrapMessageList>>(
        (value) async {
          if (value.isNotEmpty) {
            print(value);

            _messages = value;

            // sharedPrefsHelper.saveCompanyMessages(_companyMessages);

            for (var element in _messages) {
              element.messages?.sort(
                (a, b) => b.createdAt!.compareTo(a.createdAt!),
              );
            }

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
            return Future.value([]);
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
        return Future.value([]);
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
    }
    return Future.value([]);

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
              (a, b) => b.createdAt!.compareTo(a.createdAt!),
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
    var params = InterviewParams("", "",
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
}
