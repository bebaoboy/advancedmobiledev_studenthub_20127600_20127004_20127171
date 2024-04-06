import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';

var myProjects = [
  Project(
      title: "ABC",
      description:
          'The ParentDataWobjectIdget Expanded(flex: 1) wants to apply ParentData of type FlexParentData to a RenderObject, which has been set up to accept ParentData of incompatible type ParentData.Usually, this means that the Expanded wobjectIdget has the wrong ancestor RenderObjectWobjectIdget. Typically, Expanded wobjectIdgets are placed directly insobjectIde Flex wobjectIdgets.The offending Expanded is currently placed insobjectIde a AbsorbPointer wobjectIdget.The ownership chain for the RenderObject that received the incompatible parent data was: Column ← Expanded ← AbsorbPointer ← Row ← Padding ← Semantics ← DefaultTextStyle ← AnimatedDefaultTextStyle ← _InkFeatures-[GlobalKey#fae7b ink renderer] ← NotificationListener<LayoutChangedNotification> ← ⋯',
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
                objectId: 1.toString())),
        Proposal(
            student: StudentProfile(
                fullName: 'Huynh Minh Bao',
                introduction: 'I am happy',
                education: '4th year students',
                title: 'Fullstack Engineer',
                yearOfExperience: 3,
                review: 'I find your project suitable',
                objectId: 2.toString())),
        Proposal(
            student: StudentProfile(
                fullName: 'Vu Huy Hoang',
                introduction: 'I am eager',
                education: '4th year students',
                title: 'Fullstack Engineer',
                yearOfExperience: 3,
                review: 'I find your project suitable',
                objectId: 3.toString()))
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
