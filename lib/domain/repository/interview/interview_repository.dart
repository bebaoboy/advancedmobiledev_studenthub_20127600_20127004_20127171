import 'package:dio/dio.dart';

abstract class InterviewRepository {
  Future<Response> postMeeting(params);
  Future<Response> updateMeeting(params);
  Future<Response> disableMeeting(params);
  Future<Response> deleteMeeting(params);
  Future<Response> checkAvailability(params);
}
