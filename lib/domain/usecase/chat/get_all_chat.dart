import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/repository/chat/chat_repository.dart';
import 'package:dio/dio.dart';

class GetMessageByProjectAndUserParams {
  String projectId;
  String userId;

  GetMessageByProjectAndUserParams({this.projectId = "", this.userId = ""});
}

class GetMessageByProjectAndUsersUseCase
    extends UseCase<Response, GetMessageByProjectAndUserParams> {
  final ChatRepository _chatRepository;
  GetMessageByProjectAndUsersUseCase(this._chatRepository);

  @override
  Future<Response> call({required GetMessageByProjectAndUserParams params}) {
    return _chatRepository.getMessageByProjectAndUser(params);
  }
}
