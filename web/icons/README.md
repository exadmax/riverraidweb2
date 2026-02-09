# Web Icons

Place your app icons here:
- Icon-192.png (192x192)
- Icon-512.png (512x512)
- Icon-maskable-192.png (192x192, maskable)
- Icon-maskable-512.png (512x512, maskable)

For now, placeholders can be generated or you can use the default Flutter icon.

To generate icons from a source image, use:
```bash
flutter pub run flutter_launcher_icons:main
```

Add to pubspec.yaml:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.0

flutter_icons:
  android: true
  ios: true
  web:
    generate: true
  image_path: "assets/icon.png"
```
