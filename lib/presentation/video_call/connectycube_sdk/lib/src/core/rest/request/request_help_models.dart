import '../../../../connectycube_core.dart';

class RequestFilter {
  String? fieldType;
  String fieldName;
  dynamic fieldValue;
  String rule;

  RequestFilter(this.fieldType, this.fieldName, this.rule, this.fieldValue);
}

class RequestSorter {
  String? fieldType;
  String fieldName;
  String sortType;

  RequestSorter(this.sortType, this.fieldType, this.fieldName);

  RequestSorter.asc(this.fieldName) : sortType = OrderType.ASC;

  RequestSorter.desc(this.fieldName) : sortType = OrderType.DESC;
}

class RequestPaginator {
  /// the `page` should start from 0
  int? page;
  int itemsPerPage;

  RequestPaginator(this.itemsPerPage, {this.page});
}
