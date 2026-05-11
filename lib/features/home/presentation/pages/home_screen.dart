import 'package:carousel_slider/carousel_slider.dart';
import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flitpdf/core/services/storage_service.dart';
import 'package:flitpdf/shared/controllers/main_shell_controller.dart';
import 'package:flitpdf/shared/data/tool_definitions.dart' as tool_defs;
import 'package:flitpdf/shared/widgets/cards/file_card.dart';
import 'package:flitpdf/shared/widgets/typography/modern_section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> getPopularTools() => tool_defs.getPopularTools();

  final StorageService _storageService = StorageService();
  List<RecentFileRecord> _recentFiles = <RecentFileRecord>[];
  bool _isLoadingRecentFiles = true;

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    try {
      final List<RecentFileRecord> recentFiles = await _storageService
          .getRecentFiles();
      if (recentFiles.isNotEmpty) {
        if (mounted) {
          setState(() {
            _recentFiles = recentFiles.take(4).toList();
            _isLoadingRecentFiles = false;
          });
        }
      } else {
        // Fallback to random 4 top files from device
        final List<FileInfo> deviceFiles = await _storageService.getDeviceFiles(
          limit: 4,
        );
        if (mounted) {
          setState(() {
            _recentFiles = deviceFiles
                .map((FileInfo f) => RecentFileRecord.fromFileInfo(f))
                .toList();
            _isLoadingRecentFiles = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecentFiles = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          _buildSliverAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                _buildPremiumCarousel(context),
                const SizedBox(height: 30),
                const ModernSectionHeader(title: 'Quick Tools'),
                const SizedBox(height: 16),
                _buildBentoToolGrid(context),
                const SizedBox(height: 24),
                _buildProBanner(context),
                const SizedBox(height: 24),
                ModernSectionHeader(
                  title: 'Recent Files',
                  actionLabel: 'View All',
                  onActionPressed: () {
                    // Navigate to Files tab
                  },
                ),
                const SizedBox(height: 16),
                _buildRecentFilesList(context),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        centerTitle: false,
        title: Text(
          'FlitPDF',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -1,
          ),
        ),
      ),
      actions: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              final bool currentlyDark =
                  Theme.of(context).brightness == Brightness.dark;
              Get.changeThemeMode(
                currentlyDark ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCarousel(BuildContext context) {
    final List<Map<String, dynamic>> items = <Map<String, dynamic>>[
      <String, dynamic>{
        'title': 'Scan Documents',
        'subtitle': 'AI-powered high quality scans',
        'icon': Icons.document_scanner_rounded,
        'color': AppColors.primary,
      },
      <String, dynamic>{
        'title': 'Sign & Fill',
        'subtitle': 'Easy electronic signatures',
        'icon': Icons.draw_rounded,
        'color': const Color(0xFF333333),
      },
      <String, dynamic>{
        'title': 'PDF to Office',
        'subtitle': 'Convert files with 99% accuracy',
        'icon': Icons.swap_horiz_rounded,
        'color': const Color.fromARGB(255, 255, 60, 0),
      },
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 134.0,
        enlargeCenterPage: false,
        autoPlay: true,
        viewportFraction: 1.0,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
      ),
      items: items.map((Map<String, dynamic> item) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    item['color'] as Color,
                    (item['color'] as Color).withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['subtitle'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Future<void> _openToolsForTool(BuildContext context, String toolName) async {
    // Open tool directly without navigation using bottom sheet or modal
    await _showToolBottomSheet(context, toolName);
  }

  Future<void> _showToolBottomSheet(
    BuildContext context,
    String toolName,
  ) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(_getToolIcon(toolName), size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                toolName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getToolDescription(toolName),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToTool(context, toolName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Open Tool',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getToolIcon(String toolName) {
    switch (toolName) {
      case 'Image to PDF':
        return Icons.picture_as_pdf;
      case 'Compress PDF':
        return Icons.compress;
      case 'Scan PDF':
        return Icons.document_scanner;
      case 'Create PDF':
        return Icons.add_circle;
      case 'Compress Image':
        return Icons.compress;
      default:
        return Icons.build;
    }
  }

  String _getToolDescription(String toolName) {
    switch (toolName) {
      case 'Image to PDF':
        return 'Convert images to PDF document quickly and easily.';
      case 'Compress PDF':
        return 'Reduce PDF file size without losing quality.';
      case 'Scan PDF':
        return 'Scan physical documents and convert to PDF.';
      case 'Create PDF':
        return 'Create new PDF from images or blank pages.';
      case 'Compress Image':
        return 'Reduce image file size while maintaining quality.';
      default:
        return 'Open this tool to get started.';
    }
  }

  void _navigateToTool(BuildContext context, String toolName) {
    // Navigate to the appropriate tool screen using MainShellController
    final MainShellController controller = Get.find<MainShellController>();
    
    switch (toolName) {
      case 'Scan PDF':
        // Navigate to scanner tab (index 0)
        controller.changePage(0);
        break;
      case 'Image to PDF':
      case 'Compress PDF':
      case 'Create PDF':
      case 'Compress Image':
        // Navigate to tools tab (index 3)
        controller.changePage(3);
        break;
      default:
        controller.changePage(3);
    }
  }

  Widget _buildBentoToolGrid(BuildContext context) {
    final List<Map<String, dynamic>> tools = getPopularTools();

    // Filter to only active/live tools
    final List<Map<String, dynamic>> activeTools = tools.where((
      Map<String, dynamic> t,
    ) {
      final bool? isActive = t['isActive'] as bool?;
      final String? status = t['status'] as String?;
      final bool isComingSoon = t['isComingSoon'] as bool? ?? false;

      final bool matchesActive = isActive ?? true;
      final bool matchesStatus = status == null ? true : status == 'live';
      return !isComingSoon && matchesActive && matchesStatus;
    }).toList();

    // Limit to 4 active tools only
    final List<Map<String, dynamic>> displayTools = activeTools
        .take(4)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: displayTools.map((Map<String, dynamic> tool) {
          return _buildBentoItem(
            context,
            tool['name'] as String,
            tool['icon'] as IconData,
            tool['color'] as Color,
            onTap: () {
              _openToolsForTool(context, tool['name'] as String);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBentoItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,

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
                  BoxShadow(
                    color: isDark ? Colors.black26 : AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[Icon(icon, color: color, size: 28)],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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

  Widget _buildProBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Upgrade to Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock unlimited conversions and cloud storage.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              _showSnackBar('Upgrade feature coming soon!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Upgrade',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFilesList(BuildContext context) {
    if (_isLoadingRecentFiles) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentFiles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(child: Text('No recent files found.')),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _recentFiles.length,
        itemBuilder: (BuildContext context, int index) {
          final RecentFileRecord file = _recentFiles[index];
          return FileCard(
            name: file.name,
            type: file.extension,
            size: file.toFileInfo().formattedSize,
            date: file.formattedOpenedAt,
          );
        },
      ),
    );
  }
}
