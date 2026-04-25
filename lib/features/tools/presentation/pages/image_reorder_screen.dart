import 'dart:io';

import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flitpdf/core/services/tools_service.dart';
import 'package:flitpdf/features/tools/presentation/widgets/image_preview_dialog.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ImageReorderScreen extends StatefulWidget {
  final List<String> imagePaths;

  const ImageReorderScreen({super.key, required this.imagePaths});

  @override
  State<ImageReorderScreen> createState() => _ImageReorderScreenState();
}

class _ImageReorderScreenState extends State<ImageReorderScreen> {
  late List<String> _reorderedImages;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _reorderedImages = List<String>.from(widget.imagePaths);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = _reorderedImages.removeAt(oldIndex);
      _reorderedImages.insert(newIndex, item);
    });
  }

  void _onCardTap(int index) {
    ImagePreviewDialog.show(
      context,
      imagePath: _reorderedImages[index],
      pageNumber: index + 1,
    );
  }

  Future<void> _generatePdf() async {
    if (_reorderedImages.isEmpty) return;

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final ToolsService toolsService = ToolsService();
      final String? result = await toolsService.imagesToPdf(_reorderedImages);

      if (result != null && mounted) {
        _showSuccessAndShare(result);
      } else if (mounted) {
        _showError('Failed to create PDF');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  void _showSuccessAndShare(String filePath) {
    final String fileName = filePath.split('/').last;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            const Icon(Icons.picture_as_pdf, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'PDF created: $fileName',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        duration: const Duration(seconds: 4),

        action: SnackBarAction(
          label: 'Share',
          textColor: Colors.white,
          onPressed: () => _shareFile(filePath),
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'PDF Created Successfully',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        content: Text(
          'Your PDF with ${_reorderedImages.length} pages has been created.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _shareFile(filePath);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Share PDF'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareFile(String filePath) async {
    try {
      await Share.shareXFiles(<XFile>[XFile(filePath)]);
    } catch (e) {
      _showError('Could not share file');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reorder Pages',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_reorderedImages.length} pages',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Instructions

          // Reorderable list
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reorderedImages.length,
              onReorder: _onReorder,
              buildDefaultDragHandles: false,
              itemBuilder: (BuildContext context, int index) {
                return ReorderableDragStartListener(
                  key: ValueKey<String>(_reorderedImages[index]),
                  index: index,
                  child: _ImageCard(
                    imagePath: _reorderedImages[index],
                    pageNumber: index + 1,
                    onTap: () => _onCardTap(index),
                  ),
                );
              },
            ),
          ),
          // Generate PDF button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingPdf ? null : _generatePdf,
                  icon: _isGeneratingPdf
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(
                    _isGeneratingPdf ? 'Generating PDF...' : 'Generate PDF',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imagePath;
  final int pageNumber;
  final VoidCallback onTap;

  const _ImageCard({
    required this.imagePath,
    required this.pageNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: AppColors.shadow,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 100,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: <Widget>[
                // Thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) {
                            return Container(
                              color: AppColors.surface,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                    ),
                  ),
                ),
                // Page info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Page $pageNumber',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          imagePath.split('/').last,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.preview,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to preview',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Drag handle indicator
                Container(
                  width: 48,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.drag_indicator,
                      color: AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
