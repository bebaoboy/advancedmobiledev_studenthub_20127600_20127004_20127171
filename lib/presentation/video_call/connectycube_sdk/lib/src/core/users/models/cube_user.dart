import 'dart:collection';

import '../../models/cube_entity.dart';

class CubeUser extends CubeEntity {
  String? fullName;
  String? addressBookName;
  String? email;
  String? login;
  String? phone;
  String? website;
  DateTime? lastRequestAt;

  /// Use [externalUserId] instead
  @Deprecated('Use [externalUserId] instead')
  int? externalId;
  String? externalUserId;
  String? facebookId;
  String? twitterId;
  Set<String>? tags;
  String? password;
  String? oldPassword;
  String? customData;
  String? avatar;
  dynamic customDataClass;
  bool? isGuest;
  int? timeZone;

  CubeUser(
      {int? id,
      this.login,
      this.email,
      this.password,
      this.fullName,
      this.phone,
      this.website,
      this.externalId,
      this.facebookId,
      this.twitterId,
      this.tags,
      this.oldPassword,
      this.customData,
      this.avatar,
      this.customDataClass,
      this.isGuest,
      this.timeZone}) {
    this.id = id;
  }

  CubeUser.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    fullName = json['full_name'];
    addressBookName = json['address_book_name'];
    email = json['email'];
    login = json['login'];
    phone = json['phone'];
    website = json['website'];

    var lastRequestAtRaw = json['last_request_at'];
    if (lastRequestAtRaw != null) {
      lastRequestAt = DateTime.parse(lastRequestAtRaw);
    }

    externalId = json['external_user_id'];
    externalUserId = json['external_id'];
    facebookId = json['facebook_id'];
    twitterId = json['twitter_id'];

    var tagsRaw = json['user_tags'];
    String? tagsListRaw = json['tag_list'];
    if (tagsRaw != null) {
      tags = HashSet.from(tagsRaw.toString().split(','));
    } else if (tagsListRaw != null) {
      tags = HashSet.from(tagsListRaw.split(','));
    }

    password = json['password'];
    oldPassword = json['oldPassword'];
    customData = json['custom_data'];
    avatar = json['avatar'];
    isGuest = json['is_guest'];
    timeZone = json['timezone'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'full_name': fullName,
      'address_book_name': addressBookName,
      'email': email,
      'login': login,
      'phone': phone,
      'website': website,
      'last_request_at': lastRequestAt?.toIso8601String(),
      'external_user_id': externalId,
      'external_id': externalUserId,
      'facebook_id': facebookId,
      'twitter_id': twitterId,
      'password': password,
      'oldPassword': oldPassword,
      'custom_data': customData,
      'avatar': avatar,
      'guest': isGuest,
      'timezone': timeZone,
    };

    json['tag_list'] = tags?.join(",");

    json.addAll(super.toJson());

    return json;
  }

  @override
  toString() => toJson().toString();
}
