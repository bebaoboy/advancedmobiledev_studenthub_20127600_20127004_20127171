import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/chat/chat_repository.dart';
import 'package:dio/dio.dart';

class PostMessageParams {
  String content;
  String receiverId;
  String senderId;
  String projectId;
  int messageFlag = 0;

  PostMessageParams({required this.projectId, required this.content, required this.receiverId, required this.senderId,});
}

class PostMessagesUseCase
    extends UseCase<Response, PostMessageParams> {
  final ChatRepository _chatRepository;
  PostMessagesUseCase(this._chatRepository);

  @override
  Future<Response> call({required PostMessageParams params}) {
    return _chatRepository.postMessage(params);
  }
}
