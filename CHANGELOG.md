# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-20

### Added
- **Document Scanning**: Scan physical documents using camera and convert to PDF
- **Image to PDF Conversion**: Convert single or multiple images to PDF documents
- **PDF Viewing**: Built-in PDF viewer for viewing PDF files
- **PDF Compression**: Compress existing PDF files to reduce file size
- **Image Compression**: Compress images to reduce file size
- **Recent Files**: Track and display recently opened files
- **Popular Tools**: Quick access to frequently used tools
- **Firebase Authentication**: Optional Google Sign-In integration
- **In-App Updates**: Check for app updates on startup
- **In-App Reviews**: Request app reviews from users

### Features
- Local-first document workflows for privacy
- File browser with filtering by type (PDF, images, documents)
- File operations (rename, delete, open)
- Storage usage information
- Sharing functionality
- Onboarding screens for new users

### Technical
- Flutter 3.11.0+ with Dart 3.11.0+
- GetX for state management and navigation
- Clean Architecture organization
- Firebase integration (optional)

---

## [Unreleased]

### Planned Features
- Merge multiple PDFs into one
- Extract images from PDF
- Convert PDF to images
- Word/Excel/PowerPoint to PDF conversion
- PDF to Word/Excel conversion
- Text extraction from PDF (OCR)
- PDF editing capabilities
- PDF signing
- Watermarking
- Page rotation
- Add page numbers

### Improvements
- Enhanced documentation
- Code refactoring for maintainability
- Additional unit tests

---

## Architecture Note

This changelog focuses on user-facing features. For detailed technical changes, see the Git commit history.

## Upgrade Notes

### From 0.x to 1.0
- Minimum Flutter SDK is now 3.11.0
- Android minimum SDK is now 21 (Android 5.0)
- Removed deprecated packages updated to latest versions
- State management continues to use GetX

## Reporting Issues

Found a bug or have a feature request?
- Open an issue at: https://github.com/flitpdf/flitpdf/issues
- Follow the issue templates for bug reports and feature requests

## Security Vulnerabilities

For security issues, please follow the process in SECURITY.md.
Do NOT open public issues for vulnerabilities.