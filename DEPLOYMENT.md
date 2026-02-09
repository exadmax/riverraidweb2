# Deployment Instructions

## Web Deployment

### Build for Production
```bash
flutter build web --release --web-renderer canvaskit
```

The output will be in `build/web/`. You can deploy this to any static hosting service:

#### GitHub Pages
```bash
# After building
cd build/web
git init
git add .
git commit -m "Deploy to GitHub Pages"
git push -f https://github.com/exadmax/riverraidweb2.git main:gh-pages
```

#### Firebase Hosting
```bash
firebase init
firebase deploy
```

#### Netlify
Simply drag and drop the `build/web` folder to Netlify or connect your repository.

### Performance Considerations for Web
- Uses CanvasKit for best rendering performance
- PWA enabled for offline play
- Assets are optimized and cached
- Service Worker for fast loading

## Android Deployment

### Build APK
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (Google Play)
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Performance Optimizations Enabled
- ProGuard minification
- Resource shrinking
- Hardware acceleration
- Optimized for Android API 21+

## iOS Deployment

### Build for iOS
```bash
flutter build ios --release
```

### Archive for App Store
1. Open in Xcode: `open ios/Runner.xcworkspace`
2. Select Product > Archive
3. Follow App Store submission process

### Performance Features
- Metal rendering
- 120Hz support for compatible devices
- Optimized for iOS 12+

## Testing Different Platforms

### Test on Web
```bash
flutter run -d chrome
```

### Test on Android
```bash
flutter run -d android
```

### Test on iOS
```bash
flutter run -d ios
```

### Test All Platforms
```bash
flutter devices  # List available devices
flutter run -d <device_id>
```

## Performance Profiling

### Web Performance
```bash
flutter run -d chrome --profile
```
Then use Chrome DevTools for profiling.

### Mobile Performance
```bash
flutter run --profile
```
Use Flutter DevTools for performance analysis.

## Build Sizes

Expected build sizes:
- **Web**: ~2-3 MB (gzipped)
- **Android APK**: ~15-20 MB
- **Android App Bundle**: ~12-15 MB
- **iOS IPA**: ~20-25 MB

## Environment Requirements

### Development
- Flutter SDK 3.0+
- Android SDK (for Android builds)
- Xcode 14+ (for iOS builds, macOS only)
- Chrome/Safari (for web testing)

### Target Devices
- **Web**: Modern browsers (Chrome, Firefox, Safari, Edge)
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12+
