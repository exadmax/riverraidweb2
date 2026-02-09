import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../river_raid_game.dart';

class FuelDepot extends PositionComponent
    with HasGameRef<RiverRaidGame>, CollisionCallbacks {
  final double gameSpeed;
  static const double width = 60.0;
  static const double height = 40.0;
  
  final Paint _paint = Paint()..color = Colors.orange;
  final Paint _stripePaint = Paint()..color = Colors.black;
  
  FuelDepot({required this.gameSpeed});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(width, height);
    anchor = Anchor.center;
    
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
    
    // Draw fuel depot as rectangle with stripes
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      _paint,
    );
    
    // Draw diagonal stripes
    _stripePaint.strokeWidth = 2;
    for (double i = -width; i < width; i += 10) {
      canvas.drawLine(
        Offset(i, -height / 2),
        Offset(i + height, height / 2),
        _stripePaint,
      );
    }
    
    // Draw "F" for fuel
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'F',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
}
