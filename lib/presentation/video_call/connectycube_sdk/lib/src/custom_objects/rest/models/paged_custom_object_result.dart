import 'dart:convert';

import '../../../../connectycube_core.dart';

import '../../models/cube_custom_object.dart';

class PagedCustomObjectResult extends PagedResult<CubeCustomObject> {
  String? className;

  PagedCustomObjectResult(String rawResponse)
      : super(rawResponse, (element) => CubeCustomObject.fromJson(element)) {
    Map<String, dynamic> res = json.decode(rawResponse);
    className = res['class_name'];
  }

  @override
  String toString() {
    return {
      'class_name': className,
      'currentPage': currentPage,
      'totalEntries': totalEntries,
      'perPage': perPage,
      'skip': skip,
      'limit': limit,
      'items': items
    }.toString();
  }
}
