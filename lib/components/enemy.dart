import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../river_raid_game.dart';
import 'bullet.dart';

class Enemy extends PositionComponent
    with HasGameRef<RiverRaidGame>, CollisionCallbacks {
  final double gameSpeed;
  static const double size = 35.0;
  
  final Paint _paint = Paint()..color = Colors.red;
  
  Enemy({required this.gameSpeed});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    width = size;
    height = size;
    anchor = Anchor.center;
    
    // Add collision detection
    add(RectangleHitbox(size: Vector2(size, size)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move down
    position.y += gameSpeed * dt;
    
    // Remove if off screen
    if (position.y > gameRef.size.y + 100) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw enemy as a square with cross
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size, height: size),
      _paint,
    );
    
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    
    canvas.drawLine(
      Offset(-size / 3, -size / 3),
      Offset(size / 3, size / 3),
      crossPaint,
    );
    canvas.drawLine(
      Offset(size / 3, -size / 3),
      Offset(-size / 3, size / 3),
      crossPaint,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Bullet) {
      // Destroyed by bullet
      gameRef.addScore(100);
      other.removeFromParent();
      removeFromParent();
    }
  }
}
