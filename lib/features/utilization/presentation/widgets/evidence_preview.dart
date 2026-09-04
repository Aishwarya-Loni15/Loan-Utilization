import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/ai_verification_engine.dart';

class EvidencePreviewWidget extends StatelessWidget {
  final File? photoFile;
  final File? videoFile;
  final File? documentFile;
  final VoidCallback? onRemovePhoto;
  final VoidCallback? onRemoveVideo;
  final VoidCallback? onRemoveDocument;

  const EvidencePreviewWidget({
    super.key,
    this.photoFile,
    this.videoFile,
    this.documentFile,
    this.onRemovePhoto,
    this.onRemoveVideo,
    this.onRemoveDocument,
  });

  @override
  Widget build(BuildContext context) {
    if (photoFile == null && videoFile == null && documentFile == null) {
      return const SizedBox.shrink();
    }

    final isPhotoAiGen = photoFile != null && AiVerificationEngine.isAiGeneratedPhoto(photoFile!.path, '');
    final isPhotoFake = photoFile != null && (isPhotoAiGen || AiVerificationEngine.isFakePhoto(photoFile!.path, ''));

    final isDocAiGen = documentFile != null && AiVerificationEngine.isAiGeneratedPhoto(documentFile!.path, '');
    final isDocFake = documentFile != null && (isDocAiGen || AiVerificationEngine.isFakePhoto(documentFile!.path, ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attached Media Package',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (photoFile != null)
          _buildItem(
            context,
            title: 'Geotag Photo',
            filename: photoFile!.path.split('/').last,
            icon: Icons.camera_alt_outlined,
            isAiGen: isPhotoAiGen,
            isFake: isPhotoFake,
            onRemove: onRemovePhoto,
          ),
        if (videoFile != null)
          _buildItem(
            context,
            title: 'Site Video Clip',
            filename: videoFile!.path.split('/').last,
            icon: Icons.videocam_outlined,
            onRemove: onRemoveVideo,
          ),
        if (documentFile != null)
          _buildItem(
            context,
            title: 'Invoice Document',
            filename: documentFile!.path.split('/').last,
            icon: Icons.receipt_long_outlined,
            isAiGen: isDocAiGen,
            isFake: isDocFake,
            onRemove: onRemoveDocument,
          ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String title,
    required String filename,
    required IconData icon,
    bool isAiGen = false,
    bool isFake = false,
    VoidCallback? onRemove,
  }) {
    final statusColor = isAiGen
        ? Colors.purple.shade800
        : (isFake ? AppColors.danger : AppColors.border);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isAiGen
            ? Colors.purple.shade50
            : (isFake ? AppColors.danger.withValues(alpha: 0.05) : AppColors.surface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAiGen
              ? Colors.purple.shade300
              : (isFake ? AppColors.danger.withValues(alpha: 0.5) : AppColors.border),
          width: (isAiGen || isFake) ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAiGen ? Icons.smart_toy_rounded : (isFake ? Icons.gpp_bad_rounded : icon),
            color: isAiGen ? Colors.purple.shade700 : (isFake ? AppColors.danger : AppColors.primary),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    if (isAiGen) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade800,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '🤖 AI GENERATED - FAKE',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ] else if (isFake) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '⚠️ FAKE IMAGE',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  filename,
                  style: TextStyle(
                    color: (isAiGen || isFake) ? statusColor : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: (isAiGen || isFake) ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.danger),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
