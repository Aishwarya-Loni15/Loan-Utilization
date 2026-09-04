import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class SystemHealthCardWidget extends StatelessWidget {
  const SystemHealthCardWidget({super.key});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'System Health & Infrastructure',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cloud Functions (TypeScript)', style: TextStyle(fontSize: 12)),
              Text('Operational (99.9%)', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Firestore Database', style: TextStyle(fontSize: 12)),
              Text('Healthy', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assistive Vision OCR API', style: TextStyle(fontSize: 12)),
              Text('Online', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
