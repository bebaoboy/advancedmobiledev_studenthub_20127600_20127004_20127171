import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/cube_session.dart';
import '../../cube_session_manager.dart';
import '../../models/cube_settings.dart';
import '../../rest/query/query.dart';
import '../../rest/request/rest_request.dart';
import '../../rest/response/rest_response.dart';
import '../../users/models/cube_user.dart';
import '../../utils/consts.dart';

abstract class BaseAuthQuery<T> extends AutoManagedQuery<T> {
  CubeUser? _user;

  /// Data to login via social providers
  String? _provider;
  String? _accessToken;
  String? _accessTokenSecret;
  String? _projectId;

  BaseAuthQuery([this._user]);

  /// This constructor uses for creating query for sign in user via social networks or other providers.
  /// Different providers contains different count of parameters for authorisation and we can set they
  /// to parameter `args`.
  ///
  /// [_provider] Name of provider. All possible values can be found [CubeProvider]
  /// [args]     Parameters needed to authorisation.
  ///   [CubeProvider.FACEBOOK]
  ///                      args[0] - Access Token;
  ///   [CubeProvider.TWITTER]
  ///                      args[0] - Access Token;
  ///                      args[1] - Access Token Secret;
  ///   [CubeProvider.FIREBASE_PHONE]
  ///                      args[0] - ID of project in Firebase Console;
  ///                      args[1] - Access Token;
  ///   [CubeProvider.FIREBASE_EMAIL]
  ///                      args[0] - ID of project in Firebase Console;
  ///                      args[1] - Access Token;
  ///
  ///   Please describe parameters for new Provider here.
  BaseAuthQuery.usingSocial(this._provider, List<String?> args) {
    if (_provider == CubeProvider.FACEBOOK ||
        _provider == CubeProvider.TWITTER) {
      this._accessToken = args[0];
      this._accessTokenSecret = args[1];
    } else if (_provider == CubeProvider.FIREBASE_PHONE ||
        _provider == CubeProvider.FIREBASE_EMAIL) {
      this._projectId = args[0];
      this._accessToken = args[1];
    }
  }

  @override
  setMethod(RestRequest request) {
    request.method = RequestMethod.POST;
  }

  @override
  setParams(RestRequest request) {
    Map<String, dynamic> parameters = request.params;

    if (_provider != null) {
      putValue(parameters, PROVIDER, _provider);

      if (_provider == CubeProvider.FIREBASE_PHONE) {
        putValue(parameters, FIREBASE_PHONE_TOKEN, _accessToken);
        putValue(parameters, FIREBASE_PHONE_PROJECT_ID, _projectId);
      } else if (_provider == CubeProvider.FIREBASE_EMAIL) {
        putValue(parameters, FIREBASE_EMAIL_TOKEN, _accessToken);
        putValue(parameters, FIREBASE_EMAIL_PROJECT_ID, _projectId);
      } else {
        putValue(parameters, KEYS_TOKEN, _accessToken);

        if (_provider == CubeProvider.TWITTER) {
          putValue(parameters, KEYS_SECRET, _accessTokenSecret);
        }
      }
    } else if (_user != null) {
      if (_user!.isGuest != null && _user!.isGuest!) {
        putValue(parameters, USER_GUEST, '1');
        putValue(parameters, USER_FULL_NAME, _user!.fullName);
      } else {
        putValue(parameters, USER_EMAIL, _user!.email);
        putValue(parameters, USER_LOGIN, _user!.login);
        putValue(parameters, USER_PASSWORD, _user!.password);
      }
    }
  }

  @override
  setBody(RestRequest request) {
    super.setBody(request);

    Map<String, dynamic> parameters = request.params;

    if (_provider != null) {
      if (_provider == CubeProvider.FIREBASE_PHONE ||
          _provider == CubeProvider.FIREBASE_EMAIL) {
        _convertFirebaseParamsToJson(parameters, _provider!);
      } else {
        _convertProviderKeysToJson(parameters);
      }
    } else if (_user != null) {
      _setupUserForBody(parameters, _user!);
    }

    request.setBody(jsonEncode(parameters));
  }

  _convertFirebaseParamsToJson(
      Map<String, dynamic> parameters, String firebaseProviderName) {
    Map firebaseParamsJson = Map();

    firebaseParamsJson['access_token'] = _accessToken;
    parameters.remove(firebaseProviderName == CubeProvider.FIREBASE_PHONE
        ? FIREBASE_PHONE_TOKEN
        : FIREBASE_EMAIL_TOKEN);

    firebaseParamsJson['project_id'] = _projectId;
    parameters.remove(firebaseProviderName == CubeProvider.FIREBASE_PHONE
        ? FIREBASE_PHONE_PROJECT_ID
        : FIREBASE_EMAIL_PROJECT_ID);

    putValue(parameters, firebaseProviderName, firebaseParamsJson);
  }

