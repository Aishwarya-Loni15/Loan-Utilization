import 'package:flutter/material.dart';
import '../../../../core/enums/submission_status.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';

class SubmissionStatusCardWidget extends StatelessWidget {
  final SubmissionStatus status;
  final String? rejectionReason;

  const SubmissionStatusCardWidget({
    super.key,
    required this.status,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Submission Audit Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SubmissionStatusChip(status: status),
            ],
          ),
          if (rejectionReason != null && rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Rejection Reason: $rejectionReason',
                style: TextStyle(color: Colors.red.shade900, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
