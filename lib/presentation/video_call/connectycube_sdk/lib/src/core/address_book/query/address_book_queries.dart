import 'dart:convert';

import '../models/addres_book_result.dart';
import '../models/cube_contact.dart';
import '../../rest/query/query.dart';
import '../../rest/request/rest_request.dart';
import '../../rest/response/paged_result.dart';
import '../../utils/consts.dart';
import '../../users/models/cube_user.dart';

class UploadAddressBookQuery extends AutoManagedQuery<AddressBookResult> {
  List<CubeContact> _contacts;
  bool? _force;
  String? _udid;

  UploadAddressBookQuery(this._contacts, [this._force, this._udid]);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.POST);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([ADDRESS_BOOK_ENDPOINT]));
  }

  @override
  setBody(RestRequest request) {
    Map<String, dynamic> parameters = request.params;

    parameters[CONTACTS] = _contacts;
    parameters[FORCE] = _force! ? 1 : 0;
    parameters[UDID] = _udid;
  }

  @override
  AddressBookResult processResult(String response) {
    return AddressBookResult.fromJson(jsonDecode(response));
  }
}

class GetAddressBookQuery extends AutoManagedQuery<List<CubeContact>> {
  String? _udid;

  GetAddressBookQuery([this._udid]);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([ADDRESS_BOOK_ENDPOINT]));
  }

  @override
  setParams(RestRequest request) {
    Map<String, dynamic> parameters = request.params;

    putValue(parameters, UDID, _udid);
  }

  @override
  List<CubeContact> processResult(String response) {
    List result = jsonDecode(response);
    return result.map((element) => CubeContact.fromJson(element)).toList();
  }
}

class GetRegisteredUsers extends AutoManagedQuery<List<CubeUser>?> {
  String? _udid;
  bool _compact;

  GetRegisteredUsers(this._compact, [this._udid]);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(
        buildQueryUrl([ADDRESS_BOOK_ENDPOINT, REGISTERED_USERS_ENDPOINT]));
  }

  @override
  setParams(RestRequest request) {
    Map<String?, dynamic> parameters = request.params;

    putValue(parameters, UDID, _udid);
    putValue(parameters, COMPACT, _compact ? 1 : 0);
  }

  @override
  List<CubeUser>? processResult(String response) {
    return PagedResult<CubeUser>(
        response, (element) => CubeUser.fromJson(element['user'])).items;
  }
}
