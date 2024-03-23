import '../../../connectycube_core.dart';

String getPublicUrlForUid(String? uid) {
  return "${CubeSettings.instance.apiEndpoint}/blobs/$uid";
}

String? getPrivateUrlForUid(String? uid) {
  CubeSession? currentSession = CubeSessionManager.instance.activeSession;
  if (!CubeSessionManager.instance.isSessionExpired(currentSession)) {
    return "${CubeSettings.instance.apiEndpoint}/blobs/$uid?token=${currentSession!.token}";
  } else {
    return null;
  }
}
