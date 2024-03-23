import 'package:boilerplate/presentation/video_call/connectycube_flutter_call_kit/lib/connectycube_flutter_call_kit.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';

class CubeSessionManager {
  static final CubeSessionManager _instance = CubeSessionManager._internal();

  CubeSessionManager._internal();

  static CubeSessionManager get instance => _instance;

  CubeSession? _activeSession;

  @deprecated

  /// use setter [activeSession] instead
  void saveActiveSession(CubeSession session) {
    this.activeSession = session;
  }

  @deprecated

  /// use getter [activeSession] instead
  CubeSession? getActiveSession() {
    return activeSession;
  }

  CubeSession? get activeSession => _activeSession;

  set activeSession(CubeSession? session) => this._activeSession = session;

  bool isActiveSessionValid() {
    return !isSessionExpired(_activeSession);
  }

  bool isSessionExpired(CubeSession? cubeSession) {
    if (cubeSession == null) return true;

    DateTime? expirationDate = cubeSession.tokenExpirationDate;
    DateTime currentDate = DateTime.now();

    return expirationDate == null || expirationDate.isBefore(currentDate);
  }

  void updateActiveSession() {}

  String getToken() {
    return _activeSession?.token ?? "";
  }

  void setToken(String token) {
    _activeSession?.token = token;
  }

  DateTime? getTokenExpirationDate() {
    return _activeSession?.tokenExpirationDate ?? null;
  }

  void setTokenExpirationDate(DateTime tokenExpirationDate) {
    _activeSession?.tokenExpirationDate = tokenExpirationDate;
  }

  void deleteActiveSession() {
    _activeSession = null;
  }
}
