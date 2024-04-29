import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/interview/interview_repository.dart';
import 'package:boilerplate/domain/usecase/chat/schedule_interview.dart';
import 'package:dio/dio.dart';

class CheckMeetingAvailabilityUseCase
    extends UseCase<Response, InterviewParams> {
  final InterviewRepository _interviewRepository;

  CheckMeetingAvailabilityUseCase(this._interviewRepository);

  @override
  Future<Response> call({required InterviewParams params}) async {
    return await _interviewRepository.checkAvailability(params);
  }
}
