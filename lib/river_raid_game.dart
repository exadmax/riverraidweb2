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
import 'components/bridge.dart';
import 'components/bullet.dart';
import 'top_score_store.dart';

enum GamePhase {
  start,
  running,
  gameOver,
}

class RiverRaidGame extends FlameGame
  with KeyboardEvents, TapCallbacks, HasCollisionDetection {
  late Player player;
  final Random random = Random();
  
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> fuelNotifier = ValueNotifier<double>(100);
  final ValueNotifier<int> livesNotifier = ValueNotifier<int>(3);
  final TopScoreStore topScoreStore = TopScoreStore();
  late final ValueNotifier<int> topScoreNotifier =
      topScoreStore.topScoreNotifier;
  final ValueNotifier<GamePhase> gamePhaseNotifier =
      ValueNotifier<GamePhase>(GamePhase.start);
  
  double gameSpeed = 100;
  double enemySpawnTimer = 0;
  double fuelDepotSpawnTimer = 0;
  double terrainSpawnTimer = 0;
  double bridgeSpawnTimer = 0;
  
  static const double enemySpawnInterval = 2.0;
  static const double fuelDepotSpawnInterval = 8.0;
  static const double terrainSpawnInterval = 0.3;
  static const double bridgeSpawnInterval = 12.0;
  
  double _hitInvulnerableTimer = 0;
  int _nextLifeScore = 10000;
  
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

    pauseEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (gamePhaseNotifier.value != GamePhase.running) return;

    if (_hitInvulnerableTimer > 0) {
      _hitInvulnerableTimer = (_hitInvulnerableTimer - dt).clamp(0, 10);
    }
    
    // Update fuel
    player.fuel -= dt * 5; // Fuel consumption
    fuelNotifier.value = player.fuel;
    
    if (player.fuel <= 0) {
      _loseLife();
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

    bridgeSpawnTimer += dt;
    if (bridgeSpawnTimer >= bridgeSpawnInterval) {
      bridgeSpawnTimer = 0;
      if (random.nextDouble() > 0.4) {
        _spawnBridge();
      }
    }
    
    // Increase difficulty over time
    gameSpeed += dt * 2;
  }

  void _spawnEnemy() {
    final x = size.x * (0.2 + random.nextDouble() * 0.6);
    final enemy = Enemy.random(gameSpeed: gameSpeed, random: random)
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

  void _spawnBridge() {
    final bridge = Bridge(gameSpeed: gameSpeed, width: size.x * 0.65)
      ..position = Vector2(size.x * 0.175, -60);
    add(bridge);
  }

  void addScore(int points) {
    scoreNotifier.value += points;
    topScoreStore.registerScore(scoreNotifier.value);
    while (scoreNotifier.value >= _nextLifeScore) {
      livesNotifier.value += 1;
      _nextLifeScore += 10000;
    }
  }

  void refuel(double amount) {
    player.fuel = (player.fuel + amount).clamp(0, 100);
    fuelNotifier.value = player.fuel;
  }

  void _triggerGameOver() {
    gamePhaseNotifier.value = GamePhase.gameOver;
    pauseEngine();
  }

  void _resetObjects() {
    for (final enemy in children.whereType<Enemy>()) {
      enemy.removeFromParent();
    }
    for (final fuelDepot in children.whereType<FuelDepot>()) {
      fuelDepot.removeFromParent();
    }
    for (final terrain in children.whereType<Terrain>()) {
      terrain.removeFromParent();
    }
    for (final bridge in children.whereType<Bridge>()) {
      bridge.removeFromParent();
    }
    for (final bullet in children.whereType<Bullet>()) {
      bullet.removeFromParent();
    }
  }

  void _resetAfterHit() {
    player.fuel = 100;
    fuelNotifier.value = 100;
    player.position = Vector2(size.x / 2, size.y * 0.8);
    _resetObjects();
    for (int i = 0; i < 10; i++) {
      _spawnTerrain();
    }
  }

  void _loseLife() {
    if (gamePhaseNotifier.value != GamePhase.running) return;
    if (_hitInvulnerableTimer > 0) return;

    livesNotifier.value -= 1;
    if (livesNotifier.value <= 0) {
      _triggerGameOver();
      return;
    }

    _hitInvulnerableTimer = 1.0;
    _resetAfterHit();
  }

  void startGame() {
    if (gamePhaseNotifier.value == GamePhase.running) return;
    reset();
  }

  void reset() {
    scoreNotifier.value = 0;
    _nextLifeScore = 10000;
    livesNotifier.value = 3;
    player.fuel = 100;
    fuelNotifier.value = 100;
    gameSpeed = 100;
    enemySpawnTimer = 0;
    fuelDepotSpawnTimer = 0;
    terrainSpawnTimer = 0;
    bridgeSpawnTimer = 0;
    _hitInvulnerableTimer = 0;

    _resetObjects();

    for (int i = 0; i < 10; i++) {
      _spawnTerrain();
    }

    player.position = Vector2(size.x / 2, size.y * 0.8);

    gamePhaseNotifier.value = GamePhase.running;
    resumeEngine();
  }

  void handlePlayerCollision(PositionComponent other) {
    if (other is FuelDepot) {
      refuel(50);
      other.removeFromParent();
      return;
    }

    if (other is Enemy || other is Terrain || other is Bridge) {
      _loseLife();
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final phase = gamePhaseNotifier.value;

    if (phase == GamePhase.start) {
      if (keysPressed.contains(LogicalKeyboardKey.enter) ||
          keysPressed.contains(LogicalKeyboardKey.space)) {
        startGame();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (phase == GamePhase.gameOver) {
      if (keysPressed.contains(LogicalKeyboardKey.enter) ||
          keysPressed.contains(LogicalKeyboardKey.space)) {
        reset();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    
    final isLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);
    final isUp = keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
      keysPressed.contains(LogicalKeyboardKey.keyW);
    final isDown = keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
      keysPressed.contains(LogicalKeyboardKey.keyS);
    
    player.moveLeft = isLeft;
    player.moveRight = isRight;
    player.moveUp = isUp;
    player.moveDown = isDown;
    
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      player.shoot();
    }
    
    return KeyEventResult.handled;
  }

  @override
  void onTapDown(TapDownEvent event) {
    final phase = gamePhaseNotifier.value;
    if (phase == GamePhase.start) {
      startGame();
      return;
    }
    if (phase == GamePhase.gameOver) {
      reset();
      return;
    }
    
    final touchX = event.canvasPosition.x;
    final touchY = event.canvasPosition.y;
    final playerX = player.position.x;
    final playerY = player.position.y;
    
    if (touchX < playerX - 20) {
      player.moveLeft = true;
      player.moveRight = false;
    } else if (touchX > playerX + 20) {
      player.moveRight = true;
      player.moveLeft = false;
    }

    if (touchY < playerY - 20) {
      player.moveUp = true;
      player.moveDown = false;
    } else if (touchY > playerY + 20) {
      player.moveDown = true;
      player.moveUp = false;
    }
    
    player.shoot();
  }

  @override
  void onTapUp(TapUpEvent event) {
    player.moveLeft = false;
    player.moveRight = false;
    player.moveUp = false;
    player.moveDown = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    player.moveLeft = false;
    player.moveRight = false;
    player.moveUp = false;
    player.moveDown = false;
  }
}
