import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/player.dart';
import 'components/enemy.dart';
import 'components/terrain.dart';
import 'components/fuel_depot.dart';

class RiverRaidGame extends FlameGame
    with KeyboardEvents, TapDetector, HasCollisionDetection {
  late Player player;
  final Random random = Random();
  
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> fuelNotifier = ValueNotifier<double>(100);
  final ValueNotifier<bool> gameOverNotifier = ValueNotifier<bool>(false);
  
  double gameSpeed = 100;
  double enemySpawnTimer = 0;
  double fuelDepotSpawnTimer = 0;
  double terrainSpawnTimer = 0;
  
  static const double enemySpawnInterval = 2.0;
  static const double fuelDepotSpawnInterval = 8.0;
  static const double terrainSpawnInterval = 0.3;
  
  bool _isGameOver = false;
  
  @override
  Color backgroundColor() => const Color(0xFF1565C0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add player
    player = Player()
      ..position = Vector2(size.x / 2, size.y * 0.8)
      ..priority = 10;
    add(player);
    
    // Initial terrain
    for (int i = 0; i < 10; i++) {
      _spawnTerrain();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_isGameOver) return;
    
    // Update fuel
    player.fuel -= dt * 5; // Fuel consumption
    fuelNotifier.value = player.fuel;
    
    if (player.fuel <= 0) {
      gameOver();
      return;
    }
    
    // Spawn enemies
    enemySpawnTimer += dt;
    if (enemySpawnTimer >= enemySpawnInterval) {
      enemySpawnTimer = 0;
      _spawnEnemy();
    }
    
    // Spawn fuel depots
    fuelDepotSpawnTimer += dt;
    if (fuelDepotSpawnTimer >= fuelDepotSpawnInterval) {
      fuelDepotSpawnTimer = 0;
      _spawnFuelDepot();
    }
    
    // Spawn terrain
    terrainSpawnTimer += dt;
    if (terrainSpawnTimer >= terrainSpawnInterval) {
      terrainSpawnTimer = 0;
      _spawnTerrain();
    }
    
    // Increase difficulty over time
    gameSpeed += dt * 2;
  }

  void _spawnEnemy() {
    final leftSide = random.nextBool();
    final x = leftSide ? size.x * 0.2 : size.x * 0.8;
    
    final enemy = Enemy(gameSpeed: gameSpeed)
      ..position = Vector2(x, -50);
    add(enemy);
  }

  void _spawnFuelDepot() {
    final x = size.x * (0.3 + random.nextDouble() * 0.4);
    
    final fuelDepot = FuelDepot(gameSpeed: gameSpeed)
      ..position = Vector2(x, -50);
    add(fuelDepot);
  }

  void _spawnTerrain() {
    // Left terrain
    final leftWidth = 50.0 + random.nextDouble() * 50;
    final leftTerrain = Terrain(
      width: leftWidth,
      gameSpeed: gameSpeed,
      isLeft: true,
    )..position = Vector2(0, -50);
    add(leftTerrain);
    
    // Right terrain
    final rightWidth = 50.0 + random.nextDouble() * 50;
    final rightTerrain = Terrain(
      width: rightWidth,
      gameSpeed: gameSpeed,
      isLeft: false,
    )..position = Vector2(size.x - rightWidth, -50);
    add(rightTerrain);
  }

  void addScore(int points) {
    scoreNotifier.value += points;
  }

  void refuel(double amount) {
    player.fuel = (player.fuel + amount).clamp(0, 100);
    fuelNotifier.value = player.fuel;
  }

  void gameOver() {
    if (_isGameOver) return;
    _isGameOver = true;
    gameOverNotifier.value = true;
    pauseEngine();
  }

  void reset() {
    _isGameOver = false;
    gameOverNotifier.value = false;
    scoreNotifier.value = 0;
    player.fuel = 100;
    fuelNotifier.value = 100;
    gameSpeed = 100;
    enemySpawnTimer = 0;
    fuelDepotSpawnTimer = 0;
    terrainSpawnTimer = 0;
    
    // Remove all game objects except player
    for (final enemy in children.whereType<Enemy>()) {
      enemy.removeFromParent();
    }
    for (final fuelDepot in children.whereType<FuelDepot>()) {
      fuelDepot.removeFromParent();
    }
    for (final terrain in children.whereType<Terrain>()) {
      terrain.removeFromParent();
    }
    
    // Reset player position
    player.position = Vector2(size.x / 2, size.y * 0.8);
    
    resumeEngine();
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (_isGameOver) return KeyEventResult.ignored;
    
    final isLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);
    
    player.moveLeft = isLeft;
    player.moveRight = isRight;
    
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      player.shoot();
    }
    
    return KeyEventResult.handled;
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (_isGameOver) return;
    
    final touchX = info.eventPosition.global.x;
    final playerX = player.position.x;
    
    if (touchX < playerX - 20) {
      player.moveLeft = true;
      player.moveRight = false;
    } else if (touchX > playerX + 20) {
      player.moveRight = true;
      player.moveLeft = false;
    }
    
    player.shoot();
  }

  @override
  void onTapUp(TapUpInfo info) {
    player.moveLeft = false;
    player.moveRight = false;
  }

  @override
  void onTapCancel() {
    player.moveLeft = false;
    player.moveRight = false;
  }
}
