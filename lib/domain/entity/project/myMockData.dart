import 'package:boilerplate/domain/entity/project/project.dart';

var myProjects = [
  Project(
      title: "ABC",
      description: "description",
      timeCreated: DateTime.parse('2023-03-13'),
      scope: Scope.long,
      proposal: <Student>[
        Student(
            name: 'Luu Tuan Quan',
            introduction: 'I am happy',
            education: '4th year students',
            title: 'Fullstack Engineer',
            yearOfExperience: 3,
            review: 'I find your project suitable'),
        Student(
            name: 'Huynh Minh Bao',
            introduction: 'I am happy',
            education: '4th year students',
            title: 'Fullstack Engineer',
            yearOfExperience: 3,
            review: 'I find your project suitable'),
        Student(
            name: 'Vu Huy Hoang',
            introduction: 'I am eager',
            education: '4th year students',
            title: 'Fullstack Engineer',
            yearOfExperience: 3,
            review: 'I find your project suitable')
      ]),
  Project(
      title: "XYZ",
      description: "description",
      timeCreated: DateTime.parse('2023-03-12')),
  Project(
      title: "JKMM",
      description: "description",
      timeCreated: DateTime.parse('2023-03-13'),
      scope: Scope.long),
  Project(
      title: "man bhsk p",
      description: "description",
      timeCreated: DateTime.parse('2023-03-11')),
  Project(
      title: "jOa josfj á ",
      description: "description",
      timeCreated: DateTime.parse('2023-03-13')),
];

var workingProjects = [
  Project(
      title: "XYZ",
      description: "description",
      timeCreated: DateTime.parse('2023-03-12')),
];
