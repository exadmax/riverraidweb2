import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../river_raid_game.dart';
import 'bullet.dart';
import 'enemy.dart';
import 'fuel_depot.dart';
import 'terrain.dart';
import 'bridge.dart';

class Player extends PositionComponent
    with HasGameRef<RiverRaidGame>, CollisionCallbacks {
  static const double speed = 300.0;
  static const double playerSize = 40.0;
  
  double fuel = 100.0;
  bool moveLeft = false;
  bool moveRight = false;
  bool moveUp = false;
  bool moveDown = false;
  
  double shootCooldown = 0;
  static const double shootInterval = 0.2;
  
  final Paint _paint = Paint()..color = Colors.green;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    width = playerSize;
    height = playerSize;
    anchor = Anchor.center;
    
    // Add collision detection
    add(RectangleHitbox(size: Vector2(playerSize, playerSize)));
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
    if (moveUp) {
      position.y -= speed * dt;
    }
    if (moveDown) {
      position.y += speed * dt;
    }
    
    // Keep player within bounds
    position.x = position.x.clamp(
      playerSize / 2,
      gameRef.size.x - playerSize / 2,
    );
    position.y = position.y.clamp(
      playerSize / 2,
      gameRef.size.y - playerSize / 2,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw player as a triangle (jet)
    final path = Path()
      ..moveTo(0, -playerSize / 2) // Top point
      ..lineTo(-playerSize / 3, playerSize / 2) // Bottom left
      ..lineTo(playerSize / 3, playerSize / 2) // Bottom right
      ..close();
    
    canvas.drawPath(path, _paint);
    
    // Draw wings
    final wingPaint = Paint()..color = Colors.lightGreen;
    canvas.drawCircle(Offset(-playerSize / 3, 0), playerSize / 6, wingPaint);
    canvas.drawCircle(Offset(playerSize / 3, 0), playerSize / 6, wingPaint);
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
    
    if (other is Enemy ||
        other is FuelDepot ||
        other is Terrain ||
        other is Bridge) {
      gameRef.handlePlayerCollision(other);
    }
  }
}
