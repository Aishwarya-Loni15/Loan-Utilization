import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class DetectedObjectsCardWidget extends StatelessWidget {
  final List<String> objects;

  const DetectedObjectsCardWidget({super.key, required this.objects});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Computer Vision Detected Assets',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: objects
                .map((obj) => Chip(
                      avatar: const Icon(Icons.remove_red_eye_outlined, size: 14),
                      label: Text(obj, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.inputBackground,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
