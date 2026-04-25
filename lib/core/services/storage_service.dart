import 'dart:convert';
import 'dart:io';

import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _recentFilesKey = 'recent_files';
  static const String _recentToolsKey = 'recent_tools';
  static const int _maxRecentFiles = 20;
  static const int _maxRecentTools = 10;

  // User data keys for Firebase authentication
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhotoUrlKey = 'user_photo_url';
  static const String _userUidKey = 'user_uid';
  static const String _isLoggedInKey = 'is_logged_in';

  final DiskSpacePlus _diskSpacePlus = DiskSpacePlus();

  /// Get storage information for the device
  Future<Map<String, double>> getStorageInfo() async {
    final Map<String, double> storageInfo = <String, double>{
      'total': 0.0,
      'used': 0.0,
      'free': 0.0,
      'files': 0.0,
      'images': 0.0,
      'documents': 0.0,
      'all': 0.0,
    };

    try {
      // Get actual device storage from disk_space_plus
      double? totalSpace = await _diskSpacePlus.getTotalDiskSpace;
      double? freeSpace = await _diskSpacePlus.getFreeDiskSpace;

      // disk_space_plus may return in KB - convert to bytes if value is small
      if (totalSpace != null && totalSpace > 0 && totalSpace < 1000000) {
        totalSpace = totalSpace * 1024 * 1024; // Convert KB to GB
      }
      if (freeSpace != null && freeSpace > 0 && freeSpace < 1000000) {
        freeSpace = freeSpace * 1024 * 1024; // Convert KB to GB
      }

      // Fallback: Try platform channel if disk_space_plus returns null
      if (totalSpace == null || freeSpace == null) {
        totalSpace = await _getStorageViaPlatformChannel(true);
        freeSpace = await _getStorageViaPlatformChannel(false);
      }

      storageInfo['total'] = totalSpace ?? 0.0;
      storageInfo['free'] = freeSpace ?? 0.0;
      storageInfo['used'] = (totalSpace ?? 0.0) - (freeSpace ?? 0.0);

      // Get app's documents storage
      storageInfo['documents'] = await _getDocumentsStorage();

      // Get images storage from common directories
      storageInfo['images'] = await _getImagesStorage();

      // Get total files storage (app specific + common locations)
      storageInfo['files'] = await _getFilesStorage();

      // Calculate total of all document types
      storageInfo['all'] =
          (storageInfo['files'] ?? 0.0) + (storageInfo['documents'] ?? 0.0);

      // Debug: If all values are 0, set some sample data for display testing
      if (storageInfo['total'] == 0.0 && storageInfo['files'] == 0.0) {
        // Try getting storage via method channel as last resort
        storageInfo['total'] = await _getTotalStorageFallback();
        storageInfo['free'] = await _getFreeStorageFallback();
        storageInfo['used'] = storageInfo['total']! - storageInfo['free']!;
      }
    } catch (e) {
      // Return default values if any error occurs
      // print('StorageService Error: $e');
    }

    return storageInfo;
  }

  /// Fallback method to get storage via platform channel
  Future<double?> _getStorageViaPlatformChannel(bool isTotal) async {
    try {
      final MethodChannel channel = const MethodChannel('disk_space_plus');
      final double? result = await channel.invokeMethod<double>(
        isTotal ? 'getTotalDiskSpace' : 'getFreeDiskSpace',
      );
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Fallback for total storage using method channel
  Future<double> _getTotalStorageFallback() async {
    try {
      if (Platform.isAndroid) {
        final MethodChannel channel = const MethodChannel('flitpdf/storage');
        final double? result = await channel.invokeMethod<double>(
          'getTotalStorage',
        );
        return result ?? 64000000000.0; // Default 64GB
      }
    } catch (e) {
      // Fallback to estimated 64GB
    }
    return 64000000000.0;
  }

  /// Fallback for free storage using method channel
  Future<double> _getFreeStorageFallback() async {
    try {
      if (Platform.isAndroid) {
        final MethodChannel channel = const MethodChannel('flitpdf/storage');
        final double? result = await channel.invokeMethod<double>(
          'getFreeStorage',
        );
        return result ?? 32000000000.0; // Default 32GB
      }
    } catch (e) {
      // Fallback to estimated 32GB
    }
    return 32000000000.0;
  }

  /// Get actual files from device storage
  Future<List<FileInfo>> getDeviceFiles({
    String? filterType,
    int? limit,
    int? offset,
  }) async {
    final List<FileInfo> allFiles = <FileInfo>[];

    try {
      // Scan common directories
      final List<String> searchPaths = <String>[];

      if (Platform.isAndroid) {
        searchPaths.addAll(<String>[
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Documents',
          '/storage/emulated/0/DCIM',
          '/storage/emulated/0/Pictures',
        ]);
      } else if (Platform.isIOS) {
        final Directory docsDir = await getApplicationDocumentsDirectory();
        searchPaths.add(docsDir.path);
      }

      // Also scan app's documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      searchPaths.add(appDocDir.path);

      // Collect all files
      for (final String path in searchPaths) {
        final Directory directory = Directory(path);
        if (await directory.exists()) {
          final List<FileInfo> files = await _scanDirectory(
            directory,
            filterType,
          );
          allFiles.addAll(files);
          if (allFiles.length > 1000) break; // Limit total files
        }
      }

      // Sort by modification date (newest first)
      allFiles.sort(
        (FileInfo a, FileInfo b) => b.modified.compareTo(a.modified),
      );

      allFiles.length = allFiles.length.clamp(0, 1000); // Final limit

      // Apply pagination if needed
      if (offset != null && offset > 0) {
        final int end = (limit != null) ? offset + limit : allFiles.length;
        if (offset < allFiles.length) {
          return allFiles.sublist(
            offset,
            end > allFiles.length ? allFiles.length : end,
          );
        }
        return <FileInfo>[];
      }

      if (limit != null && limit > 0) {
        return allFiles.take(limit).toList();
      }

      return allFiles;
    } catch (e) {
      return <FileInfo>[];
    }
  }

  Future<List<FileInfo>> _scanDirectory(
    Directory directory,
    String? filterType, {
    int depth = 0,
  }) async {
    if (depth > 3) return <FileInfo>[];

    final List<FileInfo> files = <FileInfo>[];

    try {
      await for (final FileSystemEntity entity in directory.list(
        recursive: false,
        followLinks: false,
      )) {
        if (entity is File) {
          final FileStat stat = await entity.stat();
          final String extension = entity.path.split('.').last.toLowerCase();

          // Apply filter if specified
          if (filterType != null && !_matchesFilter(extension, filterType)) {
            continue;
          }

          // Skip hidden files and system files
          if (entity.path.contains('/.')) {
            continue;
          }

          files.add(
            FileInfo(
              name: entity.path.split('/').last,
              path: entity.path,
              size: stat.size.toDouble(),
              modified: stat.modified,
              extension: extension,
            ),
          );
        } else if (entity is Directory) {
          files.addAll(
            await _scanDirectory(entity, filterType, depth: depth + 1),
          );
        }
      }
    } catch (e) {
      // Skip directories that can't be accessed
    }

    return files;
  }

  bool _matchesFilter(String extension, String filter) {
    switch (filter.toLowerCase()) {
      case 'pdf':
        return extension == 'pdf';
      case 'images':
        return <String>[
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
          'bmp',
        ].contains(extension);
      case 'documents':
        return <String>[
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'rtf',
        ].contains(extension);
      case 'others':
        return !<String>[
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
          'bmp',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'rtf',
        ].contains(extension);
      default:
        return true;
    }
  }

  Future<double> _getFilesStorage() async {
    double totalSize = 0.0;

    try {
      final List<String> filePaths = <String>[
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Documents',
      ];

      for (final String path in filePaths) {
        try {
          final Directory directory = Directory(path);
          if (await directory.exists()) {
            totalSize += await _calculateDirectorySize(directory);
          }
        } catch (e) {
          // Skip directories that can't be accessed
          // print('Error accessing $path: $e');
        }
      }
    } catch (e) {
      // Return 0 if unable to access
    }

    return totalSize;
  }

  Future<double> _getImagesStorage() async {
    double totalSize = 0.0;

    try {
      final List<String> imagePaths = <String>[
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0/DCIM/Camera',
      ];

      for (final String path in imagePaths) {
        try {
          final Directory directory = Directory(path);
          if (await directory.exists()) {
            totalSize += await _calculateDirectorySize(directory);
          }
        } catch (e) {
          // Skip directories that can't be accessed
          // print('Error accessing $path: $e');
        }
      }
    } catch (e) {
      // Return 0 if unable to access
    }

    return totalSize;
  }

  Future<double> _getDocumentsStorage() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      return await _calculateDirectorySize(Directory(directory.path));
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> _calculateDirectorySize(
    Directory directory, {
    int depth = 0,
  }) async {
    if (depth > 3) return 0.0;

    double totalSize = 0.0;

    try {
      await for (final FileSystemEntity entity in directory.list(
        recursive: false,
        followLinks: false,
      )) {
        if (entity is File) {
          try {
            final int fileLength = await entity.length();
            totalSize += fileLength.toDouble();
          } catch (e) {
            // Skip files that can't be accessed
          }
        } else if (entity is Directory) {
          totalSize += await _calculateDirectorySize(entity, depth: depth + 1);
        }
      }
    } catch (e) {
      // Skip directories that can't be accessed
    }

    return totalSize;
  }

  String formatBytes(double bytes) {
    if (bytes <= 0) return '0 B';

    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(1)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    } else {
      return '${bytes.toStringAsFixed(0)} B';
    }
  }

  Future<bool> get isFirstLaunch async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('has_seen_onboarding') ?? false);
  }

  Future<void> setHasSeenOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  // User data methods for Firebase authentication
  Future<void> saveUserData({
    required String name,
    required String email,
    String? photoUrl,
    required String uid,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    if (photoUrl != null) {
      await prefs.setString(_userPhotoUrlKey, photoUrl);
    }
    await prefs.setString(_userUidKey, uid);
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<Map<String, String?>> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return <String, String?>{
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'photoUrl': prefs.getString(_userPhotoUrlKey),
      'uid': prefs.getString(_userUidKey),
    };
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhotoUrlKey);
    await prefs.remove(_userUidKey);
    await prefs.setBool(_isLoggedInKey, false);
    // Reset onboarding to show again after logout
    await prefs.setBool('has_seen_onboarding', false);
  }

  Future<List<RecentFileRecord>> getRecentFiles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> rawItems =
        prefs.getStringList(_recentFilesKey) ?? <String>[];

    return rawItems
        .map(RecentFileRecord.tryParse)
        .whereType<RecentFileRecord>()
        .toList();
  }

  Future<void> addRecentFile(FileInfo file) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<RecentFileRecord> files = await getRecentFiles();

    files.removeWhere((RecentFileRecord item) => item.path == file.path);
    files.insert(0, RecentFileRecord.fromFileInfo(file));

    await prefs.setStringList(
      _recentFilesKey,
      files
          .take(_maxRecentFiles)
          .map((RecentFileRecord item) => item.toRaw())
          .toList(),
    );
  }

  Future<List<RecentToolRecord>> getRecentTools() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> rawItems =
        prefs.getStringList(_recentToolsKey) ?? <String>[];

    return rawItems
        .map(RecentToolRecord.tryParse)
        .whereType<RecentToolRecord>()
        .toList();
  }

  Future<void> addRecentTool({
    required String name,
    required String iconName,
    required int colorValue,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<RecentToolRecord> tools = await getRecentTools();

    tools.removeWhere((RecentToolRecord item) => item.name == name);
    tools.insert(
      0,
      RecentToolRecord(
        name: name,
        iconName: iconName,
        colorValue: colorValue,
        usedAt: DateTime.now(),
      ),
    );

    await prefs.setStringList(
      _recentToolsKey,
      tools
          .take(_maxRecentTools)
          .map((RecentToolRecord item) => item.toRaw())
          .toList(),
    );
  }
}

