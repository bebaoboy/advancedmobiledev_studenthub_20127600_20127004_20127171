import 'package:boilerplate/data/network/apis/interview/interview_api.dart';
import 'package:boilerplate/domain/repository/interview/interview_repository.dart';
import 'package:dio/dio.dart';

class InterviewRepositoryImpl extends InterviewRepository {
  final InterviewApi _interviewApi;

  InterviewRepositoryImpl(this._interviewApi);

  @override
  Future<Response> deleteMeeting(params){
    var response = _interviewApi.deleteInterview(params);
    return response;
  }

  @override
  Future<Response> disableMeeting(params) {
    var response = _interviewApi.disableInterview(params);
    return response;
  }

  @override
  Future<Response> postMeeting(params) {
    var response = _interviewApi.scheduleInterview(params);
    return response;
  }

  @override
  Future<Response> updateMeeting(params) {
    var response = _interviewApi.updateInterview(params);
    return response;
  }
}