  _convertProviderKeysToJson(Map<String, dynamic> parameters) {
    Map keysJson = Map();

    keysJson['token'] = _accessToken;
    parameters.remove(KEYS_TOKEN);

    if (_provider == CubeProvider.TWITTER) {
      keysJson['secret'] = _accessTokenSecret;
      parameters.remove(KEYS_SECRET);
    }

    putValue(parameters, "keys", keysJson);
  }

  _setupUserForBody(Map<String, dynamic> parameters, CubeUser user);
}

class CreateSessionQuery extends BaseAuthQuery<CubeSession> {
  late CubeSession _resultSession;

  CreateSessionQuery([CubeUser? user]) : super(user);

  CreateSessionQuery.usingSocial(String provider, List<String?> args)
      : super.usingSocial(provider, args);

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([AUTH_ENDPOINT]));
  }

  @override
  setParams(RestRequest request) {
    super.setParams(request);

    Map<String, dynamic> parameters = request.params;

    String? appId = CubeSettings.instance.applicationId;
    String? authKey = CubeSettings.instance.authorizationKey;
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int nonce = Random.secure().nextInt(1 << 31);

    putValue(parameters, APP_ID, appId);
    putValue(parameters, AUTH_KEY, authKey);
    putValue(parameters, NONCE, nonce.toString());
    putValue(parameters, TIMESTAMP, timestamp.toString());

    _signRequest(request);
  }

  _signRequest(RestRequest request) {
    Map<String, dynamic> parameters = request.params;

    StringBuffer keyValueSortedString = StringBuffer();
    Map<String, String> sortedParams = SplayTreeMap.from(parameters);

    for (String key in sortedParams.keys) {
      keyValueSortedString.write("$key=${sortedParams[key]}&");
    }

    String signString = keyValueSortedString.toString();
    signString = signString.substring(0, signString.length - 1);

    String key = CubeSettings.instance.authorizationSecret!;

    List<int> messageBytes = utf8.encode(signString);
    List<int> keyBytes = utf8.encode(key);

    Hmac hmac = Hmac(sha1, keyBytes);
    Digest digest = hmac.convert(messageBytes);

    String signature = digest.toString();

    putValue(parameters, SIGNATURE, signature);
  }

  @override
  CubeSession processResult(String response) => _resultSession;

  @override
  handleResponse(RestResponse response) {
    _resultSession = _processSessionFromJson(response.getBody());
    _resultSession.tokenExpirationDate =
        getTokenExpirationDateFromResponse(response);
    _updateActiveSession(_resultSession);
  }

  @override
  void _setupUserForBody(Map<String, dynamic> parameters, CubeUser user) {
    Map userToBody = Map();

    if (user.isGuest != null && user.isGuest!) {
      userToBody['guest'] = '1';
      parameters.remove(USER_GUEST);

      if (user.fullName != null) {
        userToBody['full_name'] = user.fullName;
        parameters.remove(USER_FULL_NAME);
      }

      putValue(parameters, "user", userToBody);

      return;
    }

    if (user.login != null) {
      userToBody['login'] = user.login;
      parameters.remove(USER_LOGIN);
    }

    if (user.email != null) {
      userToBody['email'] = user.email;
      parameters.remove(USER_EMAIL);
    }

    userToBody['password'] = user.password;
    parameters.remove(USER_PASSWORD);

    putValue(parameters, "user", userToBody);
  }

  CubeSession _processSessionFromJson(String jsonString) {
    Map<String, dynamic> res = json.decode(jsonString);
    return CubeSession.fromJson(res['session']);
  }

  _updateActiveSession(CubeSession? session) {
    CubeSessionManager.instance.activeSession = session;
  }

  @override
  bool isSessionRequired() {
    return false;
  }

  @override
  bool isUserRequired() {
    return false;
  }
}

class SignInQuery extends BaseAuthQuery<CubeUser> {
  SignInQuery(CubeUser user) : super(user);

  SignInQuery.usingSocial(String provider, List<String?> args)
      : super.usingSocial(provider, args);

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([SIGNIN_ENDPOINT]));
  }

  @override
  CubeUser processResult(String response) {
    Map<String, dynamic> res = json.decode(response);

    CubeUser resultUser = CubeUser.fromJson(res['user']);
    CubeSessionManager.instance.activeSession!.user = resultUser;

    return resultUser;
  }

  @override
  void _setupUserForBody(Map<String?, dynamic> parameters, CubeUser user) {
    if (user.login != null) {
      putValue(parameters, "login", user.login);
      parameters.remove(USER_LOGIN);
    }

    if (user.email != null) {
      putValue(parameters, "email", user.email);
      parameters.remove(USER_EMAIL);
    }

    putValue(parameters, "password", user.password);
    parameters.remove(USER_PASSWORD);
  }

  @override
  bool isUserRequired() {
    return false;
  }
}

class SignOutQuery extends AutoManagedQuery<void> {
  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.DELETE);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([SIGNIN_ENDPOINT]));
  }

  @override
  handleResponse(RestResponse response) {
    CubeSessionManager.instance.activeSession!.user = null;
    super.handleResponse(response);
  }

  @override
  void processResult(String responseBody) {}
}
