// ignore: implementation_imports
import 'package:file_picker/src/platform_file.dart';
import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flitpdf/core/services/tools_service.dart';
import 'package:flitpdf/features/files/presentation/pages/pdf_viewer_screen.dart';
import 'package:flitpdf/features/tools/presentation/pages/compress_image_screen.dart';
import 'package:flitpdf/features/tools/presentation/pages/compress_pdf_screen.dart';
import 'package:flitpdf/features/tools/presentation/pages/image_reorder_screen.dart';
import 'package:flitpdf/shared/controllers/main_shell_controller.dart';
import 'package:flitpdf/shared/widgets/loading/pdf_shimmer.dart';
import 'package:flitpdf/shared/widgets/typography/modern_section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final ToolsService _toolsService = ToolsService();
  bool _isProcessing = false;
  bool _showPdfLoadingOverlay = false;
  String _processingTitle = 'Preparing PDF...';
  String _processingSubtitle =
      'Please wait while we import your file and get it ready.';

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 100,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    centerTitle: false,
                    title: Text(
                      'Tools',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const ModernSectionHeader(title: 'PDF Utilities'),
                      _buildToolsGrid(_getPdfTools()),
                      const SizedBox(height: 32),
                      const ModernSectionHeader(title: 'Image Utilities'),
                      _buildToolsGrid(_getImageTools()),
                      const SizedBox(height: 120), // Space for bottom bar
                    ],
                  ),
                ),
              ],
            ),
            if (_isProcessing && _showPdfLoadingOverlay)
              PdfLoadingOverlay(
                title: _processingTitle,
                subtitle: _processingSubtitle,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsGrid(List<Map<String, dynamic>> tools) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: tools.length,
        itemBuilder: (BuildContext context, int index) {
          final Map<String, dynamic> tool = tools[index];
          return _buildToolItem(
            icon: tool['icon'] as IconData,
            label: tool['name'] as String,
            color: tool['color'] as Color,
            onTap: tool['onTap'] as VoidCallback?,
            isComingSoon: tool['isComingSoon'] as bool? ?? false,
          );
        },
      ),
    );
  }

  Widget _buildToolItem({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool isComingSoon = false,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color displayColor = isComingSoon
        ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
        : color;

    return GestureDetector(
      onTap: isComingSoon ? () => _showComingSoonSnackBar(label) : onTap,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
                boxShadow: <BoxShadow>[
                  if (!isComingSoon)
                    BoxShadow(
                      color: isDark ? Colors.black26 : AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    color: isComingSoon
                        ? displayColor.withValues(alpha: 0.3)
                        : displayColor,
                    size: 28,
                  ),
                  if (isComingSoon)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isComingSoon
                  ? displayColor.withValues(alpha: 0.5)
                  : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _handleToolAction(String toolName) async {
    if (_isProcessing) return;

    // Check if tool is coming soon
    if (_isToolComingSoon(toolName)) {
      _showSnackBar('$toolName coming soon!');
      return;
    }

    _setProcessingMessage(toolName);
    setState(() {
      _isProcessing = true;
      _showPdfLoadingOverlay = _isPdfLoadingAction(toolName);
    });

    try {
      switch (toolName) {
        case 'Image to PDF':
          await _convertImagesToPdf();
          break;
        case 'Compress PDF':
          await _compressPdf();
          break;
        case 'Open PDF':
          await _openPdf();
          break;
        case 'Scan PDF':
          await _scanPdf();
          break;
        case 'Create PDF':
          await _createPdf();
          break;
        case 'Compress Image':
          await _compressImage();
          break;
        default:
          _showSnackBar('$toolName coming soon!');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _showPdfLoadingOverlay = false;
        });
      }
    }
  }

  bool _isPdfLoadingAction(String toolName) {
    return <String>{
      'Image to PDF',
      'Compress PDF',
      'Open PDF',
      'Create PDF',
    }.contains(toolName);
  }

  bool _isToolComingSoon(String toolName) {
    return <String>{
      'Merge PDF',
      'PDF to JPG',
      'Convert to JPG',
      'Resize Images',
    }.contains(toolName);
  }

  void _setProcessingMessage(String toolName) {
    switch (toolName) {
      case 'Image to PDF':
      case 'Create PDF':
        _processingTitle = 'Building PDF...';
        _processingSubtitle =
            'Images are being imported and arranged into a PDF document.';
        break;
      case 'Open PDF':
        _processingTitle = 'Loading PDF...';
        _processingSubtitle =
            'The selected PDF is being prepared so it can open smoothly.';
        break;
      case 'Compress PDF':
        _processingTitle = 'Preparing PDF...';
        _processingSubtitle =
            'Please wait while we load the selected PDF file.';
        break;
      default:
        _processingTitle = 'Processing files...';
        _processingSubtitle =
            'Please wait while we import your file and finish the task.';
    }
  }

  Future<void> _convertImagesToPdf() async {
    final List<PlatformFile>? files = await _toolsService.pickFiles(
      allowedExtensions: <String>['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: true,
    );

    if (files == null || files.isEmpty) {
      return;
    }

    // Filter out any files without valid paths
    final List<String> imagePaths = files
        .where((PlatformFile f) => f.path != null && f.path!.isNotEmpty)
        .map((PlatformFile f) => f.path!)
        .toList();

    if (imagePaths.isEmpty) {
      _showSnackBar('No valid images found');
      return;
    }

    // Navigate to reorder screen with selected images
    if (mounted) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              ImageReorderScreen(imagePaths: imagePaths),
        ),
      );
    }
  }

  Future<void> _compressPdf() async {
    final List<PlatformFile>? files = await _toolsService.pickFiles(
      allowedExtensions: <String>['pdf'],
      allowMultiple: false,
    );

    if (files == null || files.isEmpty) return;

    if (mounted && files.first.path != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              CompressPdfScreen(initialPdfPath: files.first.path!),
        ),
      );
    }
  }

  Future<void> _openPdf() async {
    final List<PlatformFile>? files = await _toolsService.pickFiles(
      allowedExtensions: <String>['pdf'],
      allowMultiple: false,
    );

    if (files == null || files.isEmpty) return;
    if (files.first.path == null) return;

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => PdfViewerScreen(
            filePath: files.first.path!,
            title: files.first.name,
          ),
        ),
      );
    }
  }

  Future<void> _scanPdf() async {
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().changePage(0);
    }
  }

  Future<void> _createPdf() async {
    final List<PlatformFile>? files = await _toolsService.pickFiles(
      allowedExtensions: <String>['jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );

    if (files == null || files.isEmpty) return;

    // Filter out any files without valid paths
    final List<String> imagePaths = files
        .where((PlatformFile f) => f.path != null && f.path!.isNotEmpty)
        .map((PlatformFile f) => f.path!)
        .toList();

    if (imagePaths.isEmpty) {
      _showSnackBar('No valid images found');
      return;
    }

    // Navigate to reorder screen with selected images
    if (mounted) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              ImageReorderScreen(imagePaths: imagePaths),
        ),
      );
    }
  }

  Future<void> _compressImage() async {
    final List<PlatformFile>? files = await _toolsService.pickFiles(
      allowedExtensions: <String>['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: false,
    );

    if (files == null || files.isEmpty) return;

    if (mounted && files.first.path != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              CompressImageScreen(initialImagePath: files.first.path!),
        ),
      );
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

  void _showComingSoonSnackBar(String toolName) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  children: <TextSpan>[
                    TextSpan(
                      text: toolName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' — Coming Soon!'),
                  ],
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<Map<String, dynamic>> _getPdfTools() {
    return <Map<String, dynamic>>[
      // Available Tools
      <String, dynamic>{
        'name': 'Image to PDF',
        'icon': Icons.picture_as_pdf,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Image to PDF'),
      },
      <String, dynamic>{
        'name': 'Compress PDF',
        'icon': Icons.compress,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Compress PDF'),
      },
      <String, dynamic>{
        'name': 'Scan PDF',
        'icon': Icons.document_scanner,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Scan PDF'),
      },
      <String, dynamic>{
        'name': 'Open PDF',
        'icon': Icons.open_in_new,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Open PDF'),
      },
      <String, dynamic>{
        'name': 'Create PDF',
        'icon': Icons.add_circle,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Create PDF'),
      },
      // Coming Soon Tools
      <String, dynamic>{
        'name': 'Word to PDF',
        'icon': Icons.description,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Word to PDF'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Excel to PDF',
        'icon': Icons.table_chart,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Excel to PDF'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'PPTX to PDF',
        'icon': Icons.slideshow,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('PPTX to PDF'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Merge PDF',
        'icon': Icons.merge_type,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Merge PDF'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'PDF to Word',
        'icon': Icons.text_snippet,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('PDF to Word'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'PDF to Excel',
        'icon': Icons.grid_on,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('PDF to Excel'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'PDF to PPTX',
        'icon': Icons.vertical_split,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('PDF to PPTX'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'PDF to JPG',
        'icon': Icons.image,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('PDF to JPG'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Extract Text',
        'icon': Icons.text_fields,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Extract Text'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Edit PDF',
        'icon': Icons.edit,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Edit PDF'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Unlock PDF',
        'icon': Icons.lock_open,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Unlock PDF'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Sign PDF',
        'icon': Icons.draw,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Sign PDF'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Watermark',
        'icon': Icons.waves,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Watermark'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Rotate PDF',
        'icon': Icons.rotate_right,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Rotate PDF'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Page Number',
        'icon': Icons.format_list_numbered,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Page Number'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Repair PDF',
        'icon': Icons.build,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Repair PDF'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'OCR PDF',
        'icon': Icons.document_scanner,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('OCR PDF'),
        'isComingSoon': true,
      },
    ];
  }

  List<Map<String, dynamic>> _getImageTools() {
    return <Map<String, dynamic>>[
      // Available Tools
      <String, dynamic>{
        'name': 'Compress Image',
        'icon': Icons.compress,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Compress Image'),
      },
      // Coming Soon Tools
      <String, dynamic>{
        'name': 'Convert to JPG',
        'icon': Icons.image,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Convert to JPG'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Convert from JPG',
        'icon': Icons.swap_horiz,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Convert from JPG'),
        'isComingSoon': true,
      },
      <String, dynamic>{
        'name': 'Resize Images',
        'icon': Icons.aspect_ratio,
        'color': AppColors.primary,
        'onTap': () => _handleToolAction('Resize Images'),
        'isComingSoon': true,
      },
    ];
  }
}
