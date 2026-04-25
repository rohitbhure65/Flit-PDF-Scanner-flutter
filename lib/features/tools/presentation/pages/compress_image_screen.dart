import 'dart:io';
import 'dart:typed_data';

import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flitpdf/core/services/image_service.dart';
import 'package:flitpdf/shared/widgets/loading/pdf_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class CompressImageScreen extends StatefulWidget {
  final String? initialImagePath;

  const CompressImageScreen({super.key, this.initialImagePath});

  @override
  State<CompressImageScreen> createState() => _CompressImageScreenState();
}

class _CompressImageScreenState extends State<CompressImageScreen> {
  final ImageService _imageService = ImageService();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedPath;
  int? _originalBytes;
  bool _isManual = false;
  String _selectedLevel = 'Medium';
  final TextEditingController _targetSizeController = TextEditingController(
    text: '500',
  );
  String _selectedUnit = 'KB';
  bool _isCompressing = false;
  String? _outputPath;
  int? _compressedBytes;
  double? _compressionRatio;

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null) {
      _loadInitialFile(widget.initialImagePath!);
    }
  }

  @override
  void dispose() {
    _targetSizeController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialFile(String path) async {
    final File file = File(path);
    if (await file.exists()) {
      final int size = await file.length();
      setState(() {
        _selectedPath = path;
        _originalBytes = size;
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  _setSelectedImage(image.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  _setSelectedImage(image.path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setSelectedImage(String path) async {
    final File file = File(path);
    final int size = await file.length();
    setState(() {
      _selectedPath = path;
      _originalBytes = size;
      _outputPath = null;
      _compressedBytes = null;
      _compressionRatio = null;
    });
  }

  Future<void> _compressImage() async {
    if (_selectedPath == null || _originalBytes == null) return;

    setState(() {
      _isCompressing = true;
    });

    try {
      int quality;
      if (_isManual) {
        // Manual mode: target size in KB or MB
        final double sizeValue =
            double.tryParse(_targetSizeController.text) ?? 500;
        final int targetBytes = _selectedUnit == 'MB'
            ? (sizeValue * 1024 * 1024).toInt()
            : (sizeValue * 1024).toInt();

        // Calculate quality based on target size vs original
        if (_originalBytes! > 0 && targetBytes > 0) {
          quality = ((targetBytes / _originalBytes!) * 100)
              .clamp(10, 100)
              .toInt();
        } else {
          quality = 70;
        }
      } else {
        // Auto mode: use preset quality
        switch (_selectedLevel) {
          case 'Low':
            quality = 90;
            break;
          case 'Medium':
            quality = 70;
            break;
          case 'High':
            quality = 50;
            break;
          default:
            quality = 70;
        }
      }

      debugPrint('Starting compression with quality: $quality');

      // Get output directory
      final Directory outputDir = await _imageService.getOutputDirectory();
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String outputPath = '${outputDir.path}/FlitPDFcompressed_$timestamp.jpg';

      // Read original image
      final File originalFile = File(_selectedPath!);
      final Uint8List originalBytes = await originalFile.readAsBytes();

      // Decode and compress using the image package
      final img.Image? image = img.decodeImage(originalBytes);
      if (image == null) {
        if (mounted) {
          _showSnackBar('Failed to read image');
        }
        return;
      }

      // Encode with quality (1-100 maps to 1-100 for JPEG)
      final Uint8List compressedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );

      debugPrint(
        'Original size: ${originalBytes.length}, Compressed size: ${compressedBytes.length}',
      );

      // Save compressed image
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(compressedBytes);

      final int compressedSize = await outputFile.length();

      setState(() {
        _outputPath = outputPath;
        _compressedBytes = compressedSize;
        _compressionRatio = _originalBytes! > 0
            ? ((_originalBytes! - compressedSize) / _originalBytes! * 100)
            : 0;
      });

      if (mounted) {
        _showSnackBar('Image compressed successfully!');
      }
    } catch (e) {
      debugPrint('Compression error: $e');
      if (mounted) {
        _showSnackBar('Compression failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompressing = false;
        });
      }
    }
  }

  String get _originalSizeFormatted {
    if (_originalBytes == null) return 'Unknown';
    return _imageService.formatFileSize(_originalBytes!);
  }

  String get _compressedSizeFormatted {
    if (_compressedBytes == null) return '';
    return _imageService.formatFileSize(_compressedBytes!);
  }

  Widget _buildFileCard() {
    if (_selectedPath == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              const Icon(Icons.image, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text('No image selected', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Image'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_selectedPath!),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return Container(
                        height: 150,
                        color: AppColors.border,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        ),
                      );
                    },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        p.basename(_selectedPath!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('Original: $_originalSizeFormatted'),
                      if (_compressedBytes != null) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          'Compressed: $_compressedSizeFormatted',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_compressionRatio != null && _compressionRatio! > 0)
                          Text(
                            'Saved: ${_compressionRatio!.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _pickImage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Mode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isManual ? AppColors.primary : null,
                      foregroundColor: !_isManual ? Colors.white : null,
                    ),
                    onPressed: () => setState(() => _isManual = false),
                    child: const Text('Auto'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isManual ? AppColors.primary : null,
                      foregroundColor: _isManual ? Colors.white : null,
                    ),
                    onPressed: () => setState(() => _isManual = true),
                    child: const Text('Manual'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoOptions() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Compression Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedLevel,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Level',
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'Low',
                  child: Text('Low (90% quality)'),
                ),
                DropdownMenuItem<String>(
                  value: 'Medium',
                  child: Text('Medium (70% quality)'),
                ),
                DropdownMenuItem<String>(
                  value: 'High',
                  child: Text('High (50% quality)'),
                ),
              ],
              onChanged: (String? value) =>
                  setState(() => _selectedLevel = value!),
            ),
            const SizedBox(height: 8),
            Text(
              _getLevelDescription(_selectedLevel),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelDescription(String level) {
    switch (level) {
      case 'Low':
        return 'Best quality, minimal compression. Best for printing.';
      case 'Medium':
        return 'Balanced quality and size. Good for most uses.';
      case 'High':
        return 'Smallest file size, lower quality. Best for sharing.';
      default:
        return '';
    }
  }

  Widget _buildManualOptions() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Target File Size',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _targetSizeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Size',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedUnit,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: 'KB',
                          child: Text('KB'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'MB',
                          child: Text('MB'),
                        ),
                      ],
                      onChanged: (String? value) =>
                          setState(() => _selectedUnit = value!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Smaller target size = more compression',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Compress Image'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 100,
              ),
              child: Column(
                children: <Widget>[
                  _buildFileCard(),
                  const SizedBox(height: 16),
                  _buildModeToggle(),
                  const SizedBox(height: 16),
                  if (!_isManual) _buildAutoOptions(),
                  if (_isManual) _buildManualOptions(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCompressing || _selectedPath == null
                          ? null
                          : _compressImage,
                      icon: _isCompressing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.compress),
                      label: Text(
                        _isCompressing ? 'Compressing...' : 'Compress Image',
                      ),
                    ),
                  ),
                  if (_outputPath != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _viewFile(_outputPath!),
                            icon: const Icon(Icons.visibility),
                            label: const Text('View'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _shareFile(_outputPath!),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isCompressing)
            const PdfLoadingOverlay(
              title: 'Compressing Image',
              subtitle: 'Optimizing...',
            ),
        ],
      ),
    );
  }

  Future<void> _shareFile(String path) async {
    try {
      await Share.shareXFiles(<XFile>[XFile(path)]);
    } catch (e) {
      _showSnackBar('File saved at: $path');
    }
  }

  Future<void> _viewFile(String path) async {
    // Show a dialog to preview the compressed image
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppBar(
              title: const Text('Compressed Image'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              automaticallyImplyLeading: false,
            ),
            Flexible(child: Image.file(File(path), fit: BoxFit.contain)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _shareFile(path);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
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
}
