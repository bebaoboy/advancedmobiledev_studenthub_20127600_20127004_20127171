import 'dart:async';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_calls.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/src/calls/models/call_base_session.dart';
import 'package:flutter/foundation.dart';

const MEDIA_TYPE_AUDIO = 'audio';
const MEDIA_TYPE_VIDEO = 'video';
const MIC_CORRECTION_COEFFICIENT = 32767; //the maximum reproduced value

class CubeStatsReportsManager {
  final String TAG = 'CubeStatsReportsManager';
  BaseSession? callSession;

  final StreamController<CubeMicLevelEvent> _micLevelStreamController =
      StreamController.broadcast();

  /// provides the opponents’ mic level from 0 to 1
  /// the feature is useful for detecting the talker and marking it on the UI
  Stream<CubeMicLevelEvent> get micLevelStream =>
      _micLevelStreamController.stream;

  final StreamController<CubeVideoBitrateEvent> _videoBitrateStreamController =
      StreamController.broadcast();

  /// provides the bitrate of the opponents’ video
  /// the feature is useful for detecting the connection quality and showing it on the UI
  Stream<CubeVideoBitrateEvent> get videoBitrateStream =>
      _videoBitrateStreamController.stream;

  final Map<int, int?> _lastUserTimeStamps = {};
  final Map<int, int?> _lastUserBytesReceived = {};

  init(BaseSession callSession) {
    this.callSession = callSession;

    callSession.statsReports.listen((statsReport) {
      statsReport.stats.removeWhere((stat) =>
          stat.type != 'inbound-rtp' &&
          stat.type != 'ssrc' &&
          stat.type != 'media-source' &&
          stat.type != 'track');

      calculateMicLevel(statsReport);
      calculateVideoBitrate(statsReport);
    });
  }

  dispose() {
    callSession = null;
    _micLevelStreamController.close();
    _videoBitrateStreamController.close();

    _lastUserTimeStamps.clear();
    _lastUserBytesReceived.clear();
  }

  void calculateMicLevel(CubeStatsReport report) {
    for (var statsReport in report.stats) {
      var micLevel;
      String? trackId;
      String? trackIdentifier;
      int? statsUserId;

      if (statsReport.type == 'inbound-rtp') {
        if (MEDIA_TYPE_AUDIO == statsReport.values['mediaType'] ||
            MEDIA_TYPE_AUDIO == statsReport.values['kind']) {
          var volume = statsReport.values['audioLevel'];

          micLevel = volume;
          trackId = statsReport.values['trackId']?.toString();
          trackIdentifier = statsReport.values['trackIdentifier']?.toString();
        }
      } else if (statsReport.type == 'ssrc') {
        if (MEDIA_TYPE_AUDIO == statsReport.values['mediaType']) {
          var volume = statsReport.values['audioOutputLevel'];

          if (volume != null) {
            micLevel = int.parse(volume) / MIC_CORRECTION_COEFFICIENT;
            trackId ??= statsReport.values['trackId']?.toString();

            trackIdentifier ??= statsReport.values['trackIdentifier']?.toString();
          }
        }
      } else if (statsReport.type == 'media-source') {
        if (MEDIA_TYPE_AUDIO == statsReport.values['kind']) {
          var volume = statsReport.values['audioLevel'];

          if (volume != null) {
            micLevel = double.parse(volume.toString());
            trackId ??= statsReport.values['trackId']?.toString();

            trackIdentifier ??= statsReport.values['trackIdentifier']?.toString();
          }
          statsUserId = CubeSessionManager.instance.activeSession?.userId;
        }
      } else if (statsReport.type == 'track') {}

      if (micLevel != null) {
        var userId = trackId == null && trackIdentifier == null
            ? statsUserId ?? report.userId
            : callSession?.getUserIdForStream(
                trackId, trackIdentifier, statsUserId ?? report.userId);

        if (userId != null) {
          _micLevelStreamController
              .add(CubeMicLevelEvent(userId, micLevel ?? 0.0));
        }
      }
    }
  }

  void calculateVideoBitrate(CubeStatsReport report) {
    for (var statsReport in report.stats) {
      var timeStamp;
      int finalBytesReceived = 0;
      String? trackId;
      String? trackIdentifier;

      if (statsReport.type == 'inbound-rtp') {
        if (MEDIA_TYPE_VIDEO == statsReport.values['mediaType'] ||
            MEDIA_TYPE_VIDEO == statsReport.values['kind']) {
          var bytesReceived = statsReport.values['bytesReceived'];

          finalBytesReceived = int.parse(bytesReceived.toString());
          timeStamp = statsReport.timestamp.floor();
          trackId = statsReport.values['trackId']?.toString();
          trackIdentifier = statsReport.values['trackIdentifier']?.toString();
        }
      } else if (statsReport.type == 'ssrc') {
        if (MEDIA_TYPE_VIDEO == statsReport.values['mediaType']) {
          var bytesReceived = statsReport.values['bytesReceived'];

          if (bytesReceived != null) {
            finalBytesReceived = int.parse(bytesReceived.toString());
            timeStamp = statsReport.timestamp.floor();
            trackId ??= statsReport.values['trackId']?.toString();

            trackIdentifier ??= statsReport.values['trackIdentifier']?.toString();
          }
        }
      } else if (statsReport.type == 'media-source') {
        if (MEDIA_TYPE_VIDEO == statsReport.values['kind']) {
          var bytesReceived = statsReport.values['bytesReceived'];

          if (bytesReceived != null) {
            finalBytesReceived = int.parse(bytesReceived.toString());
            timeStamp = statsReport.timestamp.floor();
            trackId ??= statsReport.values['trackId']?.toString();

            trackIdentifier ??= statsReport.values['trackIdentifier']?.toString();
          }
        }
      } else if (statsReport.type == 'track') {}

      if (finalBytesReceived != 0) {
        var userId = trackId == null && trackIdentifier == null
            ? report.userId
            : callSession?.getUserIdForStream(
                trackId, trackIdentifier, report.userId);

        if (userId != null) {
          var previousTimestamp = _lastUserTimeStamps[userId];
          var previousBytesReceived = _lastUserBytesReceived[userId];

          if (!kIsWeb) {
            timeStamp = timeStamp ~/ 1000;
          }

          if (previousTimestamp == null || previousBytesReceived == null) {
            _lastUserTimeStamps[userId] = timeStamp;
            _lastUserBytesReceived[userId] = finalBytesReceived;
          } else if (finalBytesReceived >= previousBytesReceived) {
            var timePassed = timeStamp - previousTimestamp;

            int bitRate;

            try {
              bitRate = (((finalBytesReceived - previousBytesReceived) * 8) /
                      timePassed)
                  .floor();

              _lastUserTimeStamps[userId] = timeStamp;
              _lastUserBytesReceived[userId] = finalBytesReceived;

              _videoBitrateStreamController
                  .add(CubeVideoBitrateEvent(userId, bitRate));
            } catch (e) {
              log('ERROR during calculate bitrate from statId ${statsReport.id}, error: $e  ',
                  TAG);
            }
          }
        }
      }
    }
  }
}

class CubeMicLevelEvent {
  final int userId;
  final double micLevel;

  CubeMicLevelEvent(this.userId, this.micLevel);
}

class CubeVideoBitrateEvent {
  final int userId;
  final int bitRate;

  CubeVideoBitrateEvent(this.userId, this.bitRate);
}
