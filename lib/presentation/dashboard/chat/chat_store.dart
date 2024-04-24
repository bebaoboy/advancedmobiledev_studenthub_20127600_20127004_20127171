import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';

import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/usecase/chat/get_all_chat.dart';
import 'package:boilerplate/domain/usecase/chat/get_message_by_project_and_user.dart';
import 'package:mobx/mobx.dart';

part 'chat_store.g.dart';

class ChatStore = _ChatStore with _$ChatStore;

abstract class _ChatStore with Store {
  _ChatStore(
      this._getMessageByProjectAndUsersUseCase, this._getAllChatsUseCase);

  // student
  final GetMessageByProjectAndUsersUseCase _getMessageByProjectAndUsersUseCase;
  final GetAllChatsUseCase _getAllChatsUseCase;

  final ErrorStore errorStore = getIt<ErrorStore>();

  @observable
  List<WrapMessageList> _messages = [];

  List<WrapMessageList> get messages => _messages;

  @observable
  Map<String, WrapMessageList> _projectMessages = {};

  List<MessageObject> getprojectMessages(String id) =>
      _projectMessages.containsKey(id)
          ? _projectMessages[id]!.messages ?? []
          : [];

  @action
  Future<List<WrapMessageList>> getAllChat({Function? setStateCallback}) async {
    try {
      _getAllChatsUseCase.call(params: GetMessageByProjectAndUserParams()).then(
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
  @action
  Future<List<WrapMessageList>> getMessageByProjectAndUsers(
      {required String userId,
      required String projectId,
      Function? setStateCallback}) async {
    if (projectId.trim().isEmpty || userId.trim().isEmpty) {
      return Future.value([]);
    }
    try {
      _getMessageByProjectAndUsersUseCase.call(params: GetMessageByProjectAndUserParams(userId: userId, projectId: projectId)).then(
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
}
