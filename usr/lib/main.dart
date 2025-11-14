import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touch Typing Practice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF282C34),
      ),
      home: const TypingPage(),
    );
  }
}

class TypingPage extends StatefulWidget {
  const TypingPage({super.key});

  @override
  State<TypingPage> createState() => _TypingPageState();
}

class _TypingPageState extends State<TypingPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  String _textToType = "the quick brown fox jumps over the lazy dog";
  int _currentCharIndex = 0;
  DateTime? _startTime;
  double _wpm = 0.0;
  double _accuracy = 100.0;
  int _correctChars = 0;
  int _totalTypedChars = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (_startTime == null && value.isNotEmpty) {
      setState(() {
        _startTime = DateTime.now();
      });
    }

    if (value.length > _textToType.length) {
        // User has typed more than the text available
        return;
    }

    setState(() {
      _totalTypedChars = value.length;
      _correctChars = 0;
      for (int i = 0; i < value.length; i++) {
        if (value[i] == _textToType[i]) {
          _correctChars++;
        }
      }
      _currentCharIndex = value.length;

      if (_startTime != null) {
        final duration = DateTime.now().difference(_startTime!);
        if (duration.inSeconds > 0) {
          // WPM calculation: (characters typed / 5) / minutes
          _wpm = (_currentCharIndex / 5) / (duration.inMinutes + (duration.inSeconds / 60));
        }
      }

      if (_totalTypedChars > 0) {
        _accuracy = (_correctChars / _totalTypedChars) * 100;
      } else {
        _accuracy = 100.0;
      }

      if (_currentCharIndex == _textToType.length) {
        // Finished
        _showResultDialog();
      }
    });
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _currentCharIndex = 0;
      _startTime = null;
      _wpm = 0.0;
      _accuracy = 100.0;
      _correctChars = 0;
      _totalTypedChars = 0;
      // For now, we use the same text. We can add more texts later.
      _focusNode.requestFocus();
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: Text(
              "You completed the test.\n\nWPM: ${_wpm.toStringAsFixed(2)}\nAccuracy: ${_accuracy.toStringAsFixed(2)}%"),
          actions: <Widget>[
            TextButton(
              child: const Text("Try Again"),
              onPressed: () {
                Navigator.of(context).pop();
                _reset();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Touch Typing Practice'),
        backgroundColor: const Color(0xFF21252B),
      ),
      body: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21252B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 24, fontFamily: 'monospace'),
                      children: _buildTextSpans(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Opacity(
                  opacity: 0.0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _onTextChanged,
                    autofocus: true,
                    enableSuggestions: false,
                    autocorrect: false,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildStat("WPM", _wpm.toStringAsFixed(2)),
                    _buildStat("Accuracy", "${_accuracy.toStringAsFixed(2)}%"),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildTextSpans() {
    List<TextSpan> spans = [];
    for (int i = 0; i < _textToType.length; i++) {
      Color color = Colors.grey;
      TextDecoration? decoration;

      if (i < _currentCharIndex) {
        if (_controller.text[i] == _textToType[i]) {
          color = Colors.green;
        } else {
          color = Colors.red;
          decoration = TextDecoration.underline;
        }
      }
      
      if (i == _currentCharIndex) {
          decoration = TextDecoration.underline;
          color = Colors.yellow;
      }

      spans.add(
        TextSpan(
          text: _textToType[i],
          style: TextStyle(
            color: color,
            decoration: decoration,
            decorationColor: Colors.yellow,
            decorationThickness: 2,
          ),
        ),
      );
    }
    return spans;
  }

  Widget _buildStat(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}
