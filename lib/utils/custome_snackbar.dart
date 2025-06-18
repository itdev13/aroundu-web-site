
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter/material.dart';


/// Types of SnackBar for different message contexts
enum SnackBarType { success, error, warning, info }

/// A utility class to show custom styled SnackBars throughout the app
class CustomSnackBar {
  /// Shows a custom styled SnackBar with appropriate colors based on type
  ///
  /// [context] - BuildContext to show the SnackBar
  /// [message] - Message to display in the SnackBar
  /// [type] - Type of SnackBar (success, error, warning, info)
  /// [duration] - How long the SnackBar should be displayed
  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final Color backgroundColor;
    final Color textColor;
    final IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        kLogger.info("Error: $message");
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: textColor.withOpacity(0.2), width: 1),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: textColor,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
