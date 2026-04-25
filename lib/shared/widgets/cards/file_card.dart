import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class FileCard extends StatelessWidget {
  final String name;
  final String size;
  final String date;
  final String type;
  final VoidCallback? onOpen;
  final VoidCallback? onEdit;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const FileCard({
    super.key,
    required this.name,
    required this.size,
    required this.date,
    required this.type,
    this.onOpen,
    this.onEdit,
    this.onRename,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = Theme.of(context).cardTheme.color ?? 
        (isDark ? AppColors.cardDark : AppColors.card);
    final Color textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final Color subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 0.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: isDark ? Colors.black26 : AppColors.shadow,
                blurRadius: 15,
                offset: const Offset(0, 8),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTypeColor(type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getTypeIcon(type),
                      color: _getTypeColor(type),
                      size: 24,
                    ),
                  ),
                  _buildMoreMenu(context),
                ],
              ),
              const Spacer(),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Text(
                    size,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: subTextColor.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      date,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<void>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        size: 20,
      ),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<void>>[
        if (onOpen != null)
          _buildPopupItem(Icons.visibility_outlined, 'Open', onOpen!),
        if (onEdit != null)
          _buildPopupItem(Icons.edit_outlined, 'Edit', onEdit!),
        if (onRename != null)
          _buildPopupItem(Icons.drive_file_rename_outline, 'Rename', onRename!),
        if (onDelete != null)
          _buildPopupItem(
            Icons.delete_outline_rounded,
            'Delete',
            onDelete!,
            isDestructive: true,
          ),
      ],
    );
  }

  PopupMenuItem<void> _buildPopupItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<void>(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 18,
            color: isDestructive ? AppColors.error : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDestructive ? AppColors.error : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'docx':
      case 'doc':
        return Icons.description_rounded;
      case 'xlsx':
      case 'xls':
        return Icons.table_chart_rounded;
      case 'pptx':
      case 'ppt':
        return Icons.slideshow_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return AppColors.error;
      case 'docx':
      case 'doc':
        return AppColors.info;
      case 'xlsx':
      case 'xls':
        return AppColors.success;
      case 'pptx':
      case 'ppt':
        return AppColors.warning;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }
}

// Example usage in a responsive grid/list
class ResponsiveFileGrid extends StatelessWidget {
  final List<FileItem> files;

  const ResponsiveFileGrid({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Calculate number of columns based on available width
        int crossAxisCount = 2;

        if (constraints.maxWidth > 1200) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9, // Adjust this for card height/width ratio
          ),
          itemCount: files.length,
          itemBuilder: (BuildContext context, int index) {
            final FileItem file = files[index];
            return FileCard(
              name: file.name,
              size: file.size,
              date: file.date,
              type: file.type,
            );
          },
        );
      },
    );
  }
}

// Example data model
class FileItem {
  final String name;
  final String size;
  final String date;
  final String type;

  FileItem({
    required this.name,
    required this.size,
    required this.date,
    required this.type,
  });
}
