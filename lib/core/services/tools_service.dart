import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'file_service.dart';

/// Data class for images to PDF conversion in isolate
class _ImagesToPdfData {
  final List<String> imagePaths;
  final String outputPath;

  _ImagesToPdfData({required this.imagePaths, required this.outputPath});
}

/// Data class for PDF compression in isolate
class _CompressPdfData {
  final String inputPath;
  final String outputPath;
  final String mode;
  final String? level;
  final double? targetSizeKB;

  _CompressPdfData({
    required this.inputPath,
    required this.outputPath,
    required this.mode,
    this.level,
    this.targetSizeKB,
  });
}

/// Data class for image compression in isolate
class _CompressImageData {
  final String inputPath;
  final String outputPath;
  final int quality;

  _CompressImageData({
    required this.inputPath,
    required this.outputPath,
    required this.quality,
  });
}

/// Isolate entry point: Convert images to PDF
Future<String?> _imagesToPdfIsolate(_ImagesToPdfData data) async {
  try {
    final pw.Document pdf = pw.Document();

    for (final String imagePath in data.imagePaths) {
      final Uint8List imageBytes = await File(imagePath).readAsBytes();
      final pw.MemoryImage image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) =>
              pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ),
      );
    }

    final File file = File(data.outputPath);
    await file.writeAsBytes(await pdf.save());

    return data.outputPath;
  } catch (e) {
    return null;
  }
}

/// Isolate entry point: Compress PDF
Future<String?> _compressPdfIsolate(_CompressPdfData data) async {
  try {
    final File inputFile = File(data.inputPath);
    if (!await inputFile.exists()) return null;

    final Uint8List inputBytes = await inputFile.readAsBytes();
    Uint8List compressedBytes;

    if (data.mode == 'manual' &&
        data.targetSizeKB != null &&
        data.targetSizeKB! > 0) {
      compressedBytes = await _compressToTargetSizeIsolate(
        inputBytes,
        data.targetSizeKB! * 1024,
      );
    } else {
      int quality = 85;
      if (data.level == 'Low') {
        quality = 95;
      } else if (data.level == 'Medium') {
        quality = 75;
      } else if (data.level == 'High') {
        quality = 50;
      }

      compressedBytes = await _compressWithQualityIsolate(inputBytes, quality);
    }

    final File outputFile = File(data.outputPath);
    await outputFile.writeAsBytes(compressedBytes);

    return data.outputPath;
  } catch (e) {
    return null;
  }
}

/// Isolate entry point: Compress image
Future<String?> _compressImageIsolate(_CompressImageData data) async {
  try {
    final Uint8List bytes = await File(data.inputPath).readAsBytes();
    final img.Image? image = img.decodeImage(bytes);

    if (image == null) return null;

    final Uint8List compressed = img.encodeJpg(image, quality: data.quality);

    final File file = File(data.outputPath);
    await file.writeAsBytes(compressed);

    return data.outputPath;
  } catch (e) {
    return null;
  }
}

/// Compress PDF with specified quality setting (runs in isolate)
Future<Uint8List> _compressWithQualityIsolate(
  Uint8List pdfBytes,
  int quality,
) async {
  try {
    final List<Uint8List> extractedImages = _extractPdfImages(pdfBytes);

    if (extractedImages.isNotEmpty) {
      final List<Uint8List> compressedImages = <Uint8List>[];

      for (final Uint8List imageBytes in extractedImages) {
        final img.Image? image = img.decodeImage(imageBytes);
        if (image != null) {
          int scaleFactor = 100;
          if (quality <= 50) {
            scaleFactor = 60;
          } else if (quality <= 75) {
            scaleFactor = 80;
          } else {
            scaleFactor = 95;
          }

          final img.Image resized = img.copyResize(
            image,
            width: (image.width * scaleFactor ~/ 100).clamp(1, image.width),
            height: (image.height * scaleFactor ~/ 100).clamp(1, image.height),
          );

          final Uint8List compressed = img.encodeJpg(resized, quality: quality);
          compressedImages.add(compressed);
        } else {
          compressedImages.add(imageBytes);
        }
      }

      return _replacePdfImages(pdfBytes, compressedImages);
    }

    return _optimizePdfStream(pdfBytes);
  } catch (e) {
    return pdfBytes;
  }
}

/// Optimize PDF streams for compression
Uint8List _optimizePdfStream(Uint8List pdfBytes) {
  try {
    String pdfText = String.fromCharCodes(pdfBytes);
    pdfText = pdfText.replaceAll(RegExp(r'%[^\n]*\n'), '\n');
    pdfText = pdfText.replaceAll(RegExp(r'\s+'), ' ');

    return Uint8List.fromList(pdfText.codeUnits);
  } catch (e) {
    return pdfBytes;
  }
}

/// Extract images from PDF bytes
List<Uint8List> _extractPdfImages(Uint8List pdfBytes) {
  final List<Uint8List> images = <Uint8List>[];

  try {
    int offset = 0;

    while (offset < pdfBytes.length - 1) {
      if (pdfBytes[offset] == 0xFF && pdfBytes[offset + 1] == 0xD8) {
        int endOffset = offset + 2;
        while (endOffset < pdfBytes.length - 1) {
          if (pdfBytes[endOffset] == 0xFF && pdfBytes[endOffset + 1] == 0xD9) {
            endOffset += 2;
            images.add(pdfBytes.sublist(offset, endOffset));
            offset = endOffset;
            break;
          }
          endOffset++;
        }
      } else {
        offset++;
      }
    }
  } catch (e) {
    // Silent fail
  }

  return images;
}

