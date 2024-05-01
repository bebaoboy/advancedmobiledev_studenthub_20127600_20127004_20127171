import 'dart:async';
import 'dart:io';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/interview/interview_repository.dart';
import 'package:boilerplate/domain/usecase/chat/schedule_interview.dart';

class GetInterviewUseCase
    extends UseCase<InterviewSchedule?, InterviewParams> {
  final InterviewRepository _interviewRepository;

  GetInterviewUseCase(this._interviewRepository);

  @override
  Future<InterviewSchedule?> call({required InterviewParams params}) async {
    try {
      var response = await _interviewRepository.getMeeting(params);
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
