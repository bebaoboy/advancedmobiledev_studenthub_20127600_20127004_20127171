// ignore_for_file: prefer_final_fields

import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/usecase/noti/get_noti_usecase.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:mobx/mobx.dart';

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
      {required String receiverId, required List activeDates}) async {
    // if (receiverId.trim().isEmpty) {
    //   return Future.value([]);
    // }
    this.activeDates = activeDates.length;
    try {
      return await _GetNotiUseCase.call(
              params: GetNotiParams(receiverId: receiverId))
          .then(
        (value) async {
          if (value.isNotEmpty) {
            // print(value);
            _notiList = ObservableList.of(value);
            _notiList.sort(
              (a, b) => b.createdAt!.compareTo(a.createdAt!),
            );
            categorize(activeDates);
            return _notiList;
          } else {
            print("Empty response");
            categorize(activeDates);

            return Future.value([]);
          }
        },
      );
    } catch (e) {
      print("Cannot get notification for this receiverId");
    }
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

  int activeDates = 0;

  categorize(List activeDates) {
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
      if (diff > 6) continue;
      if (diff < -7) continue;
      // print(DateTime(date.year, date.month, date.day));
      // print(diff + (activeDates.length ~/ 2));

      switch (type) {
        case NotificationType.joinInterview:
          joinInterviews![diff + (activeDates.length ~/ 2)].add(element);

          break;
        case NotificationType.viewOffer:
          viewOffers![diff + (activeDates.length ~/ 2)].add(element);

          break;
        case NotificationType.text:
          texts![diff + (activeDates.length ~/ 2)].add(element);

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

  addNofitication(Map<String, dynamic> element) {
    var not = toNotificationObject(element["notification"]);
    _notiList.insert(0, not);
    int diff = daysBetween(DateTime.now(), not.createdAt!);
    switch (not.type) {
      case NotificationType.joinInterview:
        joinInterviews![diff + (activeDates ~/ 2)].insert(0, not);

        break;
      case NotificationType.viewOffer:
        viewOffers![diff + (activeDates ~/ 2)].insert(0, not);

        break;
      case NotificationType.text:
        texts![diff + (activeDates ~/ 2)].insert(0, not);

        break;
      case NotificationType.message:
        messages![diff + (activeDates ~/ 2)].insert(0, not);

        break;
    }
    NavbarNotifier2.updateBadge(3, const NavbarBadge(showBadge: true, badgeText: "1"));
  }

  NotificationObject toNotificationObject(element) {
    var e = <String, dynamic>{
      ...element,
      'id': element['id'].toString(),
      'title': element["title"].toString(),
      "content": element["content"].toString(),
      'messageContent': element["message"]['content'].toString(),
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
      'metadata': element["interview"] != null
          ? <String, dynamic>{
              ...element["interview"],
              "meetingRoom": element["meetingRoom"]
            }
          : null
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
