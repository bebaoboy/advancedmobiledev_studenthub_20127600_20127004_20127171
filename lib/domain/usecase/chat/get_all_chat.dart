import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/repository/chat/chat_repository.dart';
import 'package:boilerplate/domain/usecase/chat/get_message_by_project_and_user.dart';

class GetAllChatsUseCase
    extends UseCase<Future<List<WrapMessageList>>, GetMessageByProjectAndUserParams> {
  final ChatRepository _chatRepository;
  GetAllChatsUseCase(this._chatRepository);

  @override
  Future<List<WrapMessageList>> call(
      {required GetMessageByProjectAndUserParams params}) {
    return _chatRepository.getAllChat(params);
  }
}
