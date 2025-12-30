import 'package:flutter/material.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  TextEditingController _youtubeLinkController = TextEditingController();
  int _playMinutes = 5;
  int _breakMinutes = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Parent Setup')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _youtubeLinkController,
              decoration: InputDecoration(labelText: 'YouTube Link'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Play duration (min): '),
                Expanded(
                  child: Slider(
                    min: 1,
                    max: 60,
                    divisions: 59,
                    value: _playMinutes.toDouble(),
                    onChanged: (val) => setState(() => _playMinutes = val.toInt()),
                  ),
                ),
                Text('$_playMinutes')
              ],
            ),
            Row(
              children: [
                Text('Break test duration (min): '),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 10,
                    divisions: 10,
                    value: _breakMinutes.toDouble(),
                    onChanged: (val) => setState(() => _breakMinutes = val.toInt()),
                  ),
                ),
                Text('$_breakMinutes')
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              child: Text('Start Session'),
              onPressed: () {
                Navigator.pushNamed(context, '/child', arguments: {
                  'youtube': _youtubeLinkController.text,
                  'playMinutes': _playMinutes,
                  'breakMinutes': _breakMinutes,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
