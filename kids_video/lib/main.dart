import 'package:flutter/material.dart';
import 'child_player.dart';

void main() {
  runApp(KidsVideoApp());
}

class KidsVideoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Video MVP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ParentSetupScreen(),
        '/child_player': (context) => ChildPlayer(),
      },
    );
  }
}

// Parent setup screen
class ParentSetupScreen extends StatefulWidget {
  @override
  State<ParentSetupScreen> createState() => _ParentSetupScreenState();
}

class _ParentSetupScreenState extends State<ParentSetupScreen> {
  final _youtubeController = TextEditingController();
  final _minutesController = TextEditingController(text: '2');

  @override
  void dispose() {
    _youtubeController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _startChildPlayer() {
    final youtubeUrl = _youtubeController.text.trim();
    final minutes = int.tryParse(_minutesController.text) ?? 2;

    if (youtubeUrl.isEmpty) return;

    Navigator.pushNamed(
      context,
      '/child_player',
      arguments: {'youtube': youtubeUrl, 'playMinutes': minutes},
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Parent Setup")),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _youtubeController,
              decoration: InputDecoration(
                labelText: "YouTube URL",
                hintText: "https://youtube.com/…",
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Play duration (minutes)",
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startChildPlayer,
              child: Text("Start"),
            ),
          ],
        ),
      ),
    ),
  );
}

}
