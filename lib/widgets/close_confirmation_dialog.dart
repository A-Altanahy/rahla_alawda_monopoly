import 'package:flutter/material.dart';
import 'save_dialog.dart';

enum CloseAction { save, discard, cancel }

class CloseConfirmationDialog extends StatelessWidget {
  const CloseConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.exit_to_app, color: Colors.orange),
          SizedBox(width: 8),
          Text('إغلاق التطبيق'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هل تريد حفظ اللعبة الحالية قبل الإغلاق؟',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            'إذا لم تقم بالحفظ، ستفقد تقدم اللعبة الحالية.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, CloseAction.cancel),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, CloseAction.discard),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('إغلاق بدون حفظ'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context, CloseAction.save);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('حفظ وإغلاق'),
        ),
      ],
    );
  }
}

// Function to show close confirmation dialog
Future<CloseAction?> showCloseConfirmationDialog(BuildContext context) {
  return showDialog<CloseAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const CloseConfirmationDialog(),
  );
}

// Function to handle the close action with save dialog
Future<bool> handleCloseAction(BuildContext context) async {
  final action = await showCloseConfirmationDialog(context);
  
  switch (action) {
    case CloseAction.save:
      // Show save dialog
      final saved = await showSaveDialog(context);
      // Only close if save was successful (or user cancelled save dialog but still wants to close)
      return saved ?? false;
    case CloseAction.discard:
      return true;
    case CloseAction.cancel:
    case null:
      return false;
  }
} 