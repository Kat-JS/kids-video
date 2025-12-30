import 'package:flutter/material.dart';
import 'dart:async';

class BreakScreen extends StatefulWidget {
  @override
  _BreakScreenState createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> {
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _secondsLeft = args['breakDuration'];
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
      });
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        Navigator.pop(context); // 返回 YouTube
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Break Time: $_secondsLeft s', style: TextStyle(fontSize: 32)),
      ),
    );
  }
}
