extension CapExtension on String {
  String get inCaps => '${trim()[0].toUpperCase()}${substring(1)}';
  String get allInCaps => toUpperCase();
  String toTitleCase() => trim().replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.inCaps).join(' ');
}