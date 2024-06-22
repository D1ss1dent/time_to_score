import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_to_score/game/components/Game_Object.dart';

class Player extends GameObject {
  ui.Image? _spaceshipImage;
  bool _canCreateBall;

  Player(
    double xPos,
    double yPos,
    double size,
    double speed,
    double direction,
    this._canCreateBall,
  ) : super(
          xPos: xPos,
          yPos: yPos,
          size: size,
          speed: speed + 5,
          direction: direction,
        ) {
    _loadImage();
  }

  Future<void> _loadImage() async {
    final assetPath =
        _canCreateBall ? 'assets/object.png' : 'assets/object2.png';
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    _spaceshipImage = await decodeImageFromList(bytes);
  }

  void setCanCreateBall(bool canCreateBall) {
    _canCreateBall = canCreateBall;
    _loadImage();
  }

  void reset(Size screenSize) {
    xPos = screenSize.width / 2;
    yPos = screenSize.height / 2;
  }

  void updatePlayerImage(bool canCreateBall) {
    _canCreateBall = canCreateBall;
    _loadImage();
  }

  void draw(Canvas canvas, Size size) {
    if (_spaceshipImage != null) {
      const double imageSize = 140.0;
      final Rect imageRect = Rect.fromPoints(
        Offset(xPos - imageSize / 2, yPos - imageSize / 2),
        Offset(xPos + imageSize / 2, yPos + imageSize / 2),
      );
      canvas.drawImageRect(
        _spaceshipImage!,
        Rect.fromPoints(
          const Offset(0, 0),
          Offset(
            _spaceshipImage!.width.toDouble(),
            _spaceshipImage!.height.toDouble(),
          ),
        ),
        imageRect,
        Paint(),
      );
    }
  }
}