/// Replace images in PDF
Uint8List _replacePdfImages(
  Uint8List originalBytes,
  List<Uint8List> compressedImages,
) {
  try {
    Uint8List result = originalBytes;
    int imageIndex = 0;
    int offset = 0;

    while (offset < result.length - 1 && imageIndex < compressedImages.length) {
      if (result[offset] == 0xFF && result[offset + 1] == 0xD8) {
        int endOffset = offset + 2;
        while (endOffset < result.length - 1) {
          if (result[endOffset] == 0xFF && result[endOffset + 1] == 0xD9) {
            endOffset += 2;
            break;
          }
          endOffset++;
        }

        final Uint8List before = result.sublist(0, offset);
        final Uint8List after = result.sublist(endOffset);
        final Uint8List compressed = compressedImages[imageIndex];

        result = Uint8List.fromList(<int>[...before, ...compressed, ...after]);

        offset += compressed.length;
        imageIndex++;
      } else {
        offset++;
      }
    }

    return result;
  } catch (e) {
    return originalBytes;
  }
}

/// Compress PDF to target size by iteratively reducing quality
Future<Uint8List> _compressToTargetSizeIsolate(
  Uint8List pdfBytes,
  double targetBytes,
) async {
  if (pdfBytes.lengthInBytes <= targetBytes) {
    return pdfBytes;
  }

  for (int quality = 95; quality >= 30; quality -= 10) {
    final Uint8List compressed = await _compressWithQualityIsolate(
      pdfBytes,
      quality,
    );

    if (compressed.lengthInBytes <= targetBytes) {
      return compressed;
    }
  }

  return await _compressWithQualityIsolate(pdfBytes, 20);
}

class ToolsService {
  /// Pick files (images, pdfs, etc.)
  Future<List<PlatformFile>?> pickFiles({
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );
      return result?.files;
    } catch (e) {
      return null;
    }
  }

  /// Convert Images to PDF (runs in isolate)
  Future<String?> imagesToPdf(List<String> imagePaths) async {
    if (imagePaths.isEmpty) return null;

    try {
      // Use FileService to get the documents directory
      final Directory output = await FileService().getDocumentsDirectory();
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String outputPath =
          '${output.path}/FlitPDFconverted_$timestamp.pdf';

      final String? result = await compute(
        _imagesToPdfIsolate,
        _ImagesToPdfData(imagePaths: imagePaths, outputPath: outputPath),
      );

      return result;
    } catch (e) {
      return null;
    }
  }

  /// Merge multiple PDFs into one (simplified, no isolate needed for placeholder)
  Future<String?> mergePdfs(List<String> pdfPaths) async {
    if (pdfPaths.length < 2) return null;

    try {
      final pw.Document pdf = pw.Document();

      for (final String pdfPath in pdfPaths) {
        final pw.Document tempDoc = pw.Document();
        tempDoc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) =>
                pw.Center(child: pw.Text('Merged: $pdfPath')),
          ),
        );
      }

      // Use FileService to get the documents directory
      final Directory output = await FileService().getDocumentsDirectory();
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final File file = File('${output.path}/FlitPDFmerged_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Compress Image (runs in isolate)
  Future<String?> compressImage(String imagePath, {int quality = 70}) async {
    try {
      // Use FileService to get the images directory
      final Directory output = await FileService().getImagesDirectory();
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String outputPath =
          '${output.path}/FlitPDFcompressed_$timestamp.jpg';

      final String? result = await compute(
        _compressImageIsolate,
        _CompressImageData(
          inputPath: imagePath,
          outputPath: outputPath,
          quality: quality,
        ),
      );

      // Save to Gallery for visibility in Gallery apps and WhatsApp
      if (result != null) {
        await FileService().saveImageToGallery(result);
      }

      return result;
    } catch (e) {
      return null;
    }
  }

  /// Convert PDF to Images (returns list of image paths)
  Future<List<String>?> pdfToImages(String pdfPath) async {
    return null;
  }

  /// Get output directory for documents (Documents/FlitPDF)
  Future<Directory> getOutputDirectory() async {
    return await FileService().getDocumentsDirectory();
  }

  /// Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Compress PDF with auto levels or manual target size (runs in isolate)
  Future<String?> compressPdf(
    String inputPath, {
    String mode = 'auto',
    String? level,
    double? targetSizeKB,
  }) async {
    try {
      // Use FileService to get the documents directory
      final Directory outputDir = await FileService().getDocumentsDirectory();
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String outputPath =
          '${outputDir.path}/FlitPDFcompressed_$timestamp.pdf';

      final String? result = await compute(
        _compressPdfIsolate,
        _CompressPdfData(
          inputPath: inputPath,
          outputPath: outputPath,
          mode: mode,
          level: level,
          targetSizeKB: targetSizeKB,
        ),
      );

      return result;
    } catch (e) {
      return null;
    }
  }
}
