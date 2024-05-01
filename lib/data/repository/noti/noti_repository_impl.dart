import 'dart:io';

import 'package:boilerplate/data/network/apis/noti/noti_api.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/noti/noti_repository.dart';
import 'package:boilerplate/domain/usecase/noti/get_noti_usecase.dart';

class NotiRepositoryImpl extends NotiRepository {
  final NotiApi _notiApi;

  NotiRepositoryImpl(this._notiApi);

  @override
  Future<List<NotificationObject>> getNoti(GetNotiParams params) async {
    try {
      return await _notiApi.getNoti(params).then(
        (value) {
          if (value.statusCode == HttpStatus.accepted ||
              value.statusCode == HttpStatus.ok) {
            List data = value.data["result"];
            List<NotificationObject> res = List.empty(growable: true);
            for (var element in data) {
              var e = <String, dynamic>{
                ...element,
                'id': element['id'].toString(),
                'content': element['content'].toString(),
                'type': element['typeNotifyFlag'],
                'createdAt':
                    DateTime.parse(element['createdAt']).millisecondsSinceEpoch,
                'receiver': {
                  "objectId": element['receiver']['id'].toString(),
                  "fullName": element['receiver']['fullName'].toString(),
                },
                'sender': {
                  "objectId": element['sender']['id'].toString(),
                  "fullName": element['sender']['fullname'].toString(),
                }
              };
              var acm = NotificationObject.fromJson(e);

              if (!res.contains(acm)) {
                res.add(acm);
              }
            }

            return res;
          } else {
            return [];
          }
        },
      );

      // ignore: invalid_return_type_for_catch_error
    } catch (e) {
      print(e.toString());
      // return _datasource.getFromDb();
      return [];
    }
  }
}
