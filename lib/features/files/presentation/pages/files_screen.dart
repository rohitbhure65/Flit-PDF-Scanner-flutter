import 'dart:io';

import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flitpdf/core/services/storage_service.dart';
import 'package:flitpdf/features/files/presentation/pages/pdf_viewer_screen.dart';
import 'package:flitpdf/shared/controllers/main_shell_controller.dart';
import 'package:flitpdf/shared/widgets/loading/pdf_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:share_plus/share_plus.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final StorageService _storageService = StorageService();
  final MainShellController _mainShellController =
      Get.find<MainShellController>();

  Map<String, double> _storageInfo = <String, double>{
    'total': 0.0,
    'used': 0.0,
    'free': 0.0,
    'files': 0.0,
    'images': 0.0,
    'documents': 0.0,
    'all': 0.0,
  };

  List<FileInfo> _files = <FileInfo>[];
  bool _isLoading = true;
  bool _isLoadingFiles = true;
  String _selectedFilter = 'All';
  final List<String> _filters = <String>[
    'All',
    'PDF',
    'Images',
    'Documents',
    'Others',
  ];

  bool _permissionsDenied = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  String? _highlightedFilePath;

  // View mode: true = grid, false = list
  bool _isGridView = false;
  Worker? _pendingFileWorker;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
    _pendingFileWorker = ever<String?>(_mainShellController.pendingFilePathRx, (
      String? filePath,
    ) {
      if (filePath == null || filePath.isEmpty) {
        return;
      }

      _showPendingPdf(filePath);
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    await _loadStorageInfo();
    await _loadFiles();
  }

  Future<void> _showPendingPdf(String filePath) async {
    if (_selectedFilter != 'PDF') {
      setState(() {
        _selectedFilter = 'PDF';
      });
    }

    if (_isSearching) {
      setState(() {
        _isSearching = false;
      });
    }

    _searchController.clear();

    await _loadData();

    if (!mounted) {
      return;
    }

    final bool fileExists = _files.any(
      (FileInfo file) => file.path == filePath,
    );

    setState(() {
      _highlightedFilePath = fileExists ? filePath : null;
    });

    _mainShellController.clearPendingFilePath();

    if (!fileExists) {
      _showFilesSnackBar(
        'PDF refreshed, but it is not available in My Files yet',
      );
      return;
    }

    _showFilesSnackBar('Showing ${filePath.split('/').last} in My Files');
  }

  void _showFilesSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    if (!Platform.isAndroid) return;

    await <Permission>[
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    final PermissionStatus status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      setState(() {
        _permissionsDenied = true;
      });
    }
  }

  Future<void> _loadStorageInfo() async {
    await _requestPermissions();

    final Map<String, double> info = await _storageService.getStorageInfo();
    if (mounted) {
      setState(() {
        _storageInfo = info;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFiles() async {
    if (!mounted) return;
    setState(() {
      _isLoadingFiles = true;
    });

    await _requestPermissions();

    try {
      final String? filterType = _selectedFilter == 'All'
          ? null
          : _selectedFilter;
      final List<FileInfo> files = await _storageService.getDeviceFiles(
        filterType: filterType,
      );
      if (mounted) {
        setState(() {
          _files = files;
          _isLoadingFiles = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFiles = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load files')));
      }
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadFiles();
  }

  Future<void> _openFile(FileInfo file) async {
    if (file.extension.toLowerCase() == 'pdf') {
      await _openPdfViewer(file);
      return;
    }

    try {
      final OpenResult result = await OpenFilex.open(file.path);
      if (result.type == ResultType.done) {
        await _storageService.addRecentFile(file);
      }
      if (result.type != ResultType.done && mounted) {
        _showFilesSnackBar('Cannot open file: ${result.message}');
      }
    } catch (e) {
      if (mounted) {
        _showFilesSnackBar('Error opening file: $e');
      }
    }
  }

  Future<void> _openPdfViewer(FileInfo file) async {
    final File pdfFile = File(file.path);
    if (!await pdfFile.exists()) {
      if (mounted) {
        _showFilesSnackBar('PDF not found: ${file.name}');
      }
      return;
    }

    if (!mounted) {
      return;
    }

    await _storageService.addRecentFile(file);

    await Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            PdfViewerScreen(filePath: file.path, title: file.name),
      ),
    );
  }

  Future<void> _shareFile(FileInfo file) async {
    try {
      await Share.shareXFiles(<XFile>[
        XFile(file.path),
      ], text: 'Shared file: ${file.name}');
    } catch (e) {
      if (mounted) {
        _showFilesSnackBar('Error sharing file: $e');
      }
    }
  }

  Future<void> _deleteFile(FileInfo file) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Delete File',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        backgroundColor: Colors.white,
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final File fileToDelete = File(file.path);
        await fileToDelete.delete();
        if (mounted) {
          _showFilesSnackBar('File deleted successfully');
          _loadFiles();
          _loadStorageInfo();
        }
      } catch (e) {
        if (mounted) {
          _showFilesSnackBar('Error deleting file: $e');
        }
      }
    }
  }

  Future<void> _renameFile(FileInfo file) async {
    final TextEditingController controller = TextEditingController(
      text: file.name,
    );
    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Rename File',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != file.name) {
      try {
        final File oldFile = File(file.path);
        final String sanitizedName = newName.trim();
        final String finalName = sanitizedName.contains('.')
            ? sanitizedName
            : '$sanitizedName.${file.extension}';
        final String newPath = '${file.directory}/$finalName';
        await oldFile.rename(newPath);
        if (mounted) {
          _showFilesSnackBar('File renamed successfully');
          _loadFiles();
        }
      } catch (e) {
        if (mounted) {
          _showFilesSnackBar('Error renaming file: $e');
        }
      }
    }
  }

  Future<void> _handleFileAction(String action, FileInfo file) async {
    switch (action) {
      case 'open':
        await _openFile(file);
        break;
      case 'share':
        await _shareFile(file);
        break;
      case 'delete':
        await _deleteFile(file);
        break;
      case 'rename':
        await _renameFile(file);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              // Header
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  centerTitle: false,
                  title: Text(
                    'My Files',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                    icon: Icon(
                      _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchQuery = '';
                          _searchController.clear();
                        }
                      });
                    },
                    icon: Icon(
                      _isSearching ? Icons.close_rounded : Icons.search_rounded,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Search Bar
              if (_isSearching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search files...',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchQuery = '';
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),

              // Storage Info Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStorageCard(),
                ),
              ),

              // Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 0, 16),
                  child: _buildFilterChips(),
                ),
              ),

              // Files List/Grid
              _isLoadingFiles 
                ? SliverToBoxAdapter(
                    child: _isGridView ? _buildGridLoadingShimmer() : _buildFilesLoadingShimmer(),
                  )
                : _filteredFiles.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  : _isGridView 
                    ? SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) => _buildGridItem(_filteredFiles[index]),
                            childCount: _filteredFiles.length,
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) => _buildFileItem(_filteredFiles[index]),
                            childCount: _filteredFiles.length,
                          ),
                        ),
                      ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 200,
              child: RiveAnimation.asset(
                'assets/animations/5078-10234-search-rive.riv',
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _permissionsDenied ? 'Permission Required' : 'No files found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _permissionsDenied
                  ? 'Grant storage permission to scan your files'
                  : 'Try adjusting your filters or search query',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_permissionsDenied) ...<Widget>[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: openAppSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Open Settings'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double totalStorage = _storageInfo['total'] ?? 0.0;
    final double usedStorage = _storageInfo['used'] ?? 0.0;
    final double usedPercentage = totalStorage > 0 ? (usedStorage / totalStorage) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? <Color>[AppColors.primary, AppColors.primaryDark]
              : <Color>[AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Storage',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Space: ${_storageService.formatBytes(totalStorage)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(usedPercentage * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: <Widget>[
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: usedPercentage,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildStorageInfoItem(Icons.folder_rounded, 'Files', _storageInfo['files'] ?? 0),
                    _buildStorageInfoItem(Icons.image_rounded, 'Images', _storageInfo['images'] ?? 0),
                    _buildStorageInfoItem(Icons.description_rounded, 'Docs', _storageInfo['all'] ?? 0),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStorageInfoItem(IconData icon, String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _storageService.formatBytes(value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (BuildContext context, int index) {
          final bool isSelected = _filters[index] == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (_) => _onFilterChanged(_filters[index]),
              labelStyle: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected 
                      ? AppColors.primary 
                      : (isDark ? AppColors.borderDark : AppColors.border),
                  width: 1,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: isSelected ? 4 : 0,
              pressElevation: 0,
            ),
          );
        },
      ),
    );
  }

  List<FileInfo> get _filteredFiles {
    final List<FileInfo> filteredFiles = _files
        .where(
          (FileInfo file) => file.name.toLowerCase().contains(_searchQuery),
        )
        .toList();

    if (_highlightedFilePath == null) {
      return filteredFiles;
    }

    filteredFiles.sort((FileInfo a, FileInfo b) {
      if (a.path == _highlightedFilePath) {
        return -1;
      }
      if (b.path == _highlightedFilePath) {
        return 1;
      }
      return b.modified.compareTo(a.modified);
    });

    return filteredFiles;
  }

  @override
  void dispose() {
    _pendingFileWorker?.dispose();
    _searchController.dispose();
    super.dispose();
  }
  Widget _buildFilesLoadingShimmer() {
    return PdfShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: <Widget>[
                PdfShimmerBox(width: 52, height: 52, radius: 14),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      PdfShimmerBox(width: double.infinity, height: 14),
                      PdfShimmerBox(
                        width: 180,
                        height: 12,
                        margin: EdgeInsets.only(top: 10),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                PdfShimmerBox(width: 24, height: 24, radius: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridLoadingShimmer() {
    return PdfShimmer(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: 6,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    PdfShimmerBox(width: 52, height: 52, radius: 14),
                    PdfShimmerBox(width: 20, height: 20, radius: 10),
                  ],
                ),
                Spacer(),
                PdfShimmerBox(width: double.infinity, height: 14),
                PdfShimmerBox(
                  width: 110,
                  height: 12,
                  margin: EdgeInsets.only(top: 10),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridItem(FileInfo file) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isHighlighted = file.path == _highlightedFilePath;

    return GestureDetector(
      onTap: () => _openFile(file),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted 
                ? AppColors.primary 
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isHighlighted ? 2 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isDark ? Colors.black26 : AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getTypeColor(file.extension).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(file.extension),
                    color: _getTypeColor(file.extension),
                    size: 24,
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    cardColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (String value) async {
                      await _handleFileAction(value, file);
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      _buildPopupItem('open', Icons.open_in_new_rounded, 'Open', isDark),
                      _buildPopupItem('share', Icons.share_rounded, 'Share', isDark),
                      _buildPopupItem('rename', Icons.edit_rounded, 'Rename', isDark),
                      const PopupMenuDivider(),
                      _buildPopupItem('delete', Icons.delete_outline_rounded, 'Delete', isDark, isError: true),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              file.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              '${file.formattedSize} • ${file.formattedDate}',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(FileInfo file) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isHighlighted = file.path == _highlightedFilePath;

    return GestureDetector(
      onTap: () => _openFile(file),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted 
                ? AppColors.primary 
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isHighlighted ? 2 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isDark ? Colors.black26 : AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getTypeColor(file.extension).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getTypeIcon(file.extension),
                color: _getTypeColor(file.extension),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    file.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Text(
                        file.formattedSize,
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '•',
                          style: TextStyle(color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.5) : AppColors.textSecondary.withValues(alpha: 0.5)),
                        ),
                      ),
                      Text(
                        file.formattedDate,
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                cardColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              ),
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (String value) async {
                  await _handleFileAction(value, file);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  _buildPopupItem('open', Icons.open_in_new_rounded, 'Open', isDark),
                  _buildPopupItem('share', Icons.share_rounded, 'Share', isDark),
                  _buildPopupItem('rename', Icons.edit_rounded, 'Rename', isDark),
                  const PopupMenuDivider(),
                  _buildPopupItem('delete', Icons.delete_outline_rounded, 'Delete', isDark, isError: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label, bool isDark, {bool isError = false}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 20,
            color: isError 
                ? AppColors.error 
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isError 
                  ? AppColors.error 
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
        return Icons.image;
      case 'txt':
      case 'rtf':
        return Icons.article;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return AppColors.error;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return AppColors.success;
      case 'ppt':
      case 'pptx':
        return AppColors.warning;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }
}
