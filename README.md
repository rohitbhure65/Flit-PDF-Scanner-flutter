# FlitPDF

<p align="center">
  <a href="https://flutter.dev/">
    <img src="https://img.shields.io/badge/Flutter-3.11.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  </a>
 <a href="https://github.com/rohitbhure65/Flit-PDF-Scanner-flutter/releases">
  <img src="https://img.shields.io/github/v/release/rohitbhure65/Flit-PDF-Scanner-flutter?include_prereleases&style=for-the-badge&logo=github&logoColor=white" />
</a>
  <a href="https://pub.dev/packages/pdf">
    <img src="https://img.shields.io/badge/Dart-3.11.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  </a>
  <a href="https://discord.gg/MkwJkHPmbt">
    <img src="https://img.shields.io/discord/1336694184400388212?label=Discord&logo=discord&logoColor=white&color=5865F2&style=for-the-badge" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
  </a>
</p>

FlitPDF is an open-source Flutter application for local-first PDF and document utilities on Android. It focuses on everyday workflows like scanning documents, converting images to PDFs, viewing files, and compressing documents—all processed directly on your device.

## Features

### Currently Available

| Feature | Description |
|---------|-------------|
| 📄 **Scan Documents** | Scan physical documents using your camera and save as PDF |
| 🖼️ **Image to PDF** | Convert one or multiple images into a PDF document |
| 📂 **Open PDF** | Built-in PDF viewer for viewing PDF files |
| 📚 **Compress PDF** | Reduce PDF file size while maintaining quality |
| 🖌️ **Compress Image** | Compress images to save storage space |
| 📁 **File Browser** | Browse and manage files on your device |
| 🕐 **Recent Files** | Quick access to recently opened files |

### Coming Soon

- Merge multiple PDFs
- PDF to image conversion
- Word/Excel to PDF conversion
- Text extraction (OCR)
- PDF editing and signing

*Contributions to complete these features are welcome!*

## Quick Start

### Prerequisites

- Flutter SDK 3.11.0 or higher
- Android SDK with API 21+ (Android 5.0)
- Android Studio or VS Code with Flutter extensions

### Installation

```bash
# Clone the repository
git clone https://github.com/flitpdf/flitpdf.git
cd flitpdf

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Building

```bash
# Debug build
flutter build apk --debug

# Release build (requires signing configuration)
flutter build apk --release
```

See [Building](#building) section for release signing details.

## Project Structure

```
flitpdf/
├── lib/
│   ├── core/                    # Core utilities
│   │   ├── constants/          # App colors and constants
│   │   ├── services/          # Business services
│   │   ├── theme/             # Theme configuration
│   │   └── utils/            # Utility classes
│   ├── features/              # Feature modules
│   │   ├── auth/             # Authentication
│   │   ├── files/            # File management
│   │   ├── home/             # Home screen
│   │   ├── scanner/          # Document scanning
│   │   ├── settings/         # App settings
│   │   ├── splash/          # Splash/onboarding
│   │   └── tools/           # PDF & image tools
│   └── shared/               # Shared code
│       ├── controllers/       # GetX controllers
│       ├── data/            # Shared data
│       └── widgets/         # UI widgets
├── assets/                   # App assets
│   ├── animations/          # Lottie/Rive animations
│   ├── fonts/               # Custom fonts
│   └── images/              # Image assets
├── android/                  # Android configuration
├── ios/                      # iOS configuration (placeholder)
├── test/                    # Unit/widget tests
├── ARCHITECTURE.md          # Architecture documentation
├── CHANGELOG.md            # Version changelog
├── CONTRIBUTING.md         # Contribution guidelines
└── pubspec.yaml            # Dependencies
```

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Technology Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.11.0+ |
| Language | Dart 3.11.0+ |
| State Management | GetX |
| PDF | `pdf` package |
| Image Processing | `image`, `flutter_image_compress` |
| Document Scanning | `flutter_doc_scanner` |
| Storage | `path_provider`, `shared_preferences` |
| Authentication | Firebase Auth, Google Sign-In |

See `pubspec.yaml` for the complete dependency list.

## Open Source

### License

The source code is available under the [MIT License](LICENSE).

### Contributing

Contributions are welcome! Please read our [contribution guidelines](CONTRIBUTING.md) before submitting pull requests.

Key points:
- Follow existing code style and conventions
- Use the GitHub issue templates
- Add tests or manual verification notes
- Don't commit secrets or credentials

### Community

- **Issues**: Report bugs and request features via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions
- **Security**: Follow the process in [SECURITY.md](SECURITY.md) for vulnerabilities

## Building

### Development Build

The app builds without any additional configuration:

```bash
flutter build apk --debug
```

### Release Build

For release builds, configure signing:

1. Copy `android/key.properties.example` to `android/key.properties`
2. Add your keystore at `android/app/upload-keystore.jks`
3. Build the release:

```bash
flutter build apk --release
```

### Optional Firebase Setup

To test Firebase features:

1. Create a Firebase project at https://console.firebase.google.com
2. Add the Android app with your package name
3. Download `google-services.json` and place in `android/app/`
4. Run with your Google web client ID:

```bash
flutter run --dart-define=FLITPDF_GOOGLE_SERVER_CLIENT_ID=your-client-id.apps.googleusercontent.com
```

An example config is provided at `android/app/google-services.json.example`.

Core PDF features work without Firebase.

## Privacy

FlitPDF processes files locally on your device. No files are uploaded to external servers unless you explicitly choose to share them. Optional Firebase features (Google Sign-In) require account creation but are not required for core functionality.

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for details.

## Branding

The FlitPDF name, logo, and branding are reserved. If you fork this project:

- Use a different app name and icon
- Don't present your fork as the official FlitPDF project
- Preserve upstream attribution

See [TRADEMARKS.md](TRADEMARKS.md) for branding guidelines.

## Contact

- **Email**: rohitbhure.cse@gmail.com
- **GitHub**: https://github.com/rohitbhure65/Flit-PDF-Scanner-flutter

## Acknowledgments

Thanks to the Flutter community and the maintainers of the packages used in this project.

---

<p align="center">
  Made with ❤️ for open source PDF utilities
</p>
