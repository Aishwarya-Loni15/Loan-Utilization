import 'dart:io';
import 'package:flutter/material.dart';

class MediaPreviewWidget extends StatelessWidget {
  final File? file;
  final String label;

  const MediaPreviewWidget({
    super.key,
    required this.file,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (file == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: ${file!.path.split('/').last}',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
