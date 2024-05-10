// ignore_for_file: camel_case_types

import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/noti/noti_repository.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';

class GetNotiParams {
  String receiverId;

  GetNotiParams({
    required this.receiverId,
  });
}

class GetNotiUseCase
    implements UseCase<List<NotificationObject>, GetNotiParams> {
  final NotiRepository _notiRepository;

  GetNotiUseCase(this._notiRepository);

  @override
  Future<List<NotificationObject>> call({required GetNotiParams params}) async {
    return _notiRepository.getNoti(params);
  }
}
