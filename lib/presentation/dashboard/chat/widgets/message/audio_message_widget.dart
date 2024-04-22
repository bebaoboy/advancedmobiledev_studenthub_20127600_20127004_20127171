// ignore_for_file: must_be_immutable, empty_catches

import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';

/// this widget is used to render voice note container
/// with ist full functionality

class AudioMessageWidget extends StatefulWidget {
  AbstractAudioMessage message;
  final Color senderColor;
  final Color inActiveAudioSliderColor;
  final Color activeAudioSliderColor;
  final bool isSender;
  final String name;

  AudioMessageWidget(
      {super.key,
      required this.message,
      required this.senderColor,
      required this.inActiveAudioSliderColor,
      required this.activeAudioSliderColor,
      required this.name,
      this.isSender = true});

  @override
  _AudioMessageWidgetState createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  final player = AudioPlayer();
  Duration? duration = Duration.zero;
  Duration seekBarPosition = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    setData();
    super.initState();
  }

  void setData() async {
    try {
      Uri.parse(widget.message.uri).isAbsolute
          ? duration = await player.setUrl(widget.message.uri)
          : duration = await player.setFilePath(widget.message.uri);
    } catch (e) {}

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        player.stop();
      },
      child: Column(
        crossAxisAlignment:
            widget.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
              width: MediaQuery.of(context).size.width * 0.7,
              padding: const EdgeInsets.symmetric(
                horizontal: 10 * 0.75,
              ),
              child: AutoSizeText(
                widget.name,
                maxLines: 1,
                minFontSize: 10,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            padding: const EdgeInsets.symmetric(
              horizontal: 10 * 0.75,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: widget.senderColor, width: 1),
              color:
                  (widget.senderColor).withOpacity(widget.isSender ? 1 : 0.1),
            ),
            child: Row(
              /// mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    if (player.audioSource == null) return;
                    isPlaying ? player.pause() : play();
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color:
                        widget.isSender ? Colors.white : (widget.senderColor),
                    // size: 25,
                  ),
                ),
                Expanded(
                  child: Slider(
                      activeColor: widget.activeAudioSliderColor,
                      inactiveColor: widget.inActiveAudioSliderColor,
                      max: player.duration?.inMilliseconds.toDouble() ?? 1,
                      value: player.position.inMilliseconds.toDouble(),
                      onChanged: (d) {
                        if (player.audioSource == null) return;

                        setState(() {
                          player.seek(Duration(milliseconds: d.toInt()));
                        });
                      }),
                ),
                Text(
                  "${_printDuration(player.position)}/${_printDuration(player.duration)}",
                  style: TextStyle(
                      fontSize: 12,
                      color: widget.isSender ? Colors.white : null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// this function is used to play audio wither its from url or path file
  void play() {
    if (player.duration != null && player.position >= player.duration!) {
      player.seek(Duration.zero);
      setState(() {
        isPlaying = false;
      });
    }
    //print(player.duration);
    //print(player.position);
    player.play();

    player.positionStream.listen((duration) {
      // duration == player.duration;
      try {
        setState(() {
          seekBarPosition = duration;
        });
        if (player.duration != null && player.position >= player.duration!) {
          player.stop();
          player.seek(Duration.zero);
          setState(() {
            isPlaying = false;
            seekBarPosition = Duration.zero;
          });
        }
      } catch (e) {}
    });
  }

  /// function used to print the duration of the current audio duration
  String _printDuration(Duration? duration) {
    if (duration == null) return "";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String hoursString =
        duration.inHours == 0 ? '' : "${twoDigits(duration.inHours)}:";
    return "$hoursString$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }
}
