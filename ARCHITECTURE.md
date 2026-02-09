# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Application                      │
│                      (MaterialApp)                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      Game Screen                             │
│              (StatefulWidget + Scaffold)                     │
│                                                              │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   HUD/UI    │  │  Game Widget  │  │  Game Over   │      │
│  │  (Overlay)  │  │  (Flame Game) │  │   Screen     │      │
│  └─────────────┘  └──────┬───────┘  └──────────────┘      │
└───────────────────────────┼──────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   RiverRaidGame                              │
│              (FlameGame + HasCollisionDetection)             │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Game State Management                  │    │
│  │  • ValueNotifier<int> scoreNotifier                │    │
│  │  • ValueNotifier<double> fuelNotifier              │    │
│  │  • ValueNotifier<bool> gameOverNotifier            │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Input Handling                         │    │
│  │  • KeyboardEvents (Web)                            │    │
│  │  • TapDetector (Mobile)                            │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Game Loop                              │    │
│  │  • Update entities                                  │    │
│  │  • Spawn management                                 │    │
│  │  • Collision detection                              │    │
│  │  • Difficulty scaling                               │    │
│  └────────────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         ▼                               ▼
┌──────────────────┐          ┌──────────────────┐
│   Game Entities  │          │  Collision System │
│  (PositionComponent)         │   (HasCollision)  │
└────────┬─────────┘          └──────────────────┘
         │
    ┌────┴────┬─────────┬──────────┬──────────┐
    ▼         ▼         ▼          ▼          ▼
┌────────┐ ┌──────┐ ┌───────┐ ┌──────────┐ ┌─────────┐
│ Player │ │Enemy │ │Bullet │ │FuelDepot │ │Terrain  │
└────────┘ └──────┘ └───────┘ └──────────┘ └─────────┘
```

## Component Hierarchy

```
RiverRaidGame
├── Player (priority: 10)
│   ├── RectangleHitbox
│   └── Bullets (spawned dynamically)
│
├── Enemies (spawned periodically)
│   └── RectangleHitbox
│
├── Fuel Depots (spawned periodically)
│   └── RectangleHitbox
│
└── Terrain (spawned continuously)
    ├── Left Terrain
    │   └── RectangleHitbox
    └── Right Terrain
        └── RectangleHitbox
```

## Data Flow

```
User Input → Input Handlers → Player Component → Game State
                                      ↓
                              Bullet Creation
                                      ↓
                           Collision Detection
                                      ↓
                    ┌─────────────────┴─────────────────┐
                    ▼                                   ▼
            Score/Fuel Update                     Entity Removal
                    ▼                                   ▼
            ValueNotifier Update                 removeFromParent()
                    ▼                                   
               UI Update (HUD)
```

## Game Loop Cycle

```
┌─────────────────────────────────────────────┐
│                                             │
│  1. Update (dt)                             │
│     ├── Update fuel consumption             │
│     ├── Check game over conditions          │
│     ├── Update spawn timers                 │
│     ├── Spawn entities (enemies, fuel, terrain) │
│     └── Increase difficulty                 │
│                                             │
│  2. Component Updates                       │
│     ├── Player movement                     │
│     ├── Enemy movement                      │
│     ├── Bullet movement                     │
│     ├── Terrain movement                    │
│     └── Remove off-screen entities          │
│                                             │
│  3. Collision Detection                     │
│     ├── Player ↔ Enemy                      │
│     ├── Player ↔ Fuel Depot                 │
│     ├── Player ↔ Terrain                    │
│     └── Bullet ↔ Enemy/Terrain              │
│                                             │
│  4. Render                                  │
│     ├── Draw terrain                        │
│     ├── Draw fuel depots                    │
│     ├── Draw enemies                        │
│     ├── Draw bullets                        │
│     └── Draw player                         │
│                                             │
│  5. Repeat (60 FPS)                         │
│                                             │
└─────────────────────────────────────────────┘
```

## Performance Optimization Points

### 1. Entity Management
- Automatic removal of off-screen entities
- No object pooling (Flame handles efficiently)
- Minimal entity creation

### 2. Rendering
- Hardware-accelerated Canvas API
- Component priority for draw order
- Efficient shape drawing (no textures by default)

### 3. Collision Detection
- Flame's spatial hashing
- RectangleHitbox for simple shapes
- Only active components checked

### 4. State Management
- ValueNotifier for minimal rebuilds
- Separate UI and game logic
- Efficient state updates

### 5. Platform-Specific
- **Web**: CanvasKit renderer
- **Android**: ProGuard, resource shrinking
- **iOS**: Metal API, optimization flags

## Multi-Platform Rendering

```
                   Flutter Framework
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
      Web (HTML)      Android (Skia)   iOS (Metal)
          │               │               │
          ▼               ▼               ▼
    CanvasKit          OpenGL           Metal API
      (WebGL)          (GPU)            (GPU)
```

## Input Handling Flow

```
Platform Input
    │
    ├── Web (Keyboard)
    │   └── KeyEventResult.onKeyEvent()
    │       ├── Arrow Keys / WASD → Movement
    │       └── Space → Shoot
    │
    └── Mobile (Touch)
        └── TapDetector
            ├── onTapDown() → Movement direction + Shoot
            ├── onTapUp() → Stop movement
            └── onTapCancel() → Stop movement
```

## Build Pipeline

```
Source Code (.dart)
    │
    ▼
Dart Analyzer
    │
    ▼
Dart Compiler
    │
    ├── Web → dart2js → JavaScript (+ CanvasKit WASM)
    │   └── Output: build/web/
    │
    ├── Android → AOT → ARM/x86 native code
    │   └── Output: build/app/outputs/apk/
    │
    └── iOS → AOT → ARM64 native code
        └── Output: build/ios/
```

## Deployment Architecture

```
┌─────────────────────────────────────────────┐
│         GitHub Repository                    │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│       GitHub Actions CI/CD                   │
│  ├── flutter analyze                         │
│  ├── flutter test                            │
│  ├── flutter build web                       │
│  └── flutter build apk                       │
└────────────────┬────────────────────────────┘
                 │
     ┌───────────┴───────────┐
     ▼                       ▼
┌─────────┐           ┌──────────┐
│   Web   │           │  Mobile  │
│ Hosting │           │  Stores  │
└─────────┘           └──────────┘
```

This architecture ensures:
- ✅ High performance (60+ FPS)
- ✅ Multi-platform support
- ✅ Efficient resource usage
- ✅ Easy maintenance and updates
- ✅ Scalable game logic
