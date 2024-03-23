const String EMPTY_STRING = "";

bool isEmpty(String? string) {
  return string == null || string.length == 0;
}

/// Returns query parameters string, e.g.
/// application_id=774&auth_key=aY7WwSRmu2-GbfA&nonce=1451135156
/// This function is more suitable for `php` API servers.
/// Try the [getUriQueryString] if the server returns errors related to the syntax of the query string
String getQueryString(Map params,
    {String prefix = '&', bool inRecursion = false}) {
  String query = '';

  params.forEach((key, value) {
    if (inRecursion) {
      key = Uri.encodeComponent('[$key]');
    }

    if (value is String || value is int || value is double || value is bool) {
      query += '$prefix$key=${Uri.encodeComponent(value.toString())}';
    } else if (value is List || value is Set || value is Map) {
      if (value is Set) {
        value = value.toList().asMap();
      } else if (value is List) {
        value = value.asMap();
      }

      value.forEach((k, v) {
        query +=
            getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
      });
    }
  });

  return inRecursion || query.isEmpty
      ? query
      : query.substring(1, query.length);
}

/// Returns query parameters string, e.g.
/// application_id=774&auth_key=aY7WwSRmu2-GbfA&nonce=1451135156
/// The difference between this function from the [getQueryString] is that this one is based on the `dart` specifications
String getUriQueryString(Map<String, dynamic> params) {
  var stringedParameters = params.map((key, value) {
    if (value is Set || value is List) {
      value = value.map((element) {
        return element.toString();
      }).toList();
    } else {
      value = value.toString();
    }

    return MapEntry(key, value);
  });

  var newUri = Uri(queryParameters: stringedParameters);
  return newUri.query;
}
