class NotiList {
  String code;

  String locale;

  String language;

  Map<String, String>? dictionary;

  NotiList({
    required this.code,
    required this.locale,
    required this.language,
    this.dictionary,
  });
}
