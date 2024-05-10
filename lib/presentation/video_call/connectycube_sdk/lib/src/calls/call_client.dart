import 'call_session.dart';

abstract class CallClient<S extends P2PCallSession> {
  SessionStateCallback<S>? onReceiveNewSession;
  SessionStateCallback<S>? onSessionClosed;

  void init();
  S createCallSession(int callType, Set<int> opponentsIds);
  void destroy();
}

typedef SessionStateCallback<T> = void Function(T session);
