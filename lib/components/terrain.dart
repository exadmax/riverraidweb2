import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../river_raid_game.dart';
import 'bullet.dart';

class Terrain extends PositionComponent
    with HasGameRef<RiverRaidGame>, CollisionCallbacks {
  final double width;
  final double gameSpeed;
  final bool isLeft;
  
  static const double height = 100.0;
  
  late final Paint _paint;
  
  Terrain({
    required this.width,
    required this.gameSpeed,
    required this.isLeft,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(width, height);
    anchor = Anchor.topLeft;
    
    // Different colors for variety
    _paint = Paint()..color = const Color(0xFF2E7D32);
    
    // Add collision detection
    add(RectangleHitbox(size: Vector2(width, height)));
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
    
    // Draw terrain as rectangle
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      _paint,
    );
    
    // Add some texture with darker lines
    final texturePaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..strokeWidth = 2;
    
    for (double y = 0; y < height; y += 20) {
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        texturePaint,
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
      // Bullets don't destroy terrain
      other.removeFromParent();
    }
  }
}
