import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_to_score/game/components/Arrow_Icon.dart';
import 'package:time_to_score/game/components/Ball.dart';
import 'package:time_to_score/game/components/Game_Painter.dart';
import 'package:time_to_score/game/components/Gate.dart';
import 'package:time_to_score/game/components/Player.dart';
import 'package:time_to_score/game/components/Transparent_Dialog.dart';

class GameController {
  final Player spaceship;
  late ArrowIcon arrowIcon;
  List<Ball> balls = [];
  late Gate gate;
  int goal = 0;
  int bestScore = 0;
  final Function() playGoalMusic;
  final bool isSoundOn2;
  double initialPlayerSpeed;
  bool canCreateBall = true;

  SharedPreferences? _prefs;

  GameController({
    required this.spaceship,
    required this.playGoalMusic,
    required this.isSoundOn2,
    required this.initialPlayerSpeed,
  }) {
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      _loadBestScore();
    });

    arrowIcon = ArrowIcon(
      xPos: spaceship.xPos,
      yPos: spaceship.yPos,
      size: 20,
      spaceship: spaceship,
    );

    gate = Gate(
      xPos: 0,
      yPos: 0,
      size: 130,
    );
    gate.relocate(const Size(500, 500));
  }

  void _loadBestScore() {
    if (_prefs != null && _prefs!.containsKey('bestScore')) {
      bestScore = _prefs!.getInt('bestScore') ?? 0;
      goal = 0;
    }
  }

  void restartGame(Size screenSize) {
    goal = 0;
    spaceship.reset(screenSize);
    spaceship.speed = initialPlayerSpeed;
    balls.clear();
    gate.relocate(screenSize);
  }

  Future<void> _saveBestScore() async {
    if (_prefs != null) {
      final currentBestScore = _prefs!.getInt('bestScore') ?? 0;
      if (goal > currentBestScore) {
        await _prefs!.setInt('bestScore', goal);
        bestScore = goal;
        print('Best score saved: $goal');
      }
    }
  }

  void update(double time, Size screenSize) {
    spaceship.update(time, screenSize);
    arrowIcon.update();

    List<Ball> ballsToRemove = [];

    for (var ball in balls) {
      ball.update(time, screenSize);

      if (ball.isOutOfBounds) {
        gate.resetMoveFlag();
      }

      if (ball.xPos > gate.xPos - gate.size / 2 &&
          ball.xPos < gate.xPos + gate.size / 2 &&
          ball.yPos > gate.yPos - gate.size / 2 &&
          ball.yPos < gate.yPos + gate.size / 2) {
        gate.relocate(screenSize);
        ballsToRemove.add(ball);
        goal++;
        if (isSoundOn2) {
          playGoalMusic();
        }
        if (goal > bestScore) {
          bestScore = goal;
          _saveBestScore();
        }
      }
    }

    balls.removeWhere((ball) => ballsToRemove.contains(ball));
  }

  void addBall() {
    final double ballX = spaceship.xPos;
    final double ballY = spaceship.yPos;
    const double ballSize = 25;
    const double ballSpeed = 500;
    final double ballDirection = spaceship.direction;
    final ball = Ball(
      xPos: ballX,
      yPos: ballY,
      size: ballSize,
      speed: ballSpeed,
      direction: ballDirection,
    );
    balls.add(ball);
  }
}

class GameWidget extends StatefulWidget {
  final GameController gameController;
  final bool isSoundOn2;

  GameWidget({required this.gameController, required this.isSoundOn2});

  @override
  State<StatefulWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  late Timer _timer;
  bool _isPaused = false;
  bool _showLoadingScreen = true;
  AudioPlayer audioPlayer2 = AudioPlayer();
  AudioPlayer audioPlayer3 = AudioPlayer();
  bool _canCreateBall = true;

  @override
  void initState() {
    super.initState();
    widget.gameController._loadBestScore();

    Future.delayed(const Duration(seconds: 6), () {
      setState(() {
        _showLoadingScreen = false;
      });
    });

    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (!_isPaused && !_showLoadingScreen) {
        final screenSize = MediaQuery.of(context).size;
        setState(() {
          widget.gameController.update(0.02, screenSize);
        });
      }
    });
  }

  void _createBall() {
    if (_canCreateBall) {
      widget.gameController.addBall();
      if (widget.isSoundOn2) {
        _playIterationMusic();
      }
      updateCanCreateBall(false);
      Timer(const Duration(seconds: 5), () {
        updateCanCreateBall(true);
      });
    }
  }

  void updateCanCreateBall(bool canCreateBall) {
    setState(() {
      _canCreateBall = canCreateBall;
      widget.gameController.spaceship.updatePlayerImage(canCreateBall);
    });
  }

  void _playIterationMusic() async {
    await audioPlayer2.play(AssetSource('interaction.wav'));
    audioPlayer2.setReleaseMode(ReleaseMode.release);
  }

  void _playGoalMusic() async {
    await audioPlayer2.play(AssetSource('goal.wav'));
    audioPlayer2.setReleaseMode(ReleaseMode.release);
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer2.stop();
    audioPlayer2.dispose();
    audioPlayer3.stop();
    audioPlayer3.dispose();
    _timer.cancel();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _showPauseMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: TransparentDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 400,
                  height: 150,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/button2.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Text(
                      "Game Paused",
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  height: 110,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/button2.png'),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.gameController
                          .restartGame(MediaQuery.of(context).size);
                      _togglePause();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Center(
                      child: Text(
                        "Restart",
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  height: 110,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/button2.png'),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                      _togglePause();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Center(
                      child: Text(
                        "Resume",
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  height: 110,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/button2.png'),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Center(
                      child: Text(
                        "Exit",
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        _createBall();
      },
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            if (!_showLoadingScreen)
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            CustomPaint(
              size: screenSize,
              painter: GamePainter(
                spaceship: widget.gameController.spaceship,
                arrowIcon: widget.gameController.arrowIcon,
                balls: widget.gameController.balls,
                gate: widget.gameController.gate,
              ),
            ),
            if (_showLoadingScreen) _buildLoadingScreen(),
            _buildControls(),
            _buildPauseButton(),
            _buildGoalDisplay(),
            _buildBestScoreDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalDisplay() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Goal: ${widget.gameController.goal}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildBestScoreDisplay() {
    return Positioned(
      top: 60,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Best: ${widget.gameController.bestScore}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900]?.withOpacity(0.4),
              ),
              onPressed: () {
                setState(() {
                  widget.gameController.spaceship.rotate(-pi / 18);
                });
              },
              child: const Text(
                'Left',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900]?.withOpacity(0.4),
              ),
              onPressed: () {
                setState(() {
                  widget.gameController.spaceship.rotate(pi / 18);
                });
              },
              child: const Text(
                'Right',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900]?.withOpacity(0.4),
              ),
              onPressed: () {
                setState(() {
                  widget.gameController.spaceship.changeSpeed(-10);
                });
              },
              child: const Text(
                'Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900]?.withOpacity(0.4),
              ),
              onPressed: () {
                setState(() {
                  widget.gameController.spaceship.changeSpeed(10);
                });
              },
              child: const Text(
                'Forward',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {
          _togglePause();
          if (_isPaused) {
            _showPauseMenu(context);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            color: _isPaused ? Colors.green : Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 5.0,
                spreadRadius: 1.0,
                offset: const Offset(0.0, 2.0),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              _isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
              size: 40.0,
            ),
          ),
        ),
      ),
    );
  }
}
