// ignore_for_file: prefer_final_fields

import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/usecase/noti/get_noti_usecase.dart';
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

  @observable
  List<NotificationObject> _NotificationObjects = [];
  List<NotificationObject> get NotificationObjects => _NotificationObjects;

  @action
  Future<List<NotificationObject>> getNoti({required String receiverId}) async {
    if (receiverId.trim().isEmpty) {
      return Future.value([]);
    }
    try {
      final future =
          _GetNotiUseCase.call(params: GetNotiParams(receiverId: receiverId))
              .then(
        (value) async {
          if (value.isNotEmpty) {
            print(value);
            _NotificationObjects = value;

            return _NotificationObjects;
          } else {
            print("Empty response");
            return Future.value([]);
          }
        },
      ).onError((error, stackTrace) async {
        return Future.value([]);
      });
    } catch (e) {
      print("Cannot get notification for this receiverId");
    }
    return Future.value([]);
  }

  @action
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
