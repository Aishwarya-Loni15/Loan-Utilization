import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class DocumentPickerWidget extends StatelessWidget {
  final File? documentFile;
  final ValueChanged<File> onDocumentPicked;

  const DocumentPickerWidget({
    super.key,
    required this.documentFile,
    required this.onDocumentPicked,
  });

  Future<void> _pickDocument(BuildContext context) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final ext = result.files.single.extension?.toLowerCase();

        if (!['pdf', 'jpg', 'jpeg', 'png'].contains(ext)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid file format. Allowed types: PDF, JPG, PNG.')),
            );
          }
          return;
        }

        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);

        if (sizeInMB > 10) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Document exceeds maximum size of 10MB (${sizeInMB.toStringAsFixed(1)}MB).')),
            );
          }
          return;
        }

        onDocumentPicked(file);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick document: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDoc = documentFile != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasDoc ? AppColors.success.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasDoc ? AppColors.success : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasDoc ? AppColors.success.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasDoc ? Icons.check_circle_rounded : Icons.description_rounded,
              color: hasDoc ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice / Voucher (PDF, JPG, PNG)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasDoc ? documentFile!.path.split('/').last : 'Upload official receipt or purchase invoice',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasDoc ? AppColors.success : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () => _pickDocument(context),
            child: Text(hasDoc ? 'Change' : 'Select'),
          ),
        ],
      ),
    );
  }
}
