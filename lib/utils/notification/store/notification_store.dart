// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/usecase/noti/get_noti_usecase.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_core.dart';
import 'package:boilerplate/utils/notification/notification.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notification_store.g.dart';

class NotificationStore = _NotificationStore with _$NotificationStore;

abstract class _NotificationStore with Store {
  _NotificationStore(this._GetNotiUseCase);

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  @observable
  String receiverId = '';

  @observable
  bool success = false;

  //usecase
  GetNotiUseCase _GetNotiUseCase;

  static ObservableFuture<void> emptyResponse = ObservableFuture.value(null);

  @observable
  ObservableFuture<void> getNotiFuture = emptyResponse;

  @computed
  bool get isLoading => getNotiFuture.status == FutureStatus.pending;

  ObservableList<NotificationObject> _notiList = ObservableList();
  List<NotificationObject> get notiList => _notiList;

  @action
  Future<List<NotificationObject>> getNoti(
      {required String receiverId,
      required List activeDates,
      bool force = false,
      required Function setStateCb}) async {
    // if (receiverId.trim().isEmpty) {
    //   return Future.value([]);
    // }
    this.activeDates = activeDates.length;
    try {
      var future =
          _GetNotiUseCase.call(params: GetNotiParams(receiverId: receiverId))
              .then(
        (value) async {
          if (value.isNotEmpty) {
            // print(value);
            _notiList = ObservableList.of(value);
            _notiList.sort(
              (a, b) => b.createdAt!.compareTo(a.createdAt!),
            );
            categorize(activeDates);
            setStateCb();

            return _notiList;
          } else {
            print("Empty response");
            var s = await SharedPreferences.getInstance();

            var l = s.getStringList("noti");
            if (l != null) {
              print("get noti from sharedpref");

              List<NotificationObject> res = l
                  .map(
                    (e) => NotificationObject.fromJson(json.decode(e)),
                  )
                  .toList();
              _notiList = ObservableList.of(res);
              _notiList.sort(
                (a, b) => b.createdAt!.compareTo(a.createdAt!),
              );
              categorize(activeDates);
              setStateCb();
              return res;
            }
            setStateCb();

            return Future.value([]);
          }
        },
      ).onError(
        (error, stackTrace) async {
          log(error.toString());
          log(stackTrace.toString());

          print("get noti from sharedpref");
          var s = await SharedPreferences.getInstance();

          var l = s.getStringList("noti");
          if (l != null) {
            List<NotificationObject> res = l
                .map(
                  (e) => NotificationObject.fromJson(json.decode(e)),
                )
                .toList();
            _notiList = ObservableList.of(res);
            _notiList.sort(
              (a, b) => b.createdAt!.compareTo(a.createdAt!),
            );
            categorize(activeDates);
            setStateCb();

            return res;
          }
          setStateCb();

          return Future.value(_notiList);
        },
      );
      getNotiFuture = ObservableFuture(future);

      categorize(activeDates);

      return _notiList;
    } catch (e) {
      log(e.toString());
      print("Cannot get notification for this receiverId");
    }
    setStateCb();
    categorize(activeDates);

    return Future.value([]);
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  @observable
  List<ObservableList<NotificationObject>>? viewOffers;
  @observable
  List<ObservableList<NotificationObject>>? texts;
  @observable
  List<ObservableList<NotificationObject>>? messages;
  @observable
  List<ObservableList<NotificationObject>>? joinInterviews;

  int activeDates = 14;

  categorize(List activeDates) {
    var userStore = getIt<UserStore>();

    this.activeDates = activeDates.length;
    viewOffers = List.generate(activeDates.length, (_) => ObservableList());
    joinInterviews = List.generate(activeDates.length, (_) => ObservableList());
    messages = List.generate(activeDates.length, (_) => ObservableList());
    texts = List.generate(activeDates.length, (_) => ObservableList());
    for (var element in notiList) {
      var type = element.type;
      var date = element.createdAt;
      if (date == null) continue;
      int diff = daysBetween(DateTime.now(), date);
      if (diff > activeDates.length/2 - 1) continue;
      if (diff < -(activeDates.length/2 - 1)) continue;
      // print(DateTime(date.year, date.month, date.day));
      // print(diff + (activeDates.length ~/ 2));

      switch (type) {
        case NotificationType.joinInterview:
          joinInterviews![diff + (activeDates.length ~/ 2)].add(element);

          break;
        case NotificationType.viewOffer:
        case NotificationType.hired:
          if (userStore.user!.type == UserType.student) {
            viewOffers![diff + (activeDates.length ~/ 2)].add(element);
          }

          break;
        case NotificationType.proposal:
          if (userStore.user!.type == UserType.company) {
            texts![diff + (activeDates.length ~/ 2)].add(element);
          }

          break;
        case NotificationType.message:
          messages![diff + (activeDates.length ~/ 2)].add(element);

          break;
      }
    }
    print("interview: ");
    for (var element in joinInterviews!) {
      print(element.length);
    }
    print("offer: ");
    for (var element in viewOffers!) {
      print(element.length);
    }
    print("text: ");
    for (var element in texts!) {
      print(element.length);
    }
    print("message: ");
    for (var element in messages!) {
      print(element.length);
    }
  }

  addNofitication(Map<String, dynamic> element) async {
    if (viewOffers == null ||
        joinInterviews == null ||
        texts == null ||
        messages == null) {
      categorize(List.filled(activeDates, 0));
    }
    var not = toNotificationObject(element["notification"]);
    _notiList.insert(0, not);
    var sharePref = await SharedPreferences.getInstance();
    log("last read saved ${DateTime.now().millisecondsSinceEpoch} ${DateTime.now()}");
    await sharePref.setInt(
        Preferences.lastRead, DateTime.now().millisecondsSinceEpoch);
    if (not.type == NotificationType.proposal) {
      NotificationHelper.createTextNotification(
          id: int.parse(not.id),
          title: "You have new proposal!",
          body:
              "From ${not.sender.name} (Project ${not.metadata!["projectId"]})");
    }
    if (not.type == NotificationType.viewOffer) {
      NotificationHelper.createTextNotification(
          id: int.parse(not.id),
          title: "You have been offered!",
          body:
              "From ${not.sender.name} (Project ${not.metadata!["projectId"]})");
    }
    if (not.type == NotificationType.hired) {
      NotificationHelper.createTextNotification(
          id: int.parse(not.id),
          title: "You have been hired!",
          body:
              "From ${not.sender.name} (Project ${not.metadata!["projectId"]})");
    }
    int diff = daysBetween(DateTime.now(), not.createdAt!);
    switch (not.type) {
      case NotificationType.joinInterview:
        joinInterviews![diff + (activeDates ~/ 2)].insert(0, not);

        break;
      case NotificationType.viewOffer:
      case NotificationType.hired:
        viewOffers![diff + (activeDates ~/ 2)].insert(0, not);

        break;
      case NotificationType.proposal:
        texts![diff + (activeDates ~/ 2)].insert(0, not);

        break;
      case NotificationType.message:
        messages![diff + (activeDates ~/ 2)].insert(0, not);

        break;
    }
    NavbarNotifier2.updateBadge(
        3, const NavbarBadge(showBadge: true, badgeText: "1"));

    Future.delayed(Duration.zero, () async {
      if (_notiList.isEmpty) return;
      var s = await SharedPreferences.getInstance();
      var l = s.getStringList("noti");
      if (l != null) {
        s.setStringList("noti", [_notiList.first.toJson(), ...l]);
      }
    });
  }

  NotificationObject toNotificationObject(element) {
    var e = <String, dynamic>{
      ...element,
      'id': element['id'].toString(),
      'title': element["title"].toString(),
      "content": element["content"].toString(),
      'messageContent': element["message"] != null
          ? element["message"]['content'].toString()
          : element["content"].toString(),
      'type': element['typeNotifyFlag'],
      'createdAt': DateTime.parse(element['createdAt']).toLocal(),
      'receiver': {
        "id": element['receiver']['id'].toString(),
        "fullname": element['receiver']['fullname'].toString(),
      },
      'sender': {
        "id": element['sender']['id'].toString(),
        "fullname": element['sender']['fullname'].toString(),
      },
      'metadata': (element["message"] != null &&
              element["message"]["interview"] != null)
          ? <String, dynamic>{
              ...element["message"]["interview"],
              "meetingRoom": element["message"]["interview"]["meetingRoom"]
            }
          : element["proposal"] != null
              ? <String, dynamic>{...element["proposal"]}
              : null,
    };
    return NotificationObject.fromJson(e);
  }

  @action
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
