import 'dart:io';

import 'package:boilerplate/data/network/apis/noti/noti_api.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/noti/noti_repository.dart';
import 'package:boilerplate/domain/usecase/noti/get_noti_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotiRepositoryImpl extends NotiRepository {
  final NotiApi _notiApi;

  NotiRepositoryImpl(this._notiApi);

  @override
  Future<List<NotificationObject>> getNoti(
    GetNotiParams params,
  ) async {
    try {
      var s = await SharedPreferences.getInstance();
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
                'title': element["title"].toString(),
                "content": element["content"].toString(),
                'messageContent': element["message"] != null ? element["message"]['content'].toString() : element["content"].toString(),
                'type': element['typeNotifyFlag'],
                'createdAt': DateTime.parse(element['createdAt']).toLocal(),
                'receiver': {
                  "id": element['receiver']['id'].toString(),
                  "fullname": element['receiver']['fullName'].toString(),
                },
                'sender': {
                  "id": element['sender']['id'].toString(),
                  "fullname": element['sender']['fullname'].toString(),
                },
                'metadata': (element["message"] != null && element["message"]["interview"] != null)
                    ? <String, dynamic>{
                        ...element["message"]["interview"],
                        "meetingRoom": element["message"]["interview"]["meetingRoom"]
                      }
                    : element["proposal"] != null
                        ? <String, dynamic>{...element["proposal"]}
                        : null,
              };
              /*
               "proposal": {
            "id": 414,
            "createdAt": "2024-05-06T05:01:15.391Z",
            "updatedAt": "2024-05-06T05:01:15.391Z",
            "deletedAt": null,
            "projectId": 238,
            "studentId": 90,
            "coverLetter": "string",
            "statusFlag": 0,
            "disableFlag": 0
        } */
              var acm = NotificationObject.fromJson(e);

              // if (!res.contains(acm)) {
              res.add(acm);
              // }
            }

            s.setStringList(
                "noti",
                res
                    .map(
                      (e) => e.toJson(),
                    )
                    .toList());

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
