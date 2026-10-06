import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';

class ProjectDocumentModel {
  final int id;
  final String title;
  final String fileUrl;
  final bool isConfidential;
  final DateTime? createdAt;

  const ProjectDocumentModel({
    required this.id,
    required this.title,
    required this.fileUrl,
    this.isConfidential = false,
    this.createdAt,
  });

  factory ProjectDocumentModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final title = json['title']?.toString() ?? 'Untitled Document';
    final rawFile =
        json['file']?.toString() ?? json['file_url']?.toString() ?? '';

    String fileUrl = rawFile;
    if (fileUrl.isNotEmpty &&
        !fileUrl.startsWith('http://') &&
        !fileUrl.startsWith('https://')) {
      final base = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final path = fileUrl.startsWith('/') ? fileUrl : '/$fileUrl';
      fileUrl = '$base$path';
    }

    final isConfidential = json['is_confidential'] == true;
    final createdAtStr = json['created_at']?.toString();
    final createdAt =
        createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

    return ProjectDocumentModel(
      id: id,
      title: title,
      fileUrl: fileUrl,
      isConfidential: isConfidential,
      createdAt: createdAt,
    );
  }

  /// Parses file extension from the file URL (or title if URL lacks extension)
  String get fileExtension {
    final target = fileUrl.isNotEmpty ? fileUrl : title;
    final clean = target.split('?').first.split('#').first;
    final dotIndex = clean.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < clean.length - 1) {
      return clean.substring(dotIndex + 1).toLowerCase();
    }
    return '';
  }

  /// Returns appropriate Material icon for the file type
  IconData get iconData {
    switch (fileExtension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'webp':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  /// Formats extension badge text (e.g. PDF, XLSX, DOC)
  String get extensionBadge {
    final ext = fileExtension;
    return ext.isNotEmpty ? ext.toUpperCase() : 'DOC';
  }
}
