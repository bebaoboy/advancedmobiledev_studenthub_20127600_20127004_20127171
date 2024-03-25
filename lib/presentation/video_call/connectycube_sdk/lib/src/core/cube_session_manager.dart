import 'auth/models/cube_session.dart';

class CubeSessionManager {
  static final CubeSessionManager _instance = CubeSessionManager._internal();

  CubeSessionManager._internal();

  static CubeSessionManager get instance => _instance;

  CubeSession? _activeSession;

  @deprecated

  /// use setter [activeSession] instead
  void saveActiveSession(CubeSession session) {
    activeSession = session;
  }

  @deprecated

  /// use getter [activeSession] instead
  CubeSession? getActiveSession() {
    return activeSession;
  }

  CubeSession? get activeSession => _activeSession;

  set activeSession(CubeSession? session) => _activeSession = session;

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
    return _activeSession?.tokenExpirationDate;
  }

  void setTokenExpirationDate(DateTime tokenExpirationDate) {
    _activeSession?.tokenExpirationDate = tokenExpirationDate;
  }

  void deleteActiveSession() {
    _activeSession = null;
  }
}
