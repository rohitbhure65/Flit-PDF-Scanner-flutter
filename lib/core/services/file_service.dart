import 'dart:io';

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Service to handle file storage in public directories
/// Images go to DCIM/FlitPDF/Images/MultipleImages (visible in Gallery/WhatsApp)
/// Files go to Documents folder (visible in File Explorer)
class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  /// Get the directory for storing images
  /// Path: DCIM/FlitPDF/Images/MultipleImages
  Future<Directory> getImagesDirectory() async {
    // Get external storage directory
    final Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      // Fallback to app documents directory
      return await getApplicationDocumentsDirectory();
    }

    // Navigate up from Android/app data to the root external storage
    String basePath = externalDir.path;
    
    // On Android, path_provider returns something like:
    // /data/user/0/com.example.flitpdf/files
    // We need to go up to get to the external storage root
    if (basePath.contains('/Android/data/')) {
      // Extract base storage path
      final int androidDataIndex = basePath.indexOf('/Android/data/');
      basePath = basePath.substring(0, androidDataIndex);
    }

    // Construct the images path: basePath/DCIM/FlitPDF/Images/MultipleImages
    final String imagesPath = p.join(basePath, 'DCIM', 'FlitPDF', 'Images', 'MultipleImages');
    final Directory imagesDir = Directory(imagesPath);

    // Create directory if it doesn't exist
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  /// Get the directory for storing documents (PDFs, etc.)
  /// Path: Documents/FlitPDF
  Future<Directory> getDocumentsDirectory() async {
    // Get external storage directory
    final Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      // Fallback to app documents directory
      return await getApplicationDocumentsDirectory();
    }

    // Navigate up from Android/app data to the root external storage
    String basePath = externalDir.path;
    
    if (basePath.contains('/Android/data/')) {
      final int androidDataIndex = basePath.indexOf('/Android/data/');
      basePath = basePath.substring(0, androidDataIndex);
    }

    // Construct the documents path: basePath/Documents/FlitPDF
    final String docsPath = p.join(basePath, 'Documents', 'FlitPDF');
    final Directory docsDir = Directory(docsPath);

    // Create directory if it doesn't exist
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }

    return docsDir;
  }

  /// Save an image to Gallery and return the saved file path
  /// The image will be visible in Gallery apps and WhatsApp
  Future<String?> saveImageToGallery(String sourcePath, {String? fileName}) async {
    try {
      final Directory imagesDir = await getImagesDirectory();
      
      // Generate filename if not provided
      final String name = fileName ?? 
          'FlitPDF_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String destPath = p.join(imagesDir.path, name);

      // Copy the file to the images directory
      final File sourceFile = File(sourcePath);
      await sourceFile.copy(destPath);

      // Insert to Gallery using gal package
      // This makes the image visible in Gallery apps
      await Gal.putImage(destPath);

      return destPath;
    } catch (e) {
      return null;
    }
  }

  /// Save a file (PDF) to Documents folder
  /// The file will be visible in File Explorer and document sharing apps
  Future<String?> saveFileToDocuments(String sourcePath, {String? fileName, String? extension}) async {
    try {
      final Directory docsDir = await getDocumentsDirectory();
      
      // Generate filename if not provided
      final String ext = extension ?? 'pdf';
      final String name = fileName ?? 
          'FlitPDF_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final String destPath = p.join(docsDir.path, name);

      // Copy the file to the documents directory
      final File sourceFile = File(sourcePath);
      await sourceFile.copy(destPath);

      return destPath;
    } catch (e) {
      return null;
    }
  }

  /// Save an image to the images directory without Gallery insertion
  /// Used when you don't want it to appear in Gallery immediately
  Future<String?> saveImageToDirectory(String sourcePath, {String? fileName, String? extension}) async {
    try {
      final Directory imagesDir = await getImagesDirectory();
      
      final String ext = extension ?? 'jpg';
      final String name = fileName ?? 
          'FlitPDF_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final String destPath = p.join(imagesDir.path, name);

      // Copy the file
      final File sourceFile = File(sourcePath);
      await sourceFile.copy(destPath);

      return destPath;
    } catch (e) {
      return null;
    }
  }
}