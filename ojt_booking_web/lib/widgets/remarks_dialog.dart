import 'package:flutter/material.dart';

class RemarksDialog extends StatefulWidget {
  final String title;
  final String bookingNumber;

  const RemarksDialog({
    super.key,
    required this.title,
    required this.bookingNumber,
  });

  @override
  State<RemarksDialog> createState() => _RemarksDialogState();

  /// Show remarks dialog for booking cancellation
  static Future<String?> showCancelRemarks(
    BuildContext context, {
    required String bookingNumber,
  }) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          RemarksDialog(title: 'CONFIRM CANCEL', bookingNumber: bookingNumber),
    );
    return result;
  }
}

class _RemarksDialogState extends State<RemarksDialog> {
  final TextEditingController _remarksController = TextEditingController();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            // Remarks Label
            const Text(
              'Remarks:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Remarks TextField
            TextField(
              controller: _remarksController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter cancellation remarks...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 32),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 12),
                // Confirm Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(_remarksController.text.trim());
                  },
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
                    'CONFIRM',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
