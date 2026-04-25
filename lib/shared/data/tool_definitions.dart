import 'package:flutter/material.dart';
import 'package:flitpdf/core/constants/app_colors.dart';

/// Tool definition data classes and constants for the PDF tools application.
///
/// This file centralizes tool definitions to make them easily maintainable
/// and accessible across different features of the application.

/// Available PDF tool definitions
const List<Map<String, dynamic>> pdfTools = <Map<String, dynamic>>[
  <String, dynamic>{
    'name': 'Image to PDF',
    'icon': Icons.picture_as_pdf,
    'color': AppColors.primary,
    'description': 'Convert images to PDF document',
  },
  <String, dynamic>{
    'name': 'Compress PDF',
    'icon': Icons.compress,
    'color': AppColors.primary,
    'description': 'Reduce PDF file size',
  },
  <String, dynamic>{
    'name': 'Scan PDF',
    'icon': Icons.document_scanner,
    'color': AppColors.primary,
    'description': 'Scan physical documents to PDF',
  },
  <String, dynamic>{
    'name': 'Open PDF',
    'icon': Icons.open_in_new,
    'color': AppColors.primary,
    'description': 'View PDF files',
  },
  <String, dynamic>{
    'name': 'Create PDF',
    'icon': Icons.add_circle,
    'color': AppColors.primary,
    'description': 'Create new PDF from images',
  },
];

/// Coming soon PDF tool definitions
const List<Map<String, dynamic>> pdfToolsComingSoon = <Map<String, dynamic>>[
  <String, dynamic>{
    'name': 'Word to PDF',
    'icon': Icons.description,
    'color': AppColors.primary,
    'description': 'Convert Word documents to PDF',
  },
  <String, dynamic>{
    'name': 'Excel to PDF',
    'icon': Icons.table_chart,
    'color': AppColors.primary,
    'description': 'Convert Excel spreadsheets to PDF',
  },
  <String, dynamic>{
    'name': 'PPTX to PDF',
    'icon': Icons.slideshow,
    'color': AppColors.primary,
    'description': 'Convert PowerPoint presentations to PDF',
  },
  <String, dynamic>{
    'name': 'Merge PDF',
    'icon': Icons.merge_type,
    'color': AppColors.primary,
    'description': 'Combine multiple PDFs',
  },
  <String, dynamic>{
    'name': 'PDF to Word',
    'icon': Icons.text_snippet,
    'color': AppColors.primary,
    'description': 'Convert PDF to Word document',
  },
  <String, dynamic>{
    'name': 'PDF to Excel',
    'icon': Icons.grid_on,
    'color': AppColors.primary,
    'description': 'Convert PDF to Excel spreadsheet',
  },
  <String, dynamic>{
    'name': 'PDF to PPTX',
    'icon': Icons.vertical_split,
    'color': AppColors.primary,
    'description': 'Convert PDF to PowerPoint',
  },
  <String, dynamic>{
    'name': 'PDF to JPG',
    'icon': Icons.image,
    'color': AppColors.primary,
    'description': 'Extract images from PDF',
  },
  <String, dynamic>{
    'name': 'Extract Text',
    'icon': Icons.text_fields,
    'color': AppColors.primary,
    'description': 'Extract text from PDF',
  },
  <String, dynamic>{
    'name': 'Edit PDF',
    'icon': Icons.edit,
    'color': AppColors.primary,
    'description': 'Edit PDF content',
  },
  <String, dynamic>{
    'name': 'Unlock PDF',
    'icon': Icons.lock_open,
    'color': AppColors.primary,
    'description': 'Remove PDF password protection',
  },
  <String, dynamic>{
    'name': 'Sign PDF',
    'icon': Icons.draw,
    'color': AppColors.primary,
    'description': 'Add signature to PDF',
  },
  <String, dynamic>{
    'name': 'Watermark',
    'icon': Icons.waves,
    'color': AppColors.primary,
    'description': 'Add watermark to PDF',
  },
  <String, dynamic>{
    'name': 'Rotate PDF',
    'icon': Icons.rotate_right,
    'color': AppColors.primary,
    'description': 'Rotate PDF pages',
  },
  <String, dynamic>{
    'name': 'Page Number',
    'icon': Icons.format_list_numbered,
    'color': AppColors.primary,
    'description': 'Add page numbers to PDF',
  },
  <String, dynamic>{
    'name': 'Repair PDF',
    'icon': Icons.build,
    'color': AppColors.primary,
    'description': 'Repair corrupted PDF',
  },
  <String, dynamic>{
    'name': 'OCR PDF',
    'icon': Icons.document_scanner,
    'color': AppColors.primary,
    'description': 'Optical character recognition',
  },
];

/// Available image tool definitions
const List<Map<String, dynamic>> imageTools = <Map<String, dynamic>>[
  <String, dynamic>{
    'name': 'Compress Image',
    'icon': Icons.compress,
    'color': AppColors.primary,
    'description': 'Reduce image file size',
  },
];

/// Coming soon image tool definitions
const List<Map<String, dynamic>> imageToolsComingSoon = <Map<String, dynamic>>[
  <String, dynamic>{
    'name': 'Convert to JPG',
    'icon': Icons.image,
    'color': AppColors.primary,
    'description': 'Convert images to JPG format',
  },
  <String, dynamic>{
    'name': 'Convert from JPG',
    'icon': Icons.swap_horiz,
    'color': AppColors.primary,
    'description': 'Convert JPG to other formats',
  },
  <String, dynamic>{
    'name': 'Resize Images',
    'icon': Icons.aspect_ratio,
    'color': AppColors.primary,
    'description': 'Batch resize images',
  },
];

/// Gets all popular tools for display on home screen
List<Map<String, dynamic>> getPopularTools() {
  return <Map<String, dynamic>>[
    <String, dynamic>{
      'name': 'Image to PDF',
      'icon': Icons.picture_as_pdf,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Compress PDF',
      'icon': Icons.compress,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Scan PDF',
      'icon': Icons.document_scanner,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Create PDF',
      'icon': Icons.add_circle,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Compress Image',
      'icon': Icons.compress,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Merge PDF',
      'icon': Icons.merge_type,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'PDF to JPG',
      'icon': Icons.image,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Extract Text',
      'icon': Icons.text_fields,
      'color': AppColors.primary,
    },
  ];
}

/// Gets all tool categories grouped together
List<Map<String, dynamic>> getAllTools() {
  return <Map<String, dynamic>>[
    <String, dynamic>{
      'name': 'Image to PDF',
      'icon': Icons.picture_as_pdf,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Compress PDF',
      'icon': Icons.compress,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Merge PDF',
      'icon': Icons.merge_type,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'PDF to JPG',
      'icon': Icons.image,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Scan PDF',
      'icon': Icons.document_scanner,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Create PDF',
      'icon': Icons.add_circle,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Compress Image',
      'icon': Icons.compress,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Extract Text',
      'icon': Icons.text_fields,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Edit PDF',
      'icon': Icons.edit,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Word to PDF',
      'icon': Icons.description,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'Excel to PDF',
      'icon': Icons.table_chart,
      'color': AppColors.primary,
    },
    <String, dynamic>{
      'name': 'PDF to Word',
      'icon': Icons.text_snippet,
      'color': AppColors.primary,
    },
  ];
}