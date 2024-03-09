class Skill {
  final String name;
  final String description;
  final String imageUrl;

  const Skill(this.name, this.description, this.imageUrl);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Skill && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'Profile{$name}';
  }
}

// -------------------------------------------------

class Language {
  String name;
  String proficiency;
  bool readOnly = true;
  bool enabled = true;

  Language(this.name, this.proficiency,
      {this.readOnly = true, this.enabled = true});
}

class Education {
  String name;
  String year;
  bool readOnly = true;
  bool enabled = true;

  Education(this.name, this.year, {this.readOnly = true, this.enabled = true});
}

class ProjectExperience {
  String name;
  DateTime? startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime? endDate = DateTime.now();
  String? description = "...";
  String link = "";
  bool readOnly = true;
  bool enabled = true;
  List<String>? skills = [];

  ProjectExperience(this.name,
      {this.description,
      this.link="",
      this.startDate,
      this.endDate,
      this.readOnly = true,
      this.enabled = true,
      this.skills});
}
