import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part "card_state_store.g.dart";

class CardStateStore = _CardStateStore with _$CardStateStore;

abstract class _CardStateStore with Store {
  @observable
  String actionName = 'none';

  @observable
  Color? color;

  @observable
  double opacity = 0;

  @observable
  int index = 0;

  @action
  changeStateToHire(String action) {
    if (action == actionName) return;
    actionName = HireStatus.offer.title;
    color = Colors.green;
  }

  @action
  changeStateToReject(String action) {
    if (action == actionName) return;
    actionName = HireStatus.notHired.title;
    color = Colors.red;
  }

  @action
  changeOpacity(double value) {
    opacity = value;
  }

  @action
  reset() {
    opacity = 0;
    actionName = '';
    color = null;
    index = 0;
  }
}
