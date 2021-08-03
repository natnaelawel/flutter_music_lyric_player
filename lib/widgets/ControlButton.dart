import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  ControlButtons(this.player);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<bool>(
          stream: player.shuffleModeEnabledStream,
          builder: (context, snapshot) {
            return _shuffleButton(context, snapshot.data ?? false);
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (_, __) {
            return _previousButton();
          },
        ),
        StreamBuilder<PlayerState?>(
          stream: player.playerStateStream,
          builder: (_, snapshot) {
            final playerState = snapshot.data;
            return _playPauseButton(playerState!);
          },
        ),
        StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (_, __) {
              return _nextButton();
            }),
        StreamBuilder<LoopMode>(
          stream: player.loopModeStream,
          builder: (context, snapshot) {
            return _repeatButton(context, snapshot.data ?? LoopMode.off);
          },
        ),
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: player.speed,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        )
      ],
    );
  }

  Widget _playPauseButton(PlayerState playerState) {
    final processingState = playerState.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: CircularProgressIndicator(),
      );
    } else if (player.playing != true) {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: player.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: player.pause,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.replay),
        iconSize: 64.0,
        onPressed: () =>
            player.seek(Duration.zero, index: player.effectiveIndices!.first),
      );
    }
  }

  // void onRepeatButtonPressed() {
  // switch (RenderPerformanceOverlay()) {
  //   case RepeatState.off:
  //     _audioPlayer.setLoopMode(LoopMode.off);
  //     break;
  //   case RepeatState.repeatSong:
  //     _audioPlayer.setLoopMode(LoopMode.one);
  //     break;
  //   case RepeatState.repeatPlaylist:
  //     _audioPlayer.setLoopMode(LoopMode.all);
  // }

  Widget _shuffleButton(BuildContext context, bool isEnabled) {
    return IconButton(
      icon: isEnabled
          ? Icon(Icons.shuffle, color: Theme.of(context).accentColor)
          : Icon(Icons.shuffle),
      onPressed: () async {
        final enable = !isEnabled;
        if (enable) {
          await player.shuffle();
        }
        await player.setShuffleModeEnabled(enable);
      },
    );
  }

  Widget _previousButton() {
    return IconButton(
      icon: Icon(Icons.skip_previous),
      onPressed: player.hasPrevious ? player.seekToPrevious : null,
    );
  }

  Widget _nextButton() {
    return IconButton(
      icon: Icon(Icons.skip_next),
      onPressed: () {
        // final pageManager = getIt<AudioHandler>();
        // print("queue size ${pos}");
        // player.durationStream.listen((duration) {
        // List<SongInfo> songs = context.read<AudioRepository>().songs;
        // final songIndex = player.playbackEvent.currentIndex;
        // print('current index: $songIndex, duration: $duration');
        // final modifiedMediaItem = mediaItem.copyWith(duration: duration);
        // _queue[songIndex] = modifiedMediaItem;
        // _handler.playMediaItem(MediaItem(
        // id: songs[songIndex!].id, title: songs[songIndex].title));
        // player.setUrl(songs[songIndex!].uri);
        // player.play();
        // AudioServiceBackground.setMediaItem(_queue[songIndex]);
        // AudioServiceBackground.setQueue(_queue);
        // });

        // int? pos = player.currentIndex;
        // if (pos != null) {
        //   pos += 1;
        // }
        // _handler.playbackState.skip(30);
        // int index = getPosition();
        // print("song index is $index ${songs.length}");
        // final song = songs[index + 1];
        // player.setUrl(song.uri);
        // player.play();
        // return Provider.of<AudioPlayerProvider>(context).playNext();
        // context.read<AudioPlayerProvider>().playPlayPause();
        // context.read<AudioPlayerProvider>().playNext();
        // AudioHandler().skipToNext();
        // print;
        // ("player has next ${player.hasNext == true}");
        // player.seek(Duration.zero, index: pos );
        // player.seek(Duration(seconds: 200));
        //  player.hasNext ? (player.seekToNext : null
      },
    );
  }

  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      Icon(Icons.repeat),
      Icon(Icons.repeat, color: Theme.of(context).accentColor),
      Icon(Icons.repeat_one, color: Theme.of(context).accentColor),
    ];
    const cycleModes = [
      LoopMode.off,
      LoopMode.all,
      LoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);
    return IconButton(
      icon: icons[index],
      onPressed: () {
        player.setLoopMode(
            cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
      },
    );
  }

  void showSliderDialog({
    required BuildContext context,
    required String title,
    required int divisions,
    required double min,
    required double max,
    String valueSuffix = '',
    required double value,
    required Stream<double> stream,
    required ValueChanged<double> onChanged,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: StreamBuilder<double>(
          stream: stream,
          builder: (context, snapshot) => Container(
            height: 100.0,
            child: Column(
              children: [
                Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                    style: TextStyle(
                        fontFamily: 'Fixed',
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0)),
                Slider(
                  divisions: divisions,
                  min: min,
                  max: max,
                  value: snapshot.data ?? value,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  SeekBar({
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            activeTrackColor: Colors.blue.shade100,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
                  widget.duration.inMilliseconds.toDouble()),
              onChanged: (value) {
                setState(() {
                  _dragValue = value;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(Duration(milliseconds: value.round()));
                }
              },
              onChangeEnd: (value) {
                if (widget.onChangeEnd != null) {
                  widget.onChangeEnd!(Duration(milliseconds: value.round()));
                }
                _dragValue = null;
              },
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.transparent,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
                widget.duration.inMilliseconds.toDouble()),
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
              }
              _dragValue = null;
            },
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("$_remaining")
                      ?.group(1) ??
                  '$_remaining',
              style: Theme.of(context).textTheme.caption),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

// }

// @override
// Widget build(BuildContext context) {
//   return Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       IconButton(
//         icon: Icon(Icons.volume_up),
//         onPressed: () {
//           showSliderDialog(
//             context: context,
//             title: "Adjust volume",
//             divisions: 10,
//             min: 0.0,
//             max: 1.0,
//             value: player.volume,
//             stream: player.volumeStream,
//             onChanged: player.setVolume,
//           );
//         },
//       ),

//       StreamBuilder<PlayerState>(
//         stream: player.playerStateStream,
//         builder: (context, snapshot) {
//           final playerState = snapshot.data;
//           final processingState = playerState?.processingState;
//           final playing = playerState?.playing;
//           if (processingState == ProcessingState.loading ||
//               processingState == ProcessingState.buffering) {
//             return Container(
//               margin: EdgeInsets.all(8.0),
//               width: 64.0,
//               height: 64.0,
//               child: CircularProgressIndicator(),
//             );
//           } else {
//             return IconButton(
//               icon: Icon(Icons.skip_previous),
//               iconSize: 64.0,
//               onPressed: () async{
//                 if (player.hasPrevious) {
//                   await player.seekToPrevious();
//                 }
//               },
//             );
//           }
//         },
//       ),

//       /// This StreamBuilder rebuilds whenever the player state changes, which
//       /// includes the playing/paused state and also the
//       /// loading/buffering/ready state. Depending on the state we show the
//       /// appropriate button or loading indicator.
//       StreamBuilder<PlayerState>(
//         stream: player.playerStateStream,
//         builder: (context, snapshot) {
//           final playerState = snapshot.data;
//           final processingState = playerState?.processingState;
//           final playing = playerState?.playing;
//           if (processingState == ProcessingState.loading ||
//               processingState == ProcessingState.buffering) {
//             return Container(
//               margin: EdgeInsets.all(8.0),
//               width: 64.0,
//               height: 64.0,
//               child: CircularProgressIndicator(),
//             );
//           } else if (playing != true) {
//             return IconButton(
//               icon: Icon(Icons.play_arrow),
//               iconSize: 64.0,
//               onPressed: player.play,
//             );
//           } else if (processingState != ProcessingState.completed) {
//             return IconButton(
//               icon: Icon(Icons.pause),
//               iconSize: 64.0,
//               onPressed: player.pause,
//             );
//           } else {
//             return IconButton(
//               icon: Icon(Icons.replay),
//               iconSize: 64.0,
//               onPressed: () => player.seek(Duration.zero),
//             );
//           }
//         },
//       ),

//       ///
//       StreamBuilder<PlayerState>(
//         stream: player.playerStateStream,
//         builder: (context, snapshot) {
//           final playerState = snapshot.data;
//           final processingState = playerState?.processingState;
//           final playing = playerState?.playing;
//           if (processingState == ProcessingState.loading ||
//               processingState == ProcessingState.buffering) {
//             return Container(
//               margin: EdgeInsets.all(8.0),
//               width: 64.0,
//               height: 64.0,
//               child: CircularProgressIndicator(),
//             );
//           } else {
//             return IconButton(
//               icon: Icon(Icons.skip_next),
//               iconSize: 64.0,
//               onPressed: ()async {
//                 //  if (player.hasNext) {
//                 //   await player.seekToNext();

//                 // }
//               },
//             );
//           }
//         },
//       ),

//       ///
//       // Opens speed slider dialog
//       StreamBuilder<double>(
//         stream: player.speedStream,
//         builder: (context, snapshot) => IconButton(
//           icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           onPressed: () {
//             showSliderDialog(
//               context: context,
//               title: "Adjust speed",
//               divisions: 10,
//               min: 0.5,
//               max: 1.5,
//               value: player.speed,
//               stream: player.speedStream,
//               onChanged: player.setSpeed,
//             );
//           },
//         ),
//       ),

//     ],
//   );
// }
