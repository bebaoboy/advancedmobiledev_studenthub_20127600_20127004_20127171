class AddressBookResult {
  int? createdCount;
  int? updatedCount;
  int? deletedCount;
  Map<String, List<String>>? rejected;

  AddressBookResult.fromJson(Map<String, dynamic> json) {
    createdCount = json['created'];
    updatedCount = json['updated'];
    deletedCount = json['deleted'];

    var rejected = json['rejected'];
    if (rejected != null) {
      this.rejected = <String, List<String>>{};

      Map<String, dynamic> rawRejected = Map.of(rejected);
      for (String key in rawRejected.keys) {
        var listValue = List.of(rawRejected[key]);
        this.rejected![key] =
            listValue.map((element) => element.toString()).toList();
      }
    }
  }

  @override
  String toString() {
    return {
      'created': createdCount,
      'updated': updatedCount,
      'deleted': deletedCount,
      'rejected': rejected
    }.toString();
  }
}
