import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/usecase/noti/get_noti_usecase.dart';

abstract class NotiRepository {
  Future<List<NotificationObject>> getNoti(GetNotiParams params);
}
