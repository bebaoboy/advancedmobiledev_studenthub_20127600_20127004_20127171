import 'dart:convert';

import '../../../../connectycube_core.dart';

import '../../models/cube_custom_object.dart';
import '../models/custom_object_permissions_result.dart';
import '../models/paged_custom_object_result.dart';

class CreateCustomObjectQuery extends AutoManagedQuery<CubeCustomObject> {
  final CubeCustomObject _customObject;

  CreateCustomObjectQuery(this._customObject);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.POST);
  }

  @override
  setUrl(RestRequest request) {
    if (isEmpty(_customObject.className)) {
      throw IllegalArgumentException("'class_name' can not by null or empty");
    }

    request.setUrl(buildQueryUrl([DATA_ENDPOINT, _customObject.className]));
  }

  @override
  setBody(RestRequest request) {
    Map<String, dynamic> parameters = request.params;
    parameters.addAll(_customObject.toJson());
  }

  @override
  CubeCustomObject processResult(String response) {
    return CubeCustomObject.fromJson(json.decode(response));
  }
}

class GetCustomObjectQuery extends AutoManagedQuery<PagedCustomObjectResult> {
  List<String>? _ids;
  final String _className;
  Map<String, dynamic>? _params;

  GetCustomObjectQuery.byIds(this._className, this._ids);

  GetCustomObjectQuery.byClassName(this._className, [this._params]);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    if (isEmpty(_className)) {
      throw IllegalArgumentException("'_className' can not by null or empty");
    }

    if (_ids?.isEmpty ?? true) {
      request.setUrl(buildQueryUrl([DATA_ENDPOINT, _className]));
    } else {
      request
          .setUrl(buildQueryUrl([DATA_ENDPOINT, _className, _ids!.join(',')]));
    }
  }

  @override
  void setParams(RestRequest request) {
    if (_ids?.isEmpty ?? true) {
      if (_params != null && _params!.isNotEmpty) {
        Map<String, dynamic> parameters = request.params;

        for (String key in _params!.keys) {
          putValue(parameters, key, _params![key]);
        }
      }
    }
  }

  @override
  PagedCustomObjectResult processResult(String response) {
    return PagedCustomObjectResult(response);
  }
}

class GetCustomObjectByIdQuery extends AutoManagedQuery<CubeCustomObject?> {
  final String _id;
  final String _className;

  GetCustomObjectByIdQuery(this._className, this._id);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    if (isEmpty(_className) || isEmpty(_id)) {
      throw IllegalArgumentException(
          "'_className' and '_id' can not by null or empty");
    }

    request.setUrl(buildQueryUrl([DATA_ENDPOINT, _className, _id]));
  }

  @override
  CubeCustomObject? processResult(String response) {
    var resp = PagedCustomObjectResult(response);
    return resp.items.isEmpty ? null : resp.items.first;
  }
}

class GetCustomObjectPermissionsQuery
    extends AutoManagedQuery<CustomObjectPermissionsResult> {
  final String _id;
  final String _className;

  GetCustomObjectPermissionsQuery(this._className, this._id);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    if (isEmpty(_id) || isEmpty(_className)) {
      throw IllegalArgumentException(
          "'_id' and '_className' can not by null or empty");
    }

    request.setUrl(buildQueryUrl([DATA_ENDPOINT, _className, _id]));
  }

  @override
  void setParams(RestRequest request) {
    putValue(request.params, 'permissions', 1);
  }

  @override
  CustomObjectPermissionsResult processResult(String response) {
    return CustomObjectPermissionsResult.fromJson(json.decode(response));
  }
}

class UpdateCustomObjectQuery extends AutoManagedQuery<CubeCustomObject> {
  final String _id;
  final String _className;
  final Map<String, dynamic> _params;

  UpdateCustomObjectQuery(this._className, this._id, this._params);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.PUT);
  }

  @override
  setUrl(RestRequest request) {
    if (isEmpty(_id) || isEmpty(_className)) {
      throw IllegalArgumentException(
          "'_id' and '_className' can not by null or empty");
    }

    request.setUrl(buildQueryUrl([DATA_ENDPOINT, _className, _id]));
  }

  @override
  void setBody(RestRequest request) {
    if (_params.isEmpty) {
      throw IllegalArgumentException(
          "'_params' is null or empty, so nothing to update");
    }

    request.params.addAll(_params);
  }

  @override
  CubeCustomObject processResult(String response) {
    return CubeCustomObject.fromJson(json.decode(response));
  }
}

class UpdateCustomObjectByCriteriaQuery
    extends AutoManagedQuery<PagedCustomObjectResult> {
  final String _className;
  final Map<String, dynamic>? _params;

  UpdateCustomObjectByCriteriaQuery(this._className, this._params);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.PUT);
  }

  @override
  setUrl(RestRequest request) {
    if (isEmpty(_className)) {
      throw IllegalArgumentException("'_className' can not by null or empty");
    }

    request.setUrl(buildQueryUrl([DATA_ENDPOINT, _className, BY_CRITERIA]));
  }

  @override
  void setBody(RestRequest request) {
    if (_params?.isEmpty ?? true) {
      throw IllegalArgumentException(
          "'_params' is null or empty, so nothing to update");
    }

    request.params.addAll(_params!);
  }

  @override
  PagedCustomObjectResult processResult(String response) {
    return PagedCustomObjectResult(response);
  }
}

class DeleteCustomObjectByIdQuery extends AutoManagedQuery<void> {
  final String _id;
  final String _className;

  DeleteCustomObjectByIdQuery(this._className, this._id);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.DELETE);
  }

  @override
  setUrl(RestRequest request) {
    if (isEmpty(_id) || isEmpty(_className)) {
      throw IllegalArgumentException(
          "'_id' and '_className' can not by null or empty");
    }

    request.setUrl(buildQueryUrl([DATA_ENDPOINT, _className, _id]));
  }

  @override
  void processResult(String response) {}
}

class DeleteCustomObjectsByIdsQuery
    extends AutoManagedQuery<DeleteItemsResult> {
  final List<String> _ids;
  final String _className;

  DeleteCustomObjectsByIdsQuery(this._className, this._ids);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.DELETE);
  }

  @override
  setUrl(RestRequest request) {
    if (_ids.isEmpty || isEmpty(_className)) {
      throw IllegalArgumentException(
          "'_ids' and '_className' can not by null or empty");
    }

    request.setUrl(buildQueryUrl([DATA_ENDPOINT, _className, _ids.join(',')]));
  }

  @override
  DeleteItemsResult processResult(String response) {
    return DeleteItemsResult.fromJson(json.decode(response));
  }
}

class DeleteCustomObjectsByCriteriaQuery extends AutoManagedQuery<int> {
  final String _className;
  final Map<String, dynamic>? _params;

  DeleteCustomObjectsByCriteriaQuery(this._className, this._params);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.DELETE);
  }

  @override
  setUrl(RestRequest request) {
    if (isEmpty(_className)) {
      throw IllegalArgumentException("'_className' can not by null or empty");
    }

    request.setUrl(buildQueryUrl([DATA_ENDPOINT, _className, BY_CRITERIA]));
  }

  @override
  void setParams(RestRequest request) {
    if (_params?.isEmpty ?? true) {
      throw IllegalArgumentException(
          "'_params' can not by null or empty for this request");
    }

    _params!.forEach((key, value) {
      putValue(request.params, key, value);
    });
  }

  @override
  int processResult(String response) {
    Map<String, dynamic> result = json.decode(response);
    return result['total_deleted'];
  }
}
