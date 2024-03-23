import '../../../connectycube_core.dart';

class CubeSubscription extends CubeEntity {
  String? subscriptionId;
  int? userId;
  String? bundleIdentifier;
  String? clientIdentificationSequence;
  int? notificationChannelId;
  String? udid;
  int? platformId;
  String? environment;
  CubeNotificationChannel? cubeNotificationChannel;

  /// Use [cubeNotificationChannel.channelName] instead
  @deprecated
  String? get notificationChannel => cubeNotificationChannel?.channelName;

  /// Use `cubeNotificationChannel = CubeNotificationChannel(channelName)` instead
  @deprecated
  set notificationChannel(String? channelName) =>
      cubeNotificationChannel = CubeNotificationChannel(channelName);
  PushToken? token;
  CubeDeviceModel? device;

  CubeSubscription.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    subscriptionId = json['_id'];
    userId = json['user_id'];
    bundleIdentifier = json['bundle_identifier'];
    clientIdentificationSequence = json['client_identification_sequence'];
    notificationChannelId = json['notification_channel_id'];
    udid = json['udid'];
    platformId = json['platform_id'];
    environment = json['environment'];

    cubeNotificationChannel =
        CubeNotificationChannel.fromJson(json['notification_channel']);
    device = CubeDeviceModel.fromJson(json['device']);
    device?.bundleIdentifier = bundleIdentifier;
    device?.clientIdentificationSequence = clientIdentificationSequence;
  }

  Map<String, dynamic> toJson() => {
        'notification_channel': cubeNotificationChannel?.channelName,
        'push_token': token,
        'device': device
      };

  @override
  toString() {
    Map<String, dynamic> json = super.toJson();
    json['_id'] = subscriptionId;
    json['user_id'] = userId;
    json['bundle_identifier'] = bundleIdentifier;
    json['client_identification_sequence'] = clientIdentificationSequence;
    json['notification_channel_id'] = notificationChannelId;
    json['udid'] = udid;
    json['platform_id'] = platformId;
    json['environment'] = environment;
    json['notification_channel'] = cubeNotificationChannel;
    json['device'] = device;

    return json.toString();
  }
}

class PushToken {
  String? environment;
  String? bundleIdentifier;
  String? clientIdentificationSequence;

  PushToken(this.environment, this.clientIdentificationSequence,
      [this.bundleIdentifier]);

  PushToken.fromJson(Map<String, dynamic> json) {
    environment = json['environment'];
    bundleIdentifier = json['bundle_identifier'];
    clientIdentificationSequence = json['client_identification_sequence'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'environment': environment,
      'client_identification_sequence': clientIdentificationSequence
    };

    if (!isEmpty(bundleIdentifier)) {
      result['bundle_identifier'] = bundleIdentifier;
    }

    return result;
  }

  @override
  toString() => toJson().toString();
}

class CubeDeviceModel {
  String? udid;
  CubePlatformModel? cubePlatform;

  /// Use [cubePlatform.name] instead
  @deprecated
  String? get platform => cubePlatform?.name;

  /// Use `cubePlatform = CubePlatformModel(platformName)` instead
  @deprecated
  set platform(String? name) => cubePlatform = CubePlatformModel(name);

  /// Use [CubeSubscription.bundleIdentifier] instead
  @deprecated
  String? bundleIdentifier;

  /// Use [CubeSubscription.clientIdentificationSequence] instead
  @deprecated
  String? clientIdentificationSequence;

  CubeDeviceModel(this.udid, String? platformName) {
    cubePlatform = CubePlatformModel(platformName);
  }

  CubeDeviceModel.fromJson(Map<String, dynamic> json) {
    udid = json['udid'];
    cubePlatform = CubePlatformModel.fromJson(json['platform']);
    bundleIdentifier = json['bundle_identifier'];
    clientIdentificationSequence = json['client_identification_sequence'];
  }

  Map<String, dynamic> toJson() =>
      {'udid': udid, 'platform': cubePlatform?.name};

  @override
  toString() => toJson().toString();
}

class CubePlatformModel {
  String? name;

  CubePlatformModel(this.name);

  CubePlatformModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() => {'name': name};

  @override
  toString() => toJson().toString();
}

class CubeNotificationChannel {
  String? channelName;

  CubeNotificationChannel(this.channelName);

  CubeNotificationChannel.fromJson(Map<String, dynamic> json) {
    channelName = json['name'];
  }

  Map<String, dynamic> toJson() => {'name': channelName};

  @override
  toString() => toJson().toString();
}
