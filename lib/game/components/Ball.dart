import 'dart:ui' as ui;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Ball {
  double xPos;
  double yPos;
  double size;
  double speed;
  double direction;
  ui.Image? _ballImage;

  Ball({
    required this.xPos,
    required this.yPos,
    required this.size,
    required this.speed,
    required this.direction,
  }) {
    _loadImage('assets/ball.png');
  }

  Future<void> _loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    _ballImage = await decodeImageFromList(bytes);
  }

  void draw(Canvas canvas) {
    if (_ballImage != null) {
      final Rect imageRect = Rect.fromPoints(
        Offset(xPos - size / 2, yPos - size / 2),
        Offset(xPos + size / 2, yPos + size / 2),
      );
      canvas.drawImageRect(
        _ballImage!,
        Rect.fromPoints(
          const Offset(0, 0),
          Offset(
            _ballImage!.width.toDouble(),
            _ballImage!.height.toDouble(),
          ),
        ),
        imageRect,
        Paint(),
      );
    }
  }

  void update(double time, Size screenSize) {
    xPos += cos(direction) * speed * time;
    yPos += sin(direction) * speed * time;

    if (xPos < 0 ||
        xPos > screenSize.width ||
        yPos < 0 ||
        yPos > screenSize.height) {
      isOutOfBounds = true;
    }
  }

  bool isOutOfBounds = false;
}
