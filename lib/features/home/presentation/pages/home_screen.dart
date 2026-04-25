import 'package:carousel_slider/carousel_slider.dart';
import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flitpdf/core/services/storage_service.dart';
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
            fontWeight: FontWeight.w900,
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

  Widget _buildBentoToolGrid(BuildContext context) {
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
        children: <Widget>[
          _buildBentoItem(
            context,
            'PDF to Word',
            Icons.description_rounded,
            AppColors.primary,
          ),
          _buildBentoItem(
            context,
            'Merge',
            Icons.merge_type_rounded,
            AppColors.primary,
          ),
          _buildBentoItem(
            context,
            'Compress',
            Icons.compress_rounded,
            AppColors.primary,
          ),
          _buildBentoItem(
            context,
            'Protect',
            Icons.lock_rounded,
            AppColors.primary,
          ),
          _buildBentoItem(
            context,
            'eSign',
            Icons.draw_rounded,
            AppColors.primary,
          ),
          _buildBentoItem(
            context,
            'OCR',
            Icons.text_fields_rounded,
            AppColors.primary,
          ),
          _buildBentoItem(
            context,
            'Organize',
            Icons.grid_view_rounded,
            AppColors.primary,
          ),
          _buildBentoItem(
            context,
            'Split',
            Icons.call_split_rounded,
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBentoItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {},
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
