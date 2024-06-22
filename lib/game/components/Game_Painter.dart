import 'package:flutter/material.dart';
import 'package:time_to_score/game/components/Arrow_Icon.dart';
import 'package:time_to_score/game/components/Ball.dart';
import 'package:time_to_score/game/components/Gate.dart';
import 'package:time_to_score/game/components/Player.dart';

class GamePainter extends CustomPainter {
  final Player spaceship;
  final ArrowIcon arrowIcon;
  final List<Ball> balls;
  final Gate gate;

  GamePainter({
    required this.spaceship,
    required this.arrowIcon,
    required this.balls,
    required this.gate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    spaceship.draw(canvas, size);
    arrowIcon.draw(canvas);

    for (var ball in balls) {
      ball.draw(canvas);
    }

    gate.draw(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
