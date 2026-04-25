// Application-wide constants and configuration values.
//
// This file centralizes application settings and constants
// that are used throughout the application.

// Application metadata
class AppConstants {
  AppConstants._();

  /// Application name
  static const String appName = 'FlitPDF';

  /// Application package name
  static const String packageName = 'com.flitpdf.app';

  /// Current application version
  static const String version = '1.0.0';

  /// Default maximum number of recent files to track
  static const int maxRecentFiles = 20;

  /// Default maximum number of recent tools to track
  static const int maxRecentTools = 10;

  /// File extension filters
  static const List<String> imageExtensions = <String>['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'];
  static const List<String> documentExtensions = <String>['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'rtf'];
  static const List<String> pdfExtensions = <String>['pdf'];

  /// Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 1000);

  /// Maximum file scan depth
  static const int maxScanDepth = 3;
  static const int maxScanFiles = 50;

  /// Carousel settings
  static const int carouselIntervalSeconds = 4;

  /// Storage keys for SharedPreferences
  static const String recentFilesKey = 'recent_files';
  static const String recentToolsKey = 'recent_tools';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String userPhotoUrlKey = 'user_photo_url';
  static const String userUidKey = 'user_uid';
  static const String isLoggedInKey = 'is_logged_in';
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';

  /// Default storage paths on Android
  static const List<String> androidSearchPaths = <String>[
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Documents',
    '/storage/emulated/0/DCIM',
    '/storage/emulated/0/Pictures',
  ];

  /// Fallback storage estimates (in bytes)
  static const double defaultTotalStorage = 64000000000.0; // 64GB
  static const double defaultFreeStorage = 32000000000.0; // 32GB
}