import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/api_endpoints.dart';
import '../widgets/custom_snackbar.dart';

class ExternalLinkLauncher {
  ExternalLinkLauncher._();

  static Future<bool> openUrl(BuildContext context, String? urlString) async {
    var trimmed = urlString?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      if (context.mounted) {
        CustomSnackBar.error(context, "No document URL available.");
      }
      return false;
    }

    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      final base = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      trimmed = '$base$path';
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      if (context.mounted) {
        CustomSnackBar.error(context, "Invalid document URL.");
      }
      return false;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        CustomSnackBar.error(context, "Could not open document.");
      }
      return launched;
    } catch (_) {
      if (context.mounted) {
        CustomSnackBar.error(context, "Could not open document.");
      }
      return false;
    }
  }
}
