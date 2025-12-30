import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ChildPlayer extends StatefulWidget {
  const ChildPlayer({super.key});

  @override
  State<ChildPlayer> createState() => _ChildPlayerState();
}

class _ChildPlayerState extends State<ChildPlayer> {
  late YoutubePlayerController _controller;
  Timer? _playTimer;
  Timer? _breakTimer;

  bool _showBreak = false;
  int _remainingBreakSeconds = 0;

  late String _videoId;
  late int _playDurationSeconds;
  late int _breakDurationSeconds;

  @override
  void initState() {
    super.initState();

    // Force landscape + hide system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final youtubeUrl = args['youtube'] as String;
    final playMinutes = args['playMinutes'] as int? ?? 10;
    final breakMinutes = args['breakMinutes'] as int? ?? 2;

    _videoId = YoutubePlayerController.convertUrlToId(youtubeUrl)!;
    _playDurationSeconds = playMinutes * 60;
    _breakDurationSeconds = breakMinutes * 60;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: _videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        enableCaption: false,
        autoPlay: true,
        playsInline: true
      ),
    );

    _startPlayTimer();
  }

  // -------------------------
  // PLAY TIMER
  // -------------------------
  void _startPlayTimer() {
    _playTimer?.cancel();

    _playTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (timer.tick >= _playDurationSeconds) {
        timer.cancel();
        _startBreak();
      }
    });
  }

  // -------------------------
  // BREAK TIMER
  // -------------------------
  void _startBreak() async {
    await _pauseVideo();

    setState(() {
      _showBreak = true;
      _remainingBreakSeconds = _breakDurationSeconds;
    });

    _breakTimer?.cancel();
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _remainingBreakSeconds--;
      });

      if (_remainingBreakSeconds <= 0) {
        timer.cancel();
        _endBreak();
      }
    });
  }

  void _endBreak() async {
    setState(() {
      _showBreak = false;
    });

    await _playVideo();
    _startPlayTimer();
  }

  // -------------------------
  // Pause/Play via JS
  // -------------------------
  Future<void> _pauseVideo() async {
    await _controller.pauseVideo();
  }

  Future<void> _playVideo() async {
    await _controller.playVideo();
  }

  // -------------------------
  // TIME FORMAT
  // -------------------------
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          YoutubePlayerControllerProvider(
            controller: _controller,
            child: const YoutubePlayer(),
          ),
          if (_showBreak) _buildBreakOverlay(),
        ],
      ),
    );
  }

  Widget _buildBreakOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/break.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Container(
                color: Colors.black.withOpacity(0.5),
              ),
              Text(
                _formatTime(_remainingBreakSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // DISPOSE
  // -------------------------
  @override
  void dispose() {
    // Restore portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _playTimer?.cancel();
    _breakTimer?.cancel();
    _controller.close();
    super.dispose();
  }
}