/// Model class to hold file information
class FileInfo {
  final String name;
  final String path;
  final double size;
  final DateTime modified;
  final String extension;

  FileInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.modified,
    required this.extension,
  });

  /// Get the file type category
  String get type {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'pdf';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
        return 'image';
      case 'doc':
      case 'docx':
      case 'xls':
      case 'xlsx':
      case 'ppt':
      case 'pptx':
      case 'txt':
      case 'rtf':
        return 'document';
      default:
        return 'other';
    }
  }

  /// Get formatted size string
  String get formattedSize {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (size >= gb) {
      return '${(size / gb).toStringAsFixed(1)} GB';
    } else if (size >= mb) {
      return '${(size / mb).toStringAsFixed(1)} MB';
    } else if (size >= kb) {
      return '${(size / kb).toStringAsFixed(1)} KB';
    } else {
      return '${size.toStringAsFixed(0)} B';
    }
  }

  /// Get formatted date string
  String get formattedDate {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime fileDate = DateTime(
      modified.year,
      modified.month,
      modified.day,
    );

    if (fileDate == today) {
      return 'Today, ${modified.hour.toString().padLeft(2, '0')}:${modified.minute.toString().padLeft(2, '0')}';
    } else if (fileDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(modified).inDays < 7) {
      return '${_getDayName(modified.weekday)}, ${modified.hour.toString().padLeft(2, '0')}:${modified.minute.toString().padLeft(2, '0')}';
    } else {
      return '${_monthName(modified.month)} ${modified.day}, ${modified.year}';
    }
  }

  String _getDayName(int weekday) {
    const List<String> days = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return days[weekday - 1];
  }

  String _monthName(int month) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Get the directory path of the file
  String get directory {
    final int lastSlash = path.lastIndexOf('/');
    if (lastSlash > 0) {
      return path.substring(0, lastSlash);
    }
    return '/';
  }
}

