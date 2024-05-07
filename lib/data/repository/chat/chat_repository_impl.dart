// ignore_for_file: unused_field

import 'dart:io';

import 'package:boilerplate/data/local/datasources/chat/chat_datasource.dart';
import 'package:boilerplate/data/network/apis/chat/chat_api.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/repository/chat/chat_repository.dart';
import 'package:boilerplate/domain/usecase/chat/get_message_by_project_and_user.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';

class ChatRepositoryImpl extends ChatRepository {
  final ChatApi _chatApi;
  final ChatDataSource _datasource;
  final SharedPreferenceHelper _sharedPrefHelper;
  ChatRepositoryImpl(this._chatApi, this._datasource, this._sharedPrefHelper);

  @override
  Future<List<WrapMessageList>> getAllChat(
      GetMessageByProjectAndUserParams params) async {
    var userStore = getIt<UserStore>();
    if (await DeviceUtils.hasConnection()) {
      return await _chatApi.getAllChat(params).then(
        (value) async {
          if (value.statusCode == HttpStatus.accepted ||
              value.statusCode == HttpStatus.ok ||
              value.statusCode == HttpStatus.created) {
            List json = value.data["result"];
            List<WrapMessageList> list = [];
            // int currentId = await _sharedPrefHelper.currentUserId;

            for (var element in json) {
              List<MessageObject> j = [];
              j.add(MessageObject.fromJson(element));
              var p = Project.fromMap(element["project"]);

              WrapMessageList ml = WrapMessageList(
                  messages: j,
                  project: p,
                  chatUser: j.first.sender.objectId! != userStore.user!.objectId
                      ? ChatUser(
                          id: j.first.sender.objectId ?? "-1",
                          firstName: j.first.sender.getName)
                      : ChatUser(
                          id: j.first.receiver.objectId ?? "-1",
                          firstName: j.first.receiver.getName));
              list.add(ml);
            }
            list.sort(
              (a, b) => (a.messages != null && b.messages != null)
                  ? b.messages!.first.createdAt!
                      .compareTo(a.messages!.first.createdAt!)
                  : 0,
            );

            for (var element in list) {
              _datasource.insert(element, userStore.user!.objectId!);
            }

            return list;
          } else {
            // return ProjectList(projects: List.empty(growable: true));
            return _datasource.getListChatObjectFromDb()
                as List<WrapMessageList>;
          }
        },
      );
    } else {
      return _datasource.getListChatObjectFromDb();
    }

    // ignore: invalid_return_type_for_catch_error
  }

  @override
  Future<List<AbstractChatMessage>> getMessageByProjectAndUser(
      GetMessageByProjectAndUserParams params) async {
    // var userStore = getIt<UserStore>();
    if (await DeviceUtils.hasConnection()) {
      try {
        List<Map<String, dynamic>> resRaw = [];
        return await _chatApi.getMessageByProjectAndUser(params).then(
          (value) {
            if (value.statusCode == HttpStatus.accepted ||
                value.statusCode == HttpStatus.ok ||
                value.statusCode == HttpStatus.created) {
              List data = value.data["result"];
              List<AbstractChatMessage> res = List.empty(growable: true);
              for (var element in data) {
                var e = <String, dynamic>{
                  ...element,
                  'id': element['id'].toString(),
                  'type': element['interview'] != null ? "schedule" : 'text',
                  'text': element['content'],
                  'status': 'seen',
                  'interview': element['interview'] ?? {},
                  'createdAt': DateTime.parse(
                          (element['interview'] ?? element)['createdAt'])
                      .millisecondsSinceEpoch,
                  'updatedAt': DateTime.parse(
                          (element['interview'] ?? element)['updatedAt'] ??
                              element['createdAt'])
                      .millisecondsSinceEpoch,
                  'author': {
                    "firstName": element['sender']['fullname'],
                    "id": element['sender']['id'].toString(),
                  }
                };
                if (element['interview'] != null) {
                  e.putIfAbsent("metadata", () => element['interview']);
                }
                var acm = AbstractChatMessage.fromJson(e);
                resRaw.add(e);
                if (!res.contains(acm)) {
                  res.add(acm);
                }
              }

              // _datasource.insertOrReplaceChatContent(
              //     int.parse(params.projectId),
              //     int.parse(params.userId),
              //     resRaw);

              return res;
            } else {
              // return ProjectList(projects: List.empty(growable: true));
              // return _datasource.getProjectsFromDb() as ProjectList;
              return [];
            }
          },
        );

        // ignore: invalid_return_type_for_catch_error
      } catch (e) {
        print(e.toString());
        // return _datasource.getProjectsFromDb();
        return [];
      }
    } else {
      return [];
    }
  }
}
