import 'package:flutter/material.dart';

class ErrorDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                // Message
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                // OK Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Specific error dialogs
  static void showOriginError(BuildContext context) {
    show(
      context: context,
      title: 'ORIGIN ERROR',
      message: 'Origin should not be the same with destination.',
    );
  }

  static void showDestinationError(BuildContext context) {
    show(
      context: context,
      title: 'DESTINATION ERROR',
      message: 'Destination should not be the same with origin.',
    );
  }

  static void showConfirmError(BuildContext context) {
    show(
      context: context,
      title: 'CONFIRM ERROR',
      message: 'Please input missing data.',
    );
  }

  static void showCancelError(
    BuildContext context, {
    required String bookingNumber,
  }) {
    show(
      context: context,
      title: 'CANCEL ERROR',
      message: 'Booking Number: $bookingNumber is already cancelled.',
    );
  }
}
