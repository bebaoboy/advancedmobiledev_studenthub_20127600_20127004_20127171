export 'connectycube_core.dart';

export 'src/custom_objects/models/cube_base_custom_object.dart';
export 'src/custom_objects/models/cube_custom_object.dart';
export 'src/custom_objects/models/cube_custom_object_permissions.dart';
export 'src/custom_objects/rest/models/custom_object_permissions_result.dart';
export 'src/custom_objects/rest/models/paged_custom_object_result.dart';

import 'connectycube_core.dart';

import 'src/custom_objects/models/cube_custom_object.dart';
import 'src/custom_objects/rest/models/custom_object_permissions_result.dart';
import 'src/custom_objects/rest/models/paged_custom_object_result.dart';
import 'src/custom_objects/rest/query/custom_object_queries.dart';

/// Returns created object
///
/// [customObject] - your object for creation. `className` field is required for this object
Future<CubeCustomObject> createCustomObject(CubeCustomObject customObject) {
  return CreateCustomObjectQuery(customObject).perform();
}

/// Returns custom object with [id]
///
/// [className] - name of the class of custom objects which you want to get
/// [id] - id of custom object which you want to get
Future<CubeCustomObject?> getCustomObjectById(String className, String id) {
  return GetCustomObjectByIdQuery(className, id).perform();
}

/// Returns list of requested objects
///
/// [className] - name of the class of custom objects which you want to get
/// [ids] - ids of custom objects which you want to get
Future<PagedCustomObjectResult> getCustomObjectsByIds(
    String className, List<String> ids) {
  return GetCustomObjectQuery.byIds(className, ids).perform();
}

/// Returns list of requested objects
///
/// [className] - name of the class of custom objects which you want to get
/// [params] - additional parameter for search, see https://developers.connectycube.com/server/custom_objects?id=options-to-apply
Future<PagedCustomObjectResult> getCustomObjectsByClassName(String className,
    [Map<String, dynamic>? params]) {
  return GetCustomObjectQuery.byClassName(className, params).perform();
}

/// Returns permissions for requested by [id] object
///
/// [className] - name of the class of custom objects which you want to get
/// [id] - id of the object, whose permissions you want to get
Future<CustomObjectPermissionsResult> getCustomObjectPermissions(
    String className, String id) {
  return GetCustomObjectPermissionsQuery(className, id).perform();
}

/// Returns updated object
///
/// [className] - name of the class of custom objects which you want to update
/// [id] - id of the object, you want to update
/// [params] - additional parameter for updating, see https://developers.connectycube.com/server/custom_objects?id=parameters-3
Future<CubeCustomObject> updateCustomObject(
    String className, String id, Map<String, dynamic> params) {
  return UpdateCustomObjectQuery(className, id, params).perform();
}

/// Returns list of updated objects
///
/// [className] - name of the class of custom objects which you want to update
/// [params] - additional parameter for updating, see https://developers.connectycube.com/server/custom_objects?id=parameters-4
Future<PagedCustomObjectResult> updateCustomObjectsByCriteria(String className,
    [Map<String, dynamic>? params]) {
  return UpdateCustomObjectByCriteriaQuery(className, params).perform();
}

/// [className] - name of the class of custom objects which you want to delete
/// [id] - id of custom object which you want to delete
Future<void> deleteCustomObjectById(String className, String id) {
  return DeleteCustomObjectByIdQuery(className, id).perform();
}

/// Returns [DeleteItemsResult] object with detailed information about deleting result
///
/// [className] - name of the class of custom objects which you want to delete
/// [ids] - ids of custom objects which you want to delete
Future<DeleteItemsResult?> deleteCustomObjectsByIds(
    String className, List<String> ids) {
  return DeleteCustomObjectsByIdsQuery(className, ids).perform();
}

/// Returns the count of deleted objects
///
/// [className] - name of the class of custom objects which you want to delete
/// [params] - additional parameter for deleting, see https://developers.connectycube.com/server/custom_objects?id=query-format
Future<int> deleteCustomObjectsByCriteria(String className,
    [Map<String, dynamic>? params]) {
  return DeleteCustomObjectsByCriteriaQuery(className, params).perform();
}
