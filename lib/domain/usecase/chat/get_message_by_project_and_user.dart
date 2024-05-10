import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/chat/chat_repository.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';

class GetMessageByProjectAndUserParams {
  String projectId;
  String userId;

  GetMessageByProjectAndUserParams({this.projectId = "", this.userId = ""});
}

class GetMessageByProjectAndUsersUseCase
    extends UseCase<Future<List<AbstractChatMessage>>, GetMessageByProjectAndUserParams> {
  final ChatRepository _chatRepository;
  GetMessageByProjectAndUsersUseCase(this._chatRepository);

  @override
  Future<List<AbstractChatMessage>> call(
      {required GetMessageByProjectAndUserParams params}) {
    return _chatRepository.getMessageByProjectAndUser(params);
  }
}
