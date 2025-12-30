import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';

class ChildPlayer extends StatefulWidget {
  @override
  State<ChildPlayer> createState() => _ChildPlayerState();
}

class _ChildPlayerState extends State<ChildPlayer> {
  late YoutubePlayerController _controller;
  Timer? _timer;
  int _elapsedSeconds = 0;
  late int playDurationSeconds;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments passed from parent
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final youtubeUrl = args['youtube'] as String;
    playDurationSeconds = (args['playMinutes'] as int) * 60;

    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
    if (videoId == null) {
      print("Invalid YouTube URL");
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        controlsVisibleAtStart: true,
      ),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;

      if (_elapsedSeconds >= playDurationSeconds) {
        _timer?.cancel();
        _controller.pause();

        // Navigate to break screen
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => BreakScreen()));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: player),
        );
      },
    );
  }
}

// Simple break screen
class BreakScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      body: Center(
        child: Text(
          "Break Time!",
          style: TextStyle(fontSize: 32, color: Colors.white),
        ),
      ),
    );
  }
}
