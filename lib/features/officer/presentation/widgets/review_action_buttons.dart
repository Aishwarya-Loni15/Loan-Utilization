import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

enum ReviewAction { approve, reject, requestInfo }

class ReviewActionButtonsWidget extends StatelessWidget {
  final ValueChanged<ReviewAction> onActionSelected;
  final bool isLoading;

  const ReviewActionButtonsWidget({
    super.key,
    required this.onActionSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: () => onActionSelected(ReviewAction.reject),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('REJECT'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: () => onActionSelected(ReviewAction.requestInfo),
                icon: const Icon(Icons.help_outline, size: 18),
                label: const Text('INFO REQ'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () => onActionSelected(ReviewAction.approve),
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text('APPROVE EVIDENCE PACKAGE'),
          ),
        ),
      ],
    );
  }
}
