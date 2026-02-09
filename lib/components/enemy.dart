import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../river_raid_game.dart';
import 'bullet.dart';

enum EnemyType {
  ship,
  helicopter,
  jet,
}

class Enemy extends PositionComponent
    with HasGameRef<RiverRaidGame>, CollisionCallbacks {
  final double gameSpeed;
  final EnemyType type;
  final double enemySize;
  final int scoreValue;
  final double speedMultiplier;
  final Paint _paint;

  double _oscillationTimer = 0;
  double _baseX = 0;

  Enemy({required this.gameSpeed, required this.type})
      : enemySize = _sizeFor(type),
        scoreValue = _scoreFor(type),
        speedMultiplier = _speedFor(type),
        _paint = Paint()..color = _colorFor(type);

  factory Enemy.random({required double gameSpeed, required Random random}) {
    final type = EnemyType.values[random.nextInt(EnemyType.values.length)];
    return Enemy(gameSpeed: gameSpeed, type: type);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    width = enemySize;
    height = enemySize;
    anchor = Anchor.center;
    _baseX = position.x;
    
    // Add collision detection
    add(RectangleHitbox(size: Vector2(enemySize, enemySize)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move down
    position.y += gameSpeed * speedMultiplier * dt;

    if (type == EnemyType.helicopter) {
      _oscillationTimer += dt;
      position.x = _baseX + sin(_oscillationTimer * 3) * 20;
    }
    
    // Remove if off screen
    if (position.y > gameRef.size.y + 100) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (type) {
      case EnemyType.ship:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: enemySize,
            height: enemySize,
          ),
          _paint,
        );
        break;
      case EnemyType.helicopter:
        canvas.drawCircle(Offset.zero, enemySize / 2, _paint);
        final rotorPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(-enemySize / 2, 0),
          Offset(enemySize / 2, 0),
          rotorPaint,
        );
        break;
      case EnemyType.jet:
        final path = Path()
          ..moveTo(0, -enemySize / 2)
          ..lineTo(-enemySize / 2, enemySize / 2)
          ..lineTo(enemySize / 2, enemySize / 2)
          ..close();
        canvas.drawPath(path, _paint);
        break;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Bullet) {
      // Destroyed by bullet
      gameRef.addScore(scoreValue);
      other.removeFromParent();
      removeFromParent();
    }
  }
}

double _sizeFor(EnemyType type) {
  switch (type) {
    case EnemyType.ship:
      return 36;
    case EnemyType.helicopter:
      return 34;
    case EnemyType.jet:
      return 30;
  }
}

int _scoreFor(EnemyType type) {
  switch (type) {
    case EnemyType.ship:
      return 100;
    case EnemyType.helicopter:
      return 150;
    case EnemyType.jet:
      return 200;
  }
}

double _speedFor(EnemyType type) {
  switch (type) {
    case EnemyType.ship:
      return 1.0;
    case EnemyType.helicopter:
      return 0.9;
    case EnemyType.jet:
      return 1.3;
  }
}

Color _colorFor(EnemyType type) {
  switch (type) {
    case EnemyType.ship:
      return const Color(0xFFD32F2F);
    case EnemyType.helicopter:
      return const Color(0xFFFFA000);
    case EnemyType.jet:
      return const Color(0xFF7B1FA2);
  }
}
