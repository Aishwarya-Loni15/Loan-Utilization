import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class EvidencePickerWidget extends StatelessWidget {
  final File? photoFile;
  final File? videoFile;
  final File? documentFile;
  final VoidCallback onPickPhoto;
  final VoidCallback onPickVideo;
  final VoidCallback onPickDocument;

  const EvidencePickerWidget({
    super.key,
    required this.photoFile,
    required this.videoFile,
    required this.documentFile,
    required this.onPickPhoto,
    required this.onPickVideo,
    required this.onPickDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence Media Artifacts',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context,
                title: 'Geotag Photo',
                icon: Icons.camera_alt_outlined,
                file: photoFile,
                onTap: onPickPhoto,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTile(
                context,
                title: 'Site Video',
                icon: Icons.videocam_outlined,
                file: videoFile,
                onTap: onPickVideo,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTile(
                context,
                title: 'Invoice / Doc',
                icon: Icons.receipt_long_outlined,
                file: documentFile,
                onTap: onPickDocument,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
  }) {
    final hasFile = file != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: hasFile ? AppColors.success.withValues(alpha: 0.1) : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? AppColors.success : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.check_circle : icon,
              color: hasFile ? AppColors.success : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: hasFile ? AppColors.success : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
