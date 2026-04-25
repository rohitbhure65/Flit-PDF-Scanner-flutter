import 'dart:io';

import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flitpdf/shared/controllers/main_shell_controller.dart';
import 'package:flitpdf/shared/widgets/loading/pdf_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../widgets/document_scanner.dart';
import 'image_preview_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  static const MethodChannel _scannerFilesChannel = MethodChannel(
    'flitpdf/scanner_files',
  );
  final ImagePicker _picker = ImagePicker();
  final List<String> _scannedImages = <String>[];
  bool _isProcessing = false;
  bool _isImportingImages = false;
  int? _draggingIndex;
  int? _targetIndex;

  Future<void> _openDocumentScanner() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => DocumentScanner(
          onImagesScanned: (List<String> paths) async {
            await _addScannedImages(paths, fromScanner: true);
          },
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isImportingImages = true;
    });

    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        await _addScannedImages(
          images.map((XFile e) => e.path).toList(),
          fromScanner: false,
        );
      }
    } catch (e) {
      _showSnackBar('Error picking images: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isImportingImages = false;
        });
      }
    }
  }

  Future<void> _showAddMoreOptions() async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Add More Pages',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to add more document pages.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAddMoreOption(
                  icon: Icons.document_scanner,
                  title: 'Scan More',
                  subtitle: 'Capture additional document pages',
                  onTap: () async {
                    Navigator.pop(context);
                    await _openDocumentScanner();
                  },
                ),
                const SizedBox(height: 12),
                _buildAddMoreOption(
                  icon: Icons.photo_library,
                  title: 'Gallery',
                  subtitle: 'Import more pages from your photos',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addScannedImages(
    List<String> paths, {
    required bool fromScanner,
  }) async {
    final List<String> normalizedPaths = await _normalizeScannedPaths(
      paths,
      fromScanner: fromScanner,
    );

    final List<String> newPaths = normalizedPaths
        .map((String path) => path.trim())
        .where((String path) => path.isNotEmpty)
        .where((String path) => !_scannedImages.contains(path))
        .toList();

    if (!mounted) {
      return;
    }

    if (newPaths.isEmpty) {
      _showSnackBar('No new document pages were added');
      return;
    }

    setState(() {
      _scannedImages.addAll(newPaths);
    });

    final String pageLabel = newPaths.length == 1 ? 'page' : 'pages';
    _showSnackBar('${newPaths.length} $pageLabel added successfully');
  }

  Future<List<String>> _normalizeScannedPaths(
    List<String> paths, {
    required bool fromScanner,
  }) async {
    final List<String> cleanedPaths = paths
        .map((String path) => path.trim())
        .where((String path) => path.isNotEmpty)
        .toList();

    if (!Platform.isAndroid || cleanedPaths.isEmpty) {
      return cleanedPaths;
    }

    try {
      final String methodName = fromScanner
          ? 'persistUrisToCache'
          : 'persistImagesToCache';
      final String argumentKey = fromScanner ? 'uris' : 'paths';

      final List<dynamic>? persistedPaths = await _scannerFilesChannel
          .invokeMethod<List<dynamic>>(methodName, <String, dynamic>{
            argumentKey: cleanedPaths,
          });

      if (persistedPaths == null || persistedPaths.isEmpty) {
        return cleanedPaths;
      }

      return persistedPaths
          .whereType<String>()
          .map((String path) => path.trim())
          .where((String path) => path.isNotEmpty)
          .toList();
    } on PlatformException {
      return cleanedPaths;
    }
  }

  Future<void> _convertToPdf() async {
    if (_scannedImages.isEmpty) {
      _showSnackBar('Please scan or select images first');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final pw.Document pdf = pw.Document();
      final List<String> validPages = <String>[];

      for (final String imagePath in _scannedImages) {
        try {
          final Uint8List imageBytes = await XFile(imagePath).readAsBytes();
          final pw.MemoryImage image = pw.MemoryImage(imageBytes);
          validPages.add(imagePath);

          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                );
              },
            ),
          );
        } catch (_) {
          continue;
        }
      }

      if (validPages.isEmpty) {
        _showSnackBar('No valid document pages available to convert');
        return;
      }

      if (validPages.length != _scannedImages.length && mounted) {
        setState(() {
          _scannedImages
            ..clear()
            ..addAll(validPages);
        });
      }

      final Directory output = await getApplicationDocumentsDirectory();
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final File file = File('${output.path}/FlitPDFScanner_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      _showPdfCreatedSnackBar(file);

      if (mounted) {
        setState(() {
          _scannedImages.clear();
        });
      }
    } catch (e) {
      _showSnackBar('Error creating PDF: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showPdfCreatedSnackBar(File file) {
    final String fileName = file.path.split('/').last;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF created: $fileName'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'View PDF',
          textColor: Colors.white,
          onPressed: () {
            if (!Get.isRegistered<MainShellController>()) {
              return;
            }

            Get.find<MainShellController>().showFileInFilesPage(file.path);
          },
        ),
      ),
    );
  }

  void _clearAll() {
    if (_scannedImages.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Clear All',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        content: const Text(
          'Are you sure you want to clear all scanned images?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _scannedImages.clear();
              });
              Navigator.pop(context);
              _showSnackBar('All images cleared');
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _removeImage(int index) {
    if (index < 0 || index >= _scannedImages.length) {
      return;
    }

    setState(() {
      _scannedImages.removeAt(index);
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= _scannedImages.length) return;
    if (newIndex < 0 || newIndex >= _scannedImages.length) return;

    setState(() {
      final String item = _scannedImages.removeAt(oldIndex);
      _scannedImages.insert(newIndex, item);
    });
  }

  void _openImagePreview(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ImagePreviewScreen(
          imagePaths: _scannedImages,
          initialIndex: initialIndex,
          onDelete: (int index) {
            setState(() {
              _scannedImages.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Scanner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (_scannedImages.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        'Clear All',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _scannedImages.isEmpty
                        ? _buildEmptyState()
                        : _buildScannedImages(),
                  ),
                  if (_isImportingImages) _buildImportingOverlay(),
                ],
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: <Color>[
                  AppColors.primary.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Lottie.asset(
              'assets/animations/multifile.json',
              alignment: Alignment.center,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Smart Document Scanner',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Turn your physical documents into professional PDFs with AI-powered enhancement.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildOptionButton(
                icon: Icons.document_scanner_rounded,
                label: 'Doc Scanner',
                onTap: _openDocumentScanner,
                isPrimary: true,
              ),
              const SizedBox(width: 20),
              _buildOptionButton(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: _pickFromGallery,
                isPrimary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(24),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
          boxShadow: <BoxShadow>[
            if (isPrimary)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            else
              BoxShadow(
                color: isDark ? Colors.black26 : AppColors.shadow,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isPrimary
                    ? Colors.white
                    : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportingOverlay() {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Importing images...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please wait while we load your photos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScannedImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                '${_scannedImages.length} Page${_scannedImages.length > 1 ? 's' : ''} Selected',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: _openDocumentScanner,
              icon: const Icon(Icons.document_scanner_outlined, size: 18),
              label: const Text('Scan More'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StatefulBuilder(
            builder:
                (
                  BuildContext context,
                  void Function(void Function()) setState,
                ) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: _scannedImages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return LongPressDraggable<int>(
                        data: index,
                        delay: const Duration(milliseconds: 200),
                        feedback: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 3 - 20,
                            height:
                                (MediaQuery.of(context).size.width / 3 - 20) /
                                0.75,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildImageThumbnail(
                                index,
                                isDragging: true,
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _buildImageThumbnail(index),
                        ),
                        onDragStarted: () {
                          setState(() {
                            _draggingIndex = index;
                          });
                        },
                        onDragEnd: (_) {
                          setState(() {
                            _draggingIndex = null;
                            _targetIndex = null;
                          });
                        },
                        child: DragTarget<int>(
                          onWillAcceptWithDetails:
                              (DragTargetDetails<int> data) {
                                if (data.data != index) {
                                  setState(() {
                                    _targetIndex = index;
                                  });
                                  return true;
                                }
                                return false;
                              },
                          onLeave: (_) {
                            if (_targetIndex == index) {
                              setState(() {
                                _targetIndex = null;
                              });
                            }
                          },
                          onAcceptWithDetails: (DragTargetDetails<int> data) {
                            _reorderImages(data.data, index);
                            setState(() {
                              _targetIndex = null;
                            });
                          },
                          builder:
                              (
                                BuildContext context,
                                List<int?> candidateData,
                                List<dynamic> rejectedData,
                              ) {
                                final bool isTarget =
                                    _targetIndex == index &&
                                    _draggingIndex != null &&
                                    _draggingIndex != index;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: isTarget
                                      ? Matrix4.diagonal3Values(0.95, 0.95, 1.0)
                                      : Matrix4.identity(),
                                  transformAlignment: Alignment.center,
                                  child: isTarget
                                      ? Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColors.primary,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: _buildImageThumbnail(index),
                                        )
                                      : _buildImageThumbnail(index),
                                );
                              },
                        ),
                      );
                    },
                  );
                },
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(int index, {bool isDragging = false}) {
    final String imagePath = _scannedImages[index];

    return GestureDetector(
      onTap: () => _openImagePreview(index),
      child: Stack(
        children: <Widget>[
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FutureBuilder<Uint8List>(
                future: XFile(imagePath).readAsBytes(),
                builder:
                    (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ImagePreviewLoading();
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildImagePreviewFallback();
                      }

                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        gaplessPlayback: true,
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return _buildImagePreviewFallback();
                            },
                      );
                    },
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Page ${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.drag_handle,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreviewFallback() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.insert_drive_file_outlined,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 8),
          Text(
            'Preview unavailable',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showAddMoreOptions,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add More'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _convertToPdf,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_isProcessing ? 'Processing...' : 'Convert to PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
