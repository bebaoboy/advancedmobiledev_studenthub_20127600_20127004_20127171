import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
part 'deeplink_store.g.dart';

class DeeplinkStore = _DeeplinkStore with _$DeeplinkStore;

abstract class _DeeplinkStore with Store {
  //Event Channel creation
  static const messageStream =
      EventChannel('https.advmobiledev-studenthub-clc20.web.app/viewMessage');
  static const proposalStream =
      EventChannel('https.advmobiledev-studenthub-clc20.web.app/viewProposal');
  static const previewStream = EventChannel(
      'https.advmobiledev-studenthub-clc20.web.app/previewMeeting');

  //Method channel creation
  static const platform =
      MethodChannel('https.advmobiledev-studenthub-clc20.web.app/channel');

  StreamController<String> _stateController = StreamController();

  Stream<String> get state => _stateController.stream;

  Sink<String> get stateSink => _stateController.sink;

  //Adding the listener into contructor
  _DeeplinkStore() {
    //Checking application start by deep link
    startUri().then(_onRedirected);
    //Checking broadcast stream, if deep link was clicked in opened appication
    messageStream.receiveBroadcastStream().listen((d) => _onRedirected(d));
  }

  _onRedirected(String? uri) {
    if (uri != null) {
      stateSink.add(uri);
    }
  }

  void dispose() {
    _stateController.close();
  }

  Future<String?> startUri() async {
    try {
      return platform.invokeMethod("initiateLink");
    } on PlatformException catch (e) {
      return "Failed to Invoke: '${e.message}'.";
    }
  }
}
