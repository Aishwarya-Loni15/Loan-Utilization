import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';

class VideoPickerWidget extends StatelessWidget {
  final File? videoFile;
  final ValueChanged<File> onVideoCaptured;

  const VideoPickerWidget({
    super.key,
    required this.videoFile,
    required this.onVideoCaptured,
  });

  Future<void> _recordVideo(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        final file = File(video.path);
        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);

        if (sizeInMB > 25) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Video exceeds maximum limit of 25MB (${sizeInMB.toStringAsFixed(1)}MB).')),
            );
          }
          return;
        }

        onVideoCaptured(file);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to record video: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo = videoFile != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasVideo ? AppColors.success.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasVideo ? AppColors.success : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasVideo ? AppColors.success.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasVideo ? Icons.check_circle_rounded : Icons.videocam_rounded,
              color: hasVideo ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Site Video Recording (Max 30s)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasVideo ? videoFile!.path.split('/').last : 'Record short video clip of asset/work',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasVideo ? AppColors.success : AppColors.textSecondary,
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
            onPressed: () => _recordVideo(context),
            child: Text(hasVideo ? 'Retake' : 'Record'),
          ),
        ],
      ),
    );
  }
}
