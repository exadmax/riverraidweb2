import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../river_raid_game.dart';
import 'bullet.dart';
import 'enemy.dart';
import 'fuel_depot.dart';
import 'terrain.dart';

class Player extends PositionComponent
    with HasGameRef<RiverRaidGame>, CollisionCallbacks {
  static const double speed = 300.0;
  static const double size = 40.0;
  
  double fuel = 100.0;
  bool moveLeft = false;
  bool moveRight = false;
  
  double shootCooldown = 0;
  static const double shootInterval = 0.2;
  
  final Paint _paint = Paint()..color = Colors.green;
  
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
    
    // Update cooldown
    if (shootCooldown > 0) {
      shootCooldown -= dt;
    }
    
    // Handle movement
    if (moveLeft) {
      position.x -= speed * dt;
    }
    if (moveRight) {
      position.x += speed * dt;
    }
    
    // Keep player within bounds
    position.x = position.x.clamp(size / 2, gameRef.size.x - size / 2);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw player as a triangle (jet)
    final path = Path()
      ..moveTo(0, -size / 2) // Top point
      ..lineTo(-size / 3, size / 2) // Bottom left
      ..lineTo(size / 3, size / 2) // Bottom right
      ..close();
    
    canvas.drawPath(path, _paint);
    
    // Draw wings
    final wingPaint = Paint()..color = Colors.lightGreen;
    canvas.drawCircle(Offset(-size / 3, 0), size / 6, wingPaint);
    canvas.drawCircle(Offset(size / 3, 0), size / 6, wingPaint);
  }

  void shoot() {
    if (shootCooldown > 0) return;
    
    shootCooldown = shootInterval;
    
    final bullet = Bullet()
      ..position = position.clone();
    gameRef.add(bullet);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Enemy) {
      // Hit by enemy - game over
      gameRef.gameOver();
    } else if (other is FuelDepot) {
      // Refuel
      gameRef.refuel(50);
      other.removeFromParent();
    } else if (other is Terrain) {
      // Hit terrain - game over
      gameRef.gameOver();
    }
  }
}
