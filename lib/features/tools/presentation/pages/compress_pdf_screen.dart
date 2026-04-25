// ignore: implementation_imports
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flitpdf/core/services/tools_service.dart';
import 'package:flitpdf/shared/widgets/loading/pdf_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class CompressPdfScreen extends StatefulWidget {
  final String? initialPdfPath;

  const CompressPdfScreen({super.key, this.initialPdfPath});

  @override
  State<CompressPdfScreen> createState() => _CompressPdfScreenState();
}

class _CompressPdfScreenState extends State<CompressPdfScreen> {
  PlatformFile? _selectedFile;
  String? _originalSize;
  bool _isManual = false;
  String _selectedLevel = 'High'; // Low, Medium, High
  String _targetSize = '';
  String _selectedUnit = 'KB';
  bool _isCompressing = false;
  String? _outputPath;
  String? _compressedSize;
  final ToolsService _toolsService = ToolsService();

  @override
  void initState() {
    super.initState();
    if (widget.initialPdfPath != null) {
      _loadInitialFile(widget.initialPdfPath!);
    }
  }

  Future<void> _loadInitialFile(String path) async {
    final File file = File(path);
    if (await file.exists()) {
      final int size = await file.length();
      setState(() {
        _selectedFile = PlatformFile(
          name: p.basename(path),
          path: path,
          size: size,
        );
        _originalSize = _toolsService.formatFileSize(size);
      });
    }
  }

  Future<void> _pickPdf() async {
    final List<PlatformFile>? files = await _toolsService.pickFiles(
      allowedExtensions: <String>['pdf'],
      allowMultiple: false,
    );
    if (files != null && files.isNotEmpty) {
      setState(() {
        _selectedFile = files.first;
        _originalSize = _toolsService.formatFileSize(_selectedFile!.size);
        _outputPath = null;
        _compressedSize = null;
      });
    }
  }

  Future<void> _compressPdf() async {
    if (_selectedFile == null || _selectedFile!.path == null) return;

    setState(() {
      _isCompressing = true;
    });

    try {
      final String resultPath =
          await _toolsService.compressPdf(
            _selectedFile!.path!,
            mode: _isManual ? 'manual' : 'auto',
            level: _isManual ? null : _selectedLevel,
            targetSizeKB: _isManual
                ? (double.tryParse(_targetSize) ?? 0) *
                      (_selectedUnit == 'MB' ? 1024 : 1)
                : null,
          ) ??
          '';

      if (resultPath.isNotEmpty && mounted) {
        final File outputFile = File(resultPath);
        final int outputSize = await outputFile.length();
        setState(() {
          _outputPath = resultPath;
          _compressedSize = _toolsService.formatFileSize(outputSize);
        });
        _showSnackBar('PDF compressed successfully!');
      }
    } catch (e) {
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

  Widget _buildFileCard() {
    if (_selectedFile == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.picture_as_pdf,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text('No PDF selected', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select PDF'),
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
        child: Row(
          children: <Widget>[
            Icon(Icons.picture_as_pdf, size: 48, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _selectedFile!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Original: $_originalSize'),
                  if (_compressedSize != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      'Compressed: $_compressedSize',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _pickPdf),
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
                DropdownMenuItem<String>(value: 'Low', child: Text('Low')),
                DropdownMenuItem<String>(
                  value: 'Medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem<String>(value: 'High', child: Text('High')),
              ],
              onChanged: (String? value) =>
                  setState(() => _selectedLevel = value!),
            ),
          ],
        ),
      ),
    );
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
                    controller: TextEditingController(text: _targetSize),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),

                      labelText: 'Size',
                    ),

                    onChanged: (String value) =>
                        setState(() => _targetSize = value),
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
        title: const Text('Compress PDF'),
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
                      onPressed: _isCompressing || _selectedFile == null
                          ? null
                          : _compressPdf,
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
                        _isCompressing ? 'Compressing...' : 'Compress PDF',
                      ),
                    ),
                  ),
                  if (_outputPath != null) ...<Widget>[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _shareFile(_outputPath!),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isCompressing)
            const PdfLoadingOverlay(
              title: 'Compressing PDF',
              subtitle: 'Optimizing images...',
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
