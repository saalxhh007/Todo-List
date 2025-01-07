import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

class Pomodoro extends StatefulWidget {
  const Pomodoro({super.key});

  @override
  State<Pomodoro> createState() => _PomodoroState();
}

class _PomodoroState extends State<Pomodoro> {
  late Timer _timer;
  int _timeInSecondsPomodoro = 25 * 60;
  final int _totalTimeInSecondsPomodoro = 25 * 60;
  int _timeInSecondsBreak = 5 * 60;
  final int _totalTimeInSecondsBreak = 5 * 60;
  bool _isRunning = false;
  String _selectedButton = '';

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
      });

      if (_selectedButton == "Pomodoro") {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_timeInSecondsPomodoro > 0) {
            setState(() {
              _timeInSecondsPomodoro--;
            });
          } else {
            _stopTimer();
          }
        });
      } else if (_selectedButton == "Break") {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_timeInSecondsBreak > 0) {
            setState(() {
              _timeInSecondsBreak--;
            });
          } else {
            _stopTimer();
          }
        });
      }
    }
  }

  void _stopTimer() {
    if (_isRunning) {
      _timer.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      if (_selectedButton == "Break") {
        _timeInSecondsBreak = _totalTimeInSecondsBreak;
      } else {
        _timeInSecondsPomodoro = _totalTimeInSecondsPomodoro;
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onButtonClick(String buttonName) {
    setState(() {
      _selectedButton = buttonName;
    });
  }

  @override
  void dispose() {
    if (_isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/night.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: GestureDetector(
                        onTap: () => _onButtonClick("Pomodoro"),
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: _selectedButton == "Pomodoro"
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Pomodoro',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: GestureDetector(
                        onTap: () => _onButtonClick("Break"),
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: _selectedButton == "Break"
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Short Break',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _selectedButton == "Pomodoro"
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: 220,
                        ),
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _formatTime(_timeInSecondsPomodoro),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: 220,
                        ),
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _formatTime(_timeInSecondsBreak),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 48, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: !_isRunning ? _startTimer : null,
                    child: const Text('Start'),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      elevation: MaterialStateProperty.all(0),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _isRunning ? _stopTimer : null,
                    child: const Text(
                      'End',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      elevation: MaterialStateProperty.all(0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _resetTimer,
                    child: const Text('Reset'),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      elevation: MaterialStateProperty.all(0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CountDownPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  CountDownPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    final Paint foregroundPaint = Paint()
      ..color = color
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;

    canvas.drawCircle(center, radius, backgroundPaint);

    final angle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