class RecentFileRecord {
  final String name;
  final String path;
  final double size;
  final DateTime modified;
  final String extension;
  final DateTime openedAt;

  RecentFileRecord({
    required this.name,
    required this.path,
    required this.size,
    required this.modified,
    required this.extension,
    required this.openedAt,
  });

  factory RecentFileRecord.fromFileInfo(FileInfo file) {
    return RecentFileRecord(
      name: file.name,
      path: file.path,
      size: file.size,
      modified: file.modified,
      extension: file.extension,
      openedAt: DateTime.now(),
    );
  }

  static RecentFileRecord? tryParse(String raw) {
    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      return RecentFileRecord(
        name: data['name'] as String,
        path: data['path'] as String,
        size: (data['size'] as num).toDouble(),
        modified: DateTime.parse(data['modified'] as String),
        extension: data['extension'] as String,
        openedAt: DateTime.parse(data['openedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  String toRaw() {
    return jsonEncode(<String, dynamic>{
      'name': name,
      'path': path,
      'size': size,
      'modified': modified.toIso8601String(),
      'extension': extension,
      'openedAt': openedAt.toIso8601String(),
    });
  }

  FileInfo toFileInfo() {
    return FileInfo(
      name: name,
      path: path,
      size: size,
      modified: modified,
      extension: extension,
    );
  }

  String get formattedOpenedAt {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(openedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      final int minutes = difference.inMinutes;
      return '$minutes min${minutes == 1 ? '' : 's'} ago';
    }
    if (difference.inDays < 1) {
      final int hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return toFileInfo().formattedDate;
  }
}

class RecentToolRecord {
  final String name;
  final String iconName;
  final int colorValue;
  final DateTime usedAt;

  RecentToolRecord({
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.usedAt,
  });

  static RecentToolRecord? tryParse(String raw) {
    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      return RecentToolRecord(
        name: data['name'] as String,
        iconName: data['iconName'] as String,
        colorValue: data['colorValue'] as int,
        usedAt: DateTime.parse(data['usedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  String toRaw() {
    return jsonEncode(<String, dynamic>{
      'name': name,
      'iconName': iconName,
      'colorValue': colorValue,
      'usedAt': usedAt.toIso8601String(),
    });
  }
}
