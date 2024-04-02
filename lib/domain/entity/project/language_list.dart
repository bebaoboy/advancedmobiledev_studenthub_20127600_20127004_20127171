import 'package:boilerplate/domain/entity/project/entities.dart';

class LanguageList {
  List<Language>? languages;

  LanguageList({
    this.languages,
  });

  factory LanguageList.fromJson(List<dynamic> json) {
    List<Language> languages = <Language>[];
    languages = json.map((language) => Language.fromMap(language)).toList();

    return LanguageList(
      languages: languages,
    );
  }
}