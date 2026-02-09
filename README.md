# River Raid Web 2

Continuação do projeto River Raid Web, porém em Flutter, com capacidades melhoradas.

## Descrição

Jogo River Raid desenvolvido em Flutter com suporte multiplataforma otimizado para:
- 🌐 **Web** - Jogue direto no navegador
- 📱 **Android** - Suporte para smartphones Android
- 🍎 **iOS** - Suporte para dispositivos Apple

## Características

- ✨ **Performance Otimizada**: Utiliza Flame Engine para renderização eficiente
- 🎮 **Controles Adaptativos**: 
  - Web: Teclado (setas ou WASD + espaço para atirar)
  - Mobile: Touch controls intuitivos
- 🚀 **Engine de Jogo**: Flame Game Engine para performance máxima
- 🎯 **Sistema de Colisões**: Detecção precisa e otimizada
- ⛽ **Sistema de Combustível**: Gerenciamento de recursos do jogo
- 🏆 **Sistema de Pontuação**: Acompanhe seu progresso

## Como Executar

### Requisitos
- Flutter SDK 3.0 ou superior
- Dart SDK incluído com Flutter

### Web
```bash
flutter run -d chrome
# ou para build de produção:
flutter build web --release
```

### Android
```bash
flutter run -d android
# ou para build de produção:
flutter build apk --release
```

### iOS
```bash
flutter run -d ios
# ou para build de produção:
flutter build ios --release
```

## Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada
├── river_raid_game.dart     # Lógica principal do jogo
└── components/              # Componentes do jogo
    ├── player.dart          # Jogador
    ├── enemy.dart           # Inimigos
    ├── bullet.dart          # Projéteis
    ├── fuel_depot.dart      # Postos de combustível
    └── terrain.dart         # Terreno
```

## Otimizações de Performance

- Uso de `const` constructors onde possível
- Canvas caching para elementos estáticos
- Efficient collision detection com Flame's collision system
- Código otimizado para mobile e web
- Minificação e tree-shaking no build de produção
- ProGuard rules para Android
- Hardware acceleration habilitado
