# SermonNotes

A Flutter mobile note-taking app for sermon notes with an intelligent Bible Toolkit that detects and handles Bible verse references in real-time.

## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

### Folder Structure

```
lib/
├── core/                  # Core utilities and base classes
│   ├── constants/         # App constants and configurations
│   ├── error/            # Error handling and exceptions
│   ├── network/          # Network utilities
│   └── usecases/         # Base usecase classes
├── data/                 # Data layer
│   ├── datasources/      # Local (SQLite) and remote data sources
│   ├── models/           # Data models with JSON serialization
│   └── repositories/     # Repository implementations
├── domain/               # Business logic layer
│   ├── entities/         # Business entities (pure Dart)
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business use cases
└── presentation/         # UI layer
    ├── bloc/             # BLoC state management
    ├── pages/            # App screens
    └── widgets/          # Reusable widgets
```

### Key Features

- **Bible Verse Detection**: Real-time detection of Bible references (e.g., "John 3:16") as users type
- **Local Storage**: SQLite database for offline note storage
- **State Management**: flutter_bloc for predictable state management
- **Clean Architecture**: Separation of concerns for maintainability and testability

### Dependencies

- `flutter_bloc` - State management
- `sqflite` - Local SQLite database
- `http` - API calls for Bible verse content
- `rxdart` - Debouncing user input
- `equatable` - Value equality
- `get_it` - Dependency injection

## Getting Started

1. Install dependencies:

```bash
flutter pub get
```

2. Run the app:

```bash
flutter run
```

## Testing

```bash
flutter test
```

### Complete installation of mobile sdks

✗ cmdline-tools component is missing.
Try installing or updating Android Studio.
Alternatively, download the tools from https://developer.android.com/studio#command-line-tools-only
and make sure to set the ANDROID_HOME environment variable.
See https://developer.android.com/studio/command-line for more details.
✗ Android license status unknown.
Run `flutter doctor --android-licenses` to accept the SDK licenses.
See https://flutter.dev/to/macos-android-setup for more details.

[!] Xcode - develop for iOS and macOS [1,126ms]
✗ Xcode installation is incomplete; a full installation is necessary for iOS and macOS development.
Download at: https://developer.apple.com/xcode/
Or install Xcode via the App Store.
Once installed, run:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
• CocoaPods version 1.16.2
