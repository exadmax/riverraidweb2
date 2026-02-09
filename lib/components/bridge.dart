import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../river_raid_game.dart';
import 'bullet.dart';

class Bridge extends PositionComponent
    with HasGameRef<RiverRaidGame>, CollisionCallbacks {
  final double gameSpeed;
  final double width;
  static const double bridgeHeight = 26.0;

  final Paint _bridgePaint = Paint()..color = const Color(0xFF6D4C41);
  final Paint _railPaint = Paint()..color = const Color(0xFF3E2723);

  Bridge({required this.gameSpeed, required this.width});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(width, bridgeHeight);
    anchor = Anchor.topLeft;

    add(RectangleHitbox(size: Vector2(width, bridgeHeight)));
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += gameSpeed * dt;

    if (position.y > gameRef.size.y + 100) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, bridgeHeight),
      _bridgePaint,
    );

    _railPaint.strokeWidth = 3;
    canvas.drawLine(
      const Offset(0, 4),
      Offset(width, 4),
      _railPaint,
    );
    canvas.drawLine(
      Offset(0, bridgeHeight - 4),
      Offset(width, bridgeHeight - 4),
      _railPaint,
    );

    for (double x = 10; x < width; x += 16) {
      canvas.drawLine(
        Offset(x, 4),
        Offset(x, bridgeHeight - 4),
        _railPaint,
      );
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      gameRef.addScore(500);
      other.removeFromParent();
      removeFromParent();
    }
  }
}
