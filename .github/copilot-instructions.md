# Copilot Agent Instructions

## Flutter SDK
- Full path: /opt/flutter/bin
- Add to PATH (already configured system-wide in /etc/profile.d/flutter.sh):
  - export PATH="/opt/flutter/bin:$PATH"

## Project Setup
1. Ensure Flutter is available:
   - flutter --version
2. Check environment:
   - flutter doctor
3. Install project dependencies:
   - flutter pub get

## Run
- Web:
  - flutter run -d chrome
- Tests:
  - flutter test

## Build (optional)
- flutter build web --release
- flutter build apk --release
