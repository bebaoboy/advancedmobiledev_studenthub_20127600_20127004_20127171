import '../models/cube_user.dart';
import '../../rest/query/query.dart';
import '../../rest/request/request_help_models.dart';
import '../../rest/request/rest_request.dart';
import '../../rest/response/paged_result.dart';
import '../../utils/consts.dart';

class GetUsersV2Query extends AutoManagedQuery<PagedResult<CubeUser>> {
  RequestPaginator? _paginator;
  RequestSorter? _sorter;

  Map<String, dynamic>? _additionalParams;

  GetUsersV2Query(Map<String, dynamic> parameters,
      {RequestPaginator? paginator, RequestSorter? sorter})
      : _additionalParams = parameters,
        _paginator = paginator,
        _sorter = sorter;

  GetUsersV2Query.byIdentifier(String identifierName, dynamic identifierValue,
      {Map<String, dynamic>? additionalParameters})
      : _additionalParams = additionalParameters {
    _additionalParams ??= {};

    _additionalParams!.addEntries([MapEntry(identifierName, identifierValue)]);
  }

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([USERS_V2_ENDPOINT]));
  }

  @override
  setParams(RestRequest request) {
    super.setParams(request);

    Map<String, dynamic> parameters = request.params;

    if (_sorter != null) {
      _additionalParams?['sort_${_sorter!.sortType}'] = _sorter!.fieldName;
    }

    if (_paginator != null && _paginator!.page != null) {
      putValue(parameters, LIMIT, _paginator!.itemsPerPage);
      putValue(
          parameters, OFFSET, _paginator!.itemsPerPage * _paginator!.page!);
    }

    if (_additionalParams != null && _additionalParams!.isNotEmpty) {
      _additionalParams!.forEach((key, value) {
        putValue(parameters, key, value);
      });
    }
  }

  @override
  PagedResult<CubeUser> processResult(String response) {
    return PagedResult<CubeUser>(
        response, (element) => CubeUser.fromJson(element));
  }
}
