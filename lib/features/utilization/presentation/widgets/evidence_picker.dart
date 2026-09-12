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
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context,
                title: 'Geotag Photo',
                subtitle: 'Camera / Gallery',
                icon: Icons.camera_alt_rounded,
                file: photoFile,
                onTap: onPickPhoto,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTile(
                context,
                title: 'Site Video',
                subtitle: 'Optional Video',
                icon: Icons.videocam_rounded,
                file: videoFile,
                onTap: onPickVideo,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTile(
                context,
                title: 'Invoice / Doc',
                subtitle: 'Receipt PDF/JPG',
                icon: Icons.receipt_long_rounded,
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
    required String subtitle,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
  }) {
    final hasFile = file != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: hasFile ? AppColors.lightViolet : AppColors.softViolet,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile ? AppColors.primaryViolet : const Color(0xFFE4DCF2),
            width: hasFile ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasFile ? AppColors.primaryViolet : AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryViolet.withValues(alpha: 0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                hasFile ? Icons.check_rounded : icon,
                color: hasFile ? Colors.white : AppColors.primaryViolet,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: hasFile ? AppColors.primaryViolet : AppColors.darkText,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              hasFile ? 'Attached' : subtitle,
              style: TextStyle(
                fontSize: 10,
                fontWeight: hasFile ? FontWeight.w700 : FontWeight.normal,
                color: hasFile ? AppColors.primaryViolet : AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

