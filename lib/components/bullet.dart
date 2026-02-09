import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../river_raid_game.dart';

class Bullet extends PositionComponent with HasGameRef<RiverRaidGame>, CollisionCallbacks {
  static const double speed = 500.0;
  static const double bulletWidth = 4.0;
  static const double bulletHeight = 15.0;
  
  final Paint _paint = Paint()..color = Colors.yellow;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(bulletWidth, bulletHeight);
    anchor = Anchor.center;
    
    // Add collision detection
    add(RectangleHitbox(size: Vector2(bulletWidth, bulletHeight)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move up
    position.y -= speed * dt;
    
    // Remove if off screen
    if (position.y < -50) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: bulletWidth,
        height: bulletHeight,
      ),
      _paint,
    );
  }
}
