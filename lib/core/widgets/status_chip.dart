import 'package:flutter/material.dart';
import '../enums/risk_level.dart';
import '../enums/submission_status.dart';
import '../enums/loan_status.dart';
import '../../app/theme/app_colors.dart';

class RiskLevelChip extends StatelessWidget {
  final RiskLevel level;
  final bool isCompact;

  const RiskLevelChip({super.key, required this.level, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (level) {
      case RiskLevel.low:
        bg = const Color(0xFFECFDF5);
        fg = AppColors.riskLow;
        icon = Icons.verified_user_rounded;
        break;
      case RiskLevel.medium:
        bg = const Color(0xFFFFFBEB);
        fg = AppColors.riskMedium;
        icon = Icons.warning_amber_rounded;
        break;
      case RiskLevel.high:
        bg = const Color(0xFFFEF2F2);
        fg = AppColors.riskHigh;
        icon = Icons.gpp_bad_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 13 : 15, color: fg),
          const SizedBox(width: 5),
          Text(
            isCompact ? level.value : level.displayName,
            style: TextStyle(
              color: fg,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class SubmissionStatusChip extends StatelessWidget {
  final SubmissionStatus status;

  const SubmissionStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    IconData icon;

    switch (status) {
      case SubmissionStatus.approved:
        color = AppColors.success;
        bg = const Color(0xFFECFDF5);
        icon = Icons.check_circle_rounded;
        break;
      case SubmissionStatus.rejected:
        color = AppColors.danger;
        bg = const Color(0xFFFEF2F2);
        icon = Icons.cancel_rounded;
        break;
      case SubmissionStatus.underOfficerReview:
      case SubmissionStatus.submitted:
      case SubmissionStatus.resubmissionRequired:
      case SubmissionStatus.aiProcessing:
        color = AppColors.warning;
        bg = const Color(0xFFFFFBEB);
        icon = Icons.hourglass_top_rounded;
        break;
      case SubmissionStatus.aiVerified:
        color = AppColors.primaryViolet;
        bg = AppColors.lightViolet;
        icon = Icons.auto_awesome_rounded;
        break;
      case SubmissionStatus.notSubmitted:
        color = AppColors.secondaryText;
        bg = const Color(0xFFF1F0F5);
        icon = Icons.pending_actions_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LoanStatusChip extends StatelessWidget {
  final LoanStatus status;

  const LoanStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;

    switch (status) {
      case LoanStatus.completed:
      case LoanStatus.fullyUtilized:
      case LoanStatus.closed:
        color = AppColors.success;
        bg = const Color(0xFFECFDF5);
        break;
      case LoanStatus.active:
      case LoanStatus.partiallyUtilized:
      case LoanStatus.disbursed:
      case LoanStatus.registered:
      case LoanStatus.linked:
        color = AppColors.primaryViolet;
        bg = AppColors.lightViolet;
        break;
      case LoanStatus.pending:
      case LoanStatus.approved:
      case LoanStatus.underReview:
        color = AppColors.warning;
        bg = const Color(0xFFFFFBEB);
        break;
      case LoanStatus.flagged:
      case LoanStatus.rejected:
        color = AppColors.danger;
        bg = const Color(0xFFFEF2F2);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SyncStatusChip extends StatelessWidget {
  final bool isSynced;

  const SyncStatusChip({super.key, required this.isSynced});

  @override
  Widget build(BuildContext context) {
    final color = isSynced ? AppColors.success : AppColors.warning;
    final bg = isSynced ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB);
    final label = isSynced ? 'Synced' : 'Pending Sync';
    final icon = isSynced ? Icons.cloud_done_rounded : Icons.sync_problem_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

