import 'dart:async';
import 'dart:io';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/interview/interview_repository.dart';

class InterviewParams {
  String? projectId = "";
  String? interviewId = "";
  String title;
  String startDate;
  String endDate;

  InterviewParams(this.interviewId, this.projectId,
      {required this.title, required this.startDate, required this.endDate});
}

class ScheduleInterviewUseCase
    extends UseCase<InterviewSchedule?, InterviewParams> {
  final InterviewRepository _interviewRepository;

  ScheduleInterviewUseCase(this._interviewRepository);

  @override
  Future<InterviewSchedule?> call({required InterviewParams params}) async {
    try {
      var response = await _interviewRepository.postMeeting(params);
      if (response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        var data = response.data['result'];
        var interview = InterviewSchedule.fromJson(data);
        return interview;
      } else {
        print(response.data['errorDetails']);
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
