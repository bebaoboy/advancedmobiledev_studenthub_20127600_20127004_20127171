class DeleteItemsResult {
  List<String>? successfullyDeleted;
  List<String>? notFound;
  List<String>? wrongPermissions;

  DeleteItemsResult.fromJson(Map<String, dynamic> json) {
    var successfullyDeletedRaw = json['SuccessfullyDeleted'];
    if (successfullyDeletedRaw != null) {
      successfullyDeleted = List.of(successfullyDeletedRaw['ids'])
          .map((element) => element.toString())
          .toList();
    }

    var notFoundRaw = json['NotFound'];
    if (notFoundRaw != null) {
      notFound = List.of(notFoundRaw['ids'])
          .map((element) => element.toString())
          .toList();
    }

    var wrongPermissionsRaw = json['WrongPermissions'];
    if (wrongPermissionsRaw != null) {
      wrongPermissions = List.of(wrongPermissionsRaw['ids'])
          .map((element) => element.toString())
          .toList();
    }
  }

  @override
  String toString() {
    return "{"
        "successfullyDeleted: $successfullyDeleted, "
        "notFound: $notFound, "
        "wrongPermissions: $wrongPermissions"
        "}";
  }
}
