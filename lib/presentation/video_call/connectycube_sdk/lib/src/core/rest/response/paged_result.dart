// ignore_for_file: use_function_type_syntax_for_parameters

import 'dart:convert';

class PagedResult<T> {
  int? currentPage;
  int? totalEntries;
  int? perPage;
  int? skip;
  int? limit;

  late List<T> items;

  PagedResult(String rawResponse, T function(element)) {
    Map<String, dynamic> res = jsonDecode(rawResponse);

    currentPage = res['current_page'];
    perPage = res['per_page'];
    totalEntries = res['total_entries'];
    skip = res['skip'];
    limit = res['limit'];
    List<dynamic> items = List.of(res['items']);

    if (items.isEmpty) {
      this.items = [];
    } else {
      this.items = items.map(function).toList();
    }
  }

  @override
  String toString() {
    return {
      'currentPage': currentPage,
      'totalEntries': totalEntries,
      'perPage': perPage,
      'skip': skip,
      'limit': limit,
      'items': items
    }.toString();
  }
}
