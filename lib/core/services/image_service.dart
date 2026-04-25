import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'file_service.dart';

/// Quality presets for image compression
enum ImageQuality { low, medium, high, custom }

/// Image format types
enum ImageFormat { jpg, png, webp }

/// Data class for image compression task
class _CompressImageData {
  final String inputPath;
  final String outputPath;
  final int quality;
  final int? width;
  final int? height;
  final String format;

  _CompressImageData({
    required this.inputPath,
    required this.outputPath,
    required this.quality,
    this.width,
    this.height,
    this.format = 'jpg',
  });
}

/// Isolate entry point for image compression
Future<String?> _compressImageIsolate(_CompressImageData data) async {
  try {
    final Uint8List? result = await FlutterImageCompress.compressWithFile(
      data.inputPath,
      quality: data.quality,
      minWidth: data.width ?? 1920,
      minHeight: data.height ?? 1080,
      format: _getCompressFormat(data.format),
    );

    if (result != null) {
      final File outputFile = File(data.outputPath);
      await outputFile.writeAsBytes(result);
      return data.outputPath;
    }

    return null;
  } catch (e) {
    debugPrint('Error compressing image: $e');
    return null;
  }
}

CompressFormat _getCompressFormat(String format) {
  switch (format.toLowerCase()) {
    case 'png':
      return CompressFormat.png;
    case 'webp':
      return CompressFormat.webp;
    default:
      return CompressFormat.jpeg;
  }
}

/// ImageService - handles image picking, compression, conversion, and resizing
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  /// Pick a single image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick a single image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 100,
      );
      return images;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return <XFile>[];
    }
  }

  /// Pick image with source selection (gallery or camera)
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      return await _imagePicker.pickImage(
        source: source,
        imageQuality: 100,
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Compress a single image with specified quality
  /// Returns the path to the compressed image, or null on failure
  Future<String?> compressImage(
    String inputPath, {
    int quality = 70,
    int? targetWidth,
    int? targetHeight,
    ImageFormat outputFormat = ImageFormat.jpg,
    bool saveToGallery = true,
  }) async {
    try {
      // Use FileService to get the images directory (DCIM/FlitPDF/Images/MultipleImages)
      final Directory outputDir = await FileService().getImagesDirectory();
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String extension = _getExtension(outputFormat);
      final String outputPath = '${outputDir.path}/FlitPDFcompressed_$timestamp.$extension';

      final String? result = await compute(
        _compressImageIsolate,
        _CompressImageData(
          inputPath: inputPath,
          outputPath: outputPath,
          quality: quality,
          width: targetWidth,
          height: targetHeight,
          format: extension,
        ),
      );

      // Optionally save to Gallery for visibility in Gallery apps and WhatsApp
      if (result != null && saveToGallery) {
        await FileService().saveImageToGallery(result);
      }

      return result;
    } catch (e) {
      debugPrint('Error in compressImage: $e');
      return null;
    }
  }

  /// Compress multiple images in batch
  /// Returns list of paths to compressed images
  Future<List<String>> compressImages(
    List<String> inputPaths, {
    int quality = 70,
    void Function(int current, int total)? onProgress,
  }) async {
    final List<String> results = <String>[];

    for (int i = 0; i < inputPaths.length; i++) {
      onProgress?.call(i + 1, inputPaths.length);

      final String? result = await compressImage(
        inputPaths[i],
        quality: quality,
      );

      if (result != null) {
        results.add(result);
      }
    }

    return results;
  }

  /// Resize image to specific dimensions
  Future<String?> resizeImage(
    String inputPath, {
    required int targetWidth,
    required int targetHeight,
    ImageFormat outputFormat = ImageFormat.jpg,
    int quality = 90,
  }) async {
    return compressImage(
      inputPath,
      quality: quality,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      outputFormat: outputFormat,
    );
  }

  /// Convert image to different format
  Future<String?> convertImage(
    String inputPath, {
    required ImageFormat targetFormat,
    int quality = 85,
    bool saveToGallery = true,
  }) async {
    try {
      // Use FileService to get the images directory (DCIM/FlitPDF/Images/MultipleImages)
      final Directory outputDir = await FileService().getImagesDirectory();
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String extension = _getExtension(targetFormat);
      final String outputPath = '${outputDir.path}/converted_$timestamp.$extension';

      final Uint8List? result = await FlutterImageCompress.compressWithFile(
        inputPath,
        quality: quality,
        format: _getCompressFormat(extension),
      );

      if (result != null) {
        final File outputFile = File(outputPath);
        await outputFile.writeAsBytes(result);

        // Optionally save to Gallery for visibility
        if (saveToGallery) {
          await FileService().saveImageToGallery(outputPath);
        }

        return outputPath;
      }

      return null;
    } catch (e) {
      debugPrint('Error converting image: $e');
      return null;
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Get output directory for images (DCIM/FlitPDF/Images/MultipleImages)
  Future<Directory> getOutputDirectory() async {
    return await FileService().getImagesDirectory();
  }

  /// Format file size to human readable string
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get quality value from enum
  int getQualityValue(ImageQuality quality, {int customValue = 70}) {
    switch (quality) {
      case ImageQuality.low:
        return 30;
      case ImageQuality.medium:
        return 50;
      case ImageQuality.high:
        return 80;
      case ImageQuality.custom:
        return customValue;
    }
  }

  String _getExtension(ImageFormat format) {
    switch (format) {
      case ImageFormat.png:
        return 'png';
      case ImageFormat.webp:
        return 'webp';
      case ImageFormat.jpg:
        return 'jpg';
    }
  }
}
