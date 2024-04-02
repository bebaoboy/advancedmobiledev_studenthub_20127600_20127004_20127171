import 'package:boilerplate/domain/entity/project/entities.dart';

var myProjects = [
  Project(
      title: "ABC",
      description:
          'The ParentDataWidget Expanded(flex: 1) wants to apply ParentData of type FlexParentData to a RenderObject, which has been set up to accept ParentData of incompatible type ParentData.Usually, this means that the Expanded widget has the wrong ancestor RenderObjectWidget. Typically, Expanded widgets are placed directly inside Flex widgets.The offending Expanded is currently placed inside a AbsorbPointer widget.The ownership chain for the RenderObject that received the incompatible parent data was: Column ← Expanded ← AbsorbPointer ← Row ← Padding ← Semantics ← DefaultTextStyle ← AnimatedDefaultTextStyle ← _InkFeatures-[GlobalKey#fae7b ink renderer] ← NotificationListener<LayoutChangedNotification> ← ⋯',
      timeCreated: DateTime.parse('2023-03-13'),
      scope: Scope.long,
      proposal: [
        Proposal(
            student: StudentProfile(
                fullName: 'Luu Tuan Quan',
                introduction: 'I am happy',
                education: '4th year students',
                title: 'Fullstack Engineer',
                yearOfExperience: 3,
                review: 'I find your project suitable',
                id: 1)),
        Proposal(
            student: StudentProfile(
                fullName: 'Huynh Minh Bao',
                introduction: 'I am happy',
                education: '4th year students',
                title: 'Fullstack Engineer',
                yearOfExperience: 3,
                review: 'I find your project suitable',
                id: 2)),
        Proposal(
            student: StudentProfile(
                fullName: 'Vu Huy Hoang',
                introduction: 'I am eager',
                education: '4th year students',
                title: 'Fullstack Engineer',
                yearOfExperience: 3,
                review: 'I find your project suitable',
                id: 3))
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

var studentProjects = [
  StudentProject(
      title: "XYZ",
      description: "description",
      timeCreated: DateTime.parse('2023-03-12'),
      submittedTime: DateTime.parse('2024-03-12')),
  StudentProject(
      title: "JKMM",
      description: "description",
      timeCreated: DateTime.parse('2023-03-13'),
      scope: Scope.long,
      submittedTime: DateTime.parse('2024-03-17')),
  StudentProject(
      title: "man bhsk p",
      description: "description",
      timeCreated: DateTime.parse('2023-03-11'),
      isAccepted: true,
      isSubmitted: true,
      submittedTime: DateTime.parse('2024-03-18')),
  StudentProject(
      title: "JKMM",
      description: "description",
      timeCreated: DateTime.parse('2023-03-13'),
      scope: Scope.long,
      submittedTime: DateTime.parse('2024-03-17')),
  StudentProject(
      title: "JKMM",
      description: "description",
      timeCreated: DateTime.parse('2023-03-13'),
      scope: Scope.long,
      submittedTime: DateTime.parse('2024-03-17')),
];

var studentWorkingProjects = [
  StudentProject(
      title: "jOa josfj á ",
      description: "description",
      timeCreated: DateTime.parse('2023-03-13'),
      submittedTime: DateTime.parse('2024-03-11')),
];
