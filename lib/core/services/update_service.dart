import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  bool _isChecking = false;
  bool _updateStarted = false;

  /// Check for app updates and show dialog if available
  Future<void> checkForUpdate(BuildContext context) async {
    if (_isChecking || _updateStarted) return;
    _isChecking = true;

    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (context.mounted) {
          _showUpdateDialog(context, updateInfo);
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Show update available dialog
  void _showUpdateDialog(BuildContext context, AppUpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text(
          'Update Available',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        content: const Text(
          'A new version of the app is available. Would you like to update now?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Later', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _startImmediateUpdate(context);
            },
            child: const Text(
              'Update',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Start immediate update (user must stay on screen)
  Future<void> _startImmediateUpdate(BuildContext context) async {
    _updateStarted = true;

    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
        // If we get here, update was successful
        debugPrint('Update completed successfully');
      }
    } catch (e) {
      debugPrint('Error during immediate update: $e');
      if (context.mounted) {
        _showUpdateFailedSnackbar(context);
      }
      _updateStarted = false;
    }
  }

  /// Show snackbar when update fails
  void _showUpdateFailedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: <Widget>[
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('Update failed. Please try again later.'),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Reset update flag (can be called after app restart)
  void resetUpdateState() {
    _updateStarted = false;
  }
}
