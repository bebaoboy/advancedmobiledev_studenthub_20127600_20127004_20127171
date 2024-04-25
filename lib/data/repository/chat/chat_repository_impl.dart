// ignore_for_file: unused_field

import 'dart:io';

import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/network/apis/chat/chat_api.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/repository/chat/chat_repository.dart';
import 'package:boilerplate/domain/usecase/chat/get_message_by_project_and_user.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';

class ChatRepositoryImpl extends ChatRepository {
  final ChatApi _chatApi;
  final ProjectDataSource _datasource;
  final SharedPreferenceHelper _sharedPrefHelper;
  ChatRepositoryImpl(this._chatApi, this._datasource, this._sharedPrefHelper);

  @override
  Future<List<WrapMessageList>> getAllChat(
      GetMessageByProjectAndUserParams params) async {
    return await _chatApi.getAllChat(params).then(
      (value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          List json = value.data["result"];
          List<WrapMessageList> list = [];
          for (var element in json) {
            List<MessageObject> j = [];
            List r = element["messages"];
            for (var element in r) {
              j.add(MessageObject.fromJson(element));
            }
            var p = Project.fromMap(element["project"]);
            WrapMessageList ml = WrapMessageList(
                messages: j,
                project: p,
                chatUser: ChatUser(
                    id: j.first.sender.objectId ?? "-1",
                    firstName: j.first.sender.getName));
            list.add(ml);
          }

          return list;
        } else {
          // return ProjectList(projects: List.empty(growable: true));
          // return _datasource.getProjectsFromDb() as ProjectList;
          return [];
        }
      },
    );

    // ignore: invalid_return_type_for_catch_error
  }

  @override
  Future<List<WrapMessageList>> getMessageByProjectAndUser(
      GetMessageByProjectAndUserParams params) async {
    try {
      return await _chatApi.getMessageByProjectAndUser(params).then(
        (value) {
          if (value.statusCode == HttpStatus.accepted ||
              value.statusCode == HttpStatus.ok ||
              value.statusCode == HttpStatus.created) {
            List json = value.data["result"];
            List<WrapMessageList> list = [];
            for (var element in json) {
              List<MessageObject> j = [];
              j.add(MessageObject.fromJson(element));
              WrapMessageList ml = WrapMessageList(
                  messages: j,
                  project: Project(
                      id: params.projectId,
                      title: "",
                      timeCreated: DateTime.now(),
                      description: ""),
                  chatUser: ChatUser(
                      id: j.first.sender.objectId ?? "-1",
                      firstName: j.first.sender.getName));
              list.add(ml);
            }

            return list;
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
  }
}
