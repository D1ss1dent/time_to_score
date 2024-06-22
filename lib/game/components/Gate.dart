import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Gate {
  double xPos;
  double yPos;
  double size;
  ui.Image? _gateImage;
  bool shouldMove = false;

  Gate({required this.xPos, required this.yPos, required this.size}) {
    _loadImage('assets/gate.png');
    shouldMove = true;
  }

  Future<void> _loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    _gateImage = await decodeImageFromList(bytes);
  }

  void draw(Canvas canvas) {
    if (_gateImage != null) {
      final Rect imageRect = Rect.fromPoints(
        Offset(xPos - size / 2, yPos - size / 2),
        Offset(xPos + size / 2, yPos + size / 2),
      );
      canvas.drawImageRect(
        _gateImage!,
        Rect.fromPoints(
          const Offset(0, 0),
          Offset(
            _gateImage!.width.toDouble(),
            _gateImage!.height.toDouble(),
          ),
        ),
        imageRect,
        Paint(),
      );
    }
  }

  void relocate(Size screenSize) {
    final Random random = Random();
    xPos = random.nextDouble() * (screenSize.width - 50);
    yPos = random.nextDouble() * (screenSize.height - 50);
    shouldMove = false;
  }

  void resetMoveFlag() {
    shouldMove = false;
  }
}
