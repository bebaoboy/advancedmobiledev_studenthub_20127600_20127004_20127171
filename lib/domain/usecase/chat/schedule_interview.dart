import 'dart:async';
import 'dart:io';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/interview/interview_repository.dart';

class InterviewParams {
  String? projectId = "";
  String? interviewId = "";
  String title;
  String content;
  String startDate;
  String endDate;
  String meetingCode;
  String meetingId;
  String senderId;
  String receiverId;

  InterviewParams(
      this.interviewId, this.projectId, this.meetingId, this.meetingCode,
      {required this.title,
      required this.startDate,
      required this.endDate,
      required this.senderId,
      required this.receiverId,
      this.content = ""});
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
        var interview = InterviewSchedule.fromJsonApi(data);
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
