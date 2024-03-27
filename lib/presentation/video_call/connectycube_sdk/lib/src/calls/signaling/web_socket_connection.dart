// ignore_for_file: unused_field

import 'dart:async';
import 'dart:collection';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/status.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'web_socket_packets.dart';
import '../../../connectycube_core.dart';

class WebSocketConnection {
  static const int _timeOutInSec = 10;
  static int _instances = 0;
  int? _instance;
  final String _url;
  final String _protocol;

  late WebSocketChannel _channel;
  int? _sessionId;

  final RandomStringGenerator stringGenerator = RandomStringGenerator();
  Map<String, WsPacket> transactions = HashMap<String, WsPacket>();
  List<WsPacketListener> packetListeners = [];
  List<PacketCollector> collectors = [];

  WebSocketConnection(this._url, this._protocol) {
    _instance = _instances++;
  }

  void addPacketListener(WsPacketListener packetListener) {
    packetListeners.add(packetListener);
  }

  void connect() {
    logTime("connect to $_url, $_protocol");
    _channel =
        WebSocketChannel.connect(Uri.parse(_url), protocols: [_protocol]);

    _channel.stream.listen((message) {
      onParseMessage(message);
    });
  }

  authenticate(Completer<void> completer) {
    WsDataPacket packet = WsDataPacket();
    packet.messageType = Type.create;
    createCollectorAndSend(packet, Type.success, completer);
  }

  createCollectorAndSend(
      WsPacket packet, Type type, Completer<void> completer) {
    PacketCollector packetCollector = PacketCollector(type, completer);
    collectors.add(packetCollector);
    send(packet);
  }

  send<P extends WsPacket>(P packet) {
    applyTransactionData(packet);
    String rawMessage = encode(packet.toJson());
    logTime("SND(${_instance.toString()}): $rawMessage");
    _channel.sink.add(rawMessage);
  }

  void removePacketCollector(PacketCollector packetCollector) {
    collectors.remove(packetCollector);
  }

  void applyTransactionData(WsPacket packet) {
    if (_sessionId != null) {
      packet.sessionId = _sessionId;
    }

    String randomString = stringGenerator.getString();
    packet.transaction = randomString;
    transactions[randomString] = packet;
  }

  void onParseMessage(String message) {
    logTime("RCV(${_instance.toString()}): $message");

    WsPacket packet = parse(message);
    applySession(packet);
    WsPacket? reqPacket = transactions[packet.transaction];

    if (reqPacket == null) {
      if (packet.sessionId == null) {
//        notifyErrorListeners(packet);
        return;
      }
    }
    notifyListeners(packet);
  }

  applySession(WsPacket packet) {
    if (_sessionId == null && packet is WsDataPacket) {
      if (packet.getData() != null) {
        int? id = packet.getData().id;
        _sessionId = id;
      }
    }
  }

  notifyListeners(WsPacket packet) {
    for (var listener in packetListeners) {
      listener.onPacketReceived(packet);
    }
    processResponse(packet);
  }

  processResponse(WsPacket packet) {
    for (var collector in collectors) {
      collector.processPacket(packet);
    }
    collectors.removeWhere((packet) => packet.cancelled);
  }

  bool isActiveSession() {
    return _sessionId != null;
  }

  void closeSession() {
    WsDataPacket packet = WsDataPacket();
    packet.messageType = Type.destroy;
    Completer completer = Completer();
    createCollectorAndSend(packet, Type.success, completer);
    completer.future.whenComplete(() {
      _sessionId = null;
      _channel.sink.close(normalClosure);
    });
  }
}

class PacketCollector {
  Type? _type;
  late Completer _completer;

  bool cancelled = false;

  PacketCollector(Type type, Completer completer) {
    _type = type;
    _completer = completer;
  }

  void cancel() {
    // If the packet collector has already been cancelled, do nothing.
    if (!cancelled) {
      cancelled = true;
    }
  }

  void processPacket(WsPacket packet) {
    if (packet.messageType == _type || packet.messageType == Type.error) {
      cancel();
      _completer.complete(packet);
    }
  }
}

class RandomStringGenerator {
  //FixME RP as an option can be http://pub.dartlang.org/packages/uuid
  String getString() {
    return const Uuid().v4();
  }
}

abstract class WsPacketListener {
  void onPacketReceived(WsPacket packet);

  void onPacketError(WsPacket packet, String error);
}
