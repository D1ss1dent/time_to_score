import 'dart:math';

import 'package:flutter/material.dart';

class GameObject {
  double xPos;
  double yPos;
  double size;
  double speed;
  double direction;

  GameObject(
      {required this.xPos,
      required this.yPos,
      required this.size,
      required this.speed,
      required this.direction});

  void update(double time, Size screenSize) {
    xPos += cos(direction) * speed * time;
    yPos += sin(direction) * speed * time;

    if (xPos < 0) xPos = screenSize.width;
    if (xPos > screenSize.width) xPos = 0;
    if (yPos < 0) yPos = screenSize.height;
    if (yPos > screenSize.height) yPos = 0;
  }

  void rotate(double angle) {
    direction += angle;
  }

  void changeSpeed(double amount) {
    speed += amount;
  }
}
