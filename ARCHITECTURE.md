# FlitPDF Architecture

This document describes the architecture and design decisions for FlitPDF, a Flutter-based PDF utility application.

## Overview

FlitPDF is built using **Clean Architecture** principles with a feature-based organization. The app follows a layered architecture that separates concerns and promotes maintainability.

## Project Structure

```
lib/
├── core/                    # Core utilities and shared components
│   ├── constants/          # App-wide constants and colors
│   ├── services/          # Core business services
│   ├── theme/            # Theme configuration
│   └── utils/            # Utility classes
├── features/              # Feature modules
│   ├── auth/            # Authentication (Firebase/Google)
│   ├── files/           # File management and PDF viewing
│   ├── home/            # Home screen
│   ├── scanner/         # Document scanning
│   ├── settings/       # App settings
│   ├── splash/          # Splash and onboarding
│   └── tools/          # PDF and image tools
├── shared/               # Shared widgets and controllers
│   ├── controllers/     # GetX controllers
│   ├── data/           # Shared data definitions
│   └── widgets/        # Reusable widgets
└── main.dart           # App entry point
```

### Layer Descriptions

#### Core Layer (`lib/core/`)
Contains fundamental code used throughout the app:
- **constants/**: App colors, dimensions, strings, and configuration values
- **services/**: Core services for file handling, image processing, storage
- **theme/**: Material theme configuration
- **utils/**: Utility classes (formatting, helpers)

#### Features Layer (`lib/features/`)
Organized by feature domain:
- Each feature is self-contained with its own data, presentation, and logic
- Follows the pattern: `feature_name/presentation/pages` or `feature_name/data/services`

#### Shared Layer (`lib/shared/`)
Code used across multiple features:
- **controllers/**: Global GetX controllers
- **data/**: Shared data definitions (tool definitions, constants)
- **widgets/**: Reusable UI components

## Technology Stack

### Framework & Language
- **Flutter**: 3.11.0+
- **Dart**: 3.11.0+

### State Management
- **GetX**: Reactive state management, dependency injection, route management

### Key Dependencies
| Package | Purpose |
|---------|---------|
| `get` | State management & routing |
| `pdf` | PDF generation |
| `file_picker` | File selection |
| `path_provider` | File system paths |
| `image` | Image manipulation |
| `flutter_image_compress` | Image compression |
| `flutter_doc_scanner` | Document scanning |
| `flutter_pdfview` | PDF rendering |
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication |
| `google_sign_in` | Google Sign-In |

### Architecture Patterns

#### Service Layer Pattern
Core services follow the singleton pattern for convenience:

```dart
class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();
}
```

#### GetX Controller Pattern
State management uses GetX controllers:

```dart
class MainShellController extends GetxController {
  final RxInt _currentIndex = 2.obs;
  // Reactive state and methods
}
```

#### Feature Module Pattern
Features are organized into modular directories:

```
features/
└── feature_name/
    ├── data/           # Data layer
    │   └── services/
    ├── domain/         # Business logic
    └── presentation/   # UI layer
        ├── pages/
        └── widgets/
```

## Data Flow

1. **User Interaction** → UI Widget
2. **UI Widget** → GetX Controller (if needed)
3. **Controller** → Core Service
4. **Service** → Platform/Storage
5. **Response** flows back up the chain

## Dependency Injection

The app uses GetX's built-in dependency injection:

```dart
// Register a service
Get.put(FileService());

// Register a controller
Get.put(MainShellController());

// Use a service/controller
final controller = Get.find<MainShellController>();
```

## Navigation

Navigation uses GetX's named routes and MaterialPageRoute:

```dart
// Named routes (recommended for deep linking)
Get.toNamed('/home');

// Direct navigation
Navigator.push(context, MaterialPageRoute(...));
```

## State Management

### Reactive State
Uses GetX observables (`Rx`) for reactive state:

```dart
final count = 0.obs;
// Automatically updates UI when count changes
```

### Workers
React to state changes:

```dart
ever(count, (callback) => // runs on every change);
once(count, (callback) => // runs only once);
```

## Error Handling

Services handle errors gracefully with try-catch blocks:

```dart
Future<String?> saveFileToDocuments(...) async {
  try {
    // ... operation
    return destPath;
  } catch (e) {
    return null;
  }
}
```

## Testing

Services are designed to be testable:
- Concrete implementations can be swapped with mocks
- Pure functions in utilities enable unit testing
- GetX allows controller testing

## Performance Considerations

1. **Lazy Loading**: Features loaded on demand
2. **Image Caching**: Using `cached_network_image` for remote images
3. **File Pagination**: Limit file scans to prevent memory issues
4. **Dispose Pattern**: Proper cleanup in controllers

## Security

- No secrets committed to the repository
- Firebase initialized with graceful fallbacks
- Local storage uses encrypted preferences where available

## Future Improvements

Potential architectural enhancements:
- Complete feature module separation (data/domain/presentation)
- Add BLoC pattern for complex features
- Implement clean architecture with use cases
- Add unit and widget tests