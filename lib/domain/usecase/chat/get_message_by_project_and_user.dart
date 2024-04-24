import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/repository/chat/chat_repository.dart';

class GetMessageByProjectAndUserParams {
  String projectId;
  String userId;

  GetMessageByProjectAndUserParams({this.projectId = "", this.userId = ""});
}

class GetMessageByProjectAndUsersUseCase
    extends UseCase<Future<List<WrapMessageList>>, GetMessageByProjectAndUserParams> {
  final ChatRepository _chatRepository;
  GetMessageByProjectAndUsersUseCase(this._chatRepository);

  @override
  Future<List<WrapMessageList>> call(
      {required GetMessageByProjectAndUserParams params}) {
    return _chatRepository.getMessageByProjectAndUser(params);
  }
}
