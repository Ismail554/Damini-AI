import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api_endpoints.dart';
import '../services/dio_service.dart';
import '../widgets/custom_snackbar.dart';

class FileDownloader {
  FileDownloader._();

  /// Downloads file from [url] to device downloads/documents directory.
  /// Shows progress, error or success snackbar with an 'Open' action.
  static Future<String?> downloadFile(
    BuildContext context, {
    required String url,
    required String suggestedName,
    String? extension,
    void Function(double progress)? onProgress,
  }) async {
    var cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      if (context.mounted) {
        CustomSnackBar.error(context, "No download URL available.");
      }
      return null;
    }

    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      final base = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final path = cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl';
      cleanUrl = '$base$path';
    }

    try {
      Directory? dir;
      if (Platform.isAndroid) {
        try {
          dir = await getDownloadsDirectory();
        } catch (_) {}
        dir ??= await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      // Extract / resolve file extension
      String ext = (extension ?? '').replaceAll('.', '').trim().toLowerCase();
      if (ext.isEmpty) {
        final uriPath = cleanUrl.split('?').first.split('#').first;
        final dotIdx = uriPath.lastIndexOf('.');
        if (dotIdx != -1 && dotIdx < uriPath.length - 1) {
          ext = uriPath.substring(dotIdx + 1).toLowerCase();
        }
      }
      if (ext.isEmpty) ext = 'pdf';

      // Sanitize filename
      String safeBaseName = suggestedName
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          .trim();
      if (safeBaseName.isEmpty) safeBaseName = 'Document';

      String fileName = safeBaseName.toLowerCase().endsWith('.$ext')
          ? safeBaseName
          : '$safeBaseName.$ext';

      String savePath = '${dir.path}/$fileName';
      final existingFile = File(savePath);
      if (await existingFile.exists()) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final baseWithoutExt = fileName.substring(
          0,
          fileName.length - ext.length - 1,
        );
        fileName = '${baseWithoutExt}_$timestamp.$ext';
        savePath = '${dir.path}/$fileName';
      }

      if (context.mounted) {
        CustomSnackBar.info(context, "Starting download: $fileName");
      }

      // Try authenticated dio client first, fallback to standard client
      try {
        await DioService.client.download(
          cleanUrl,
          savePath,
          onReceiveProgress: (received, total) {
            if (total > 0 && onProgress != null) {
              onProgress(received / total);
            }
          },
        );
      } catch (_) {
        await Dio().download(
          cleanUrl,
          savePath,
          onReceiveProgress: (received, total) {
            if (total > 0 && onProgress != null) {
              onProgress(received / total);
            }
          },
        );
      }

      if (context.mounted) {
        CustomSnackBar.show(
          context,
          "Saved $fileName to device",
          actionLabel: "Open",
          onAction: () async {
            final res = await OpenFilex.open(savePath);
            if (res.type == ResultType.noAppToOpen && context.mounted) {
              CustomSnackBar.warning(
                context,
                "No app available to open this file.",
              );
            }
          },
        );
      }

      return savePath;
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.error(context, "Download failed: $e");
      }
      return null;
    }
  }
}
