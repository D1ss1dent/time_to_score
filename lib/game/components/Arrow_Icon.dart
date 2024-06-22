import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_to_score/game/components/Player.dart';

class ArrowIcon {
  double xPos;
  double yPos;
  double size;
  double angle;
  Player spaceship;
  double distanceFromCenter;

  ArrowIcon(
      {required this.xPos,
      required this.yPos,
      required this.size,
      required this.spaceship,
      this.distanceFromCenter = 40})
      : angle = spaceship.direction;

  void update() {
    xPos = spaceship.xPos;
    yPos = spaceship.yPos;
    angle = spaceship.direction;
  }

  void draw(Canvas canvas) {
    final double arrowLength = spaceship.size / 2 + distanceFromCenter;
    final double arrowX =
        spaceship.xPos + arrowLength * cos(spaceship.direction);
    final double arrowY =
        spaceship.yPos + arrowLength * sin(spaceship.direction);

    xPos = arrowX;
    yPos = arrowY;
    angle = spaceship.direction;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(arrowX, arrowY);
    canvas.rotate(angle);
    canvas.drawPath(getArrowPath(arrowLength), paint);
    canvas.restore();
  }

  Path getArrowPath(double length) {
    final double halfWidth = size / 2;
    return Path()
      ..moveTo(0, -halfWidth)
      ..lineTo(length, 0)
      ..lineTo(0, halfWidth)
      ..close();
  }
}
