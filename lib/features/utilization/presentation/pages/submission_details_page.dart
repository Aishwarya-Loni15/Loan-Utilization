import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/providers/utilization_provider.dart';
import 'package:laon/app/providers/auth_provider.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/enums/user_role.dart';
import 'package:laon/core/enums/submission_status.dart';
import 'package:laon/core/widgets/status_chip.dart';
import 'package:laon/features/loans/providers/loan_provider.dart';
import 'package:laon/core/services/ai_verification_engine.dart';

class SubmissionDetailsPage extends ConsumerWidget {
  final String submissionId;

  const SubmissionDetailsPage({super.key, required this.submissionId});

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Submission'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter mandatory rejection reason...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(context);
              await ref.read(submitEvidenceNotifierProvider.notifier).review(
                    submissionId: submissionId,
                    status: SubmissionStatus.rejected,
                    rejectionReason: reasonController.text.trim(),
                  );
            },
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(allSubmissionsProvider);
    final loansAsync = ref.watch(allLoansProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission & AI Audit'),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          final submission = submissions.where((s) => s.submissionId == submissionId).firstOrNull;

          if (submission == null) {
            return const Center(child: Text('Submission record not found.'));
          }

          final loan = loansAsync.value?.where((l) => l.loanId == submission.loanId).firstOrNull;

          if (user != null && user.role == UserRole.bankManager) {
            final userUid = user.uid;
            final userEmail = user.email.trim().toLowerCase();
            final loanMgrId = (loan?.bankManagerId ?? '').trim();
            final isManagerMatch = (loanMgrId.isNotEmpty && (loanMgrId == userUid || loanMgrId.toLowerCase() == userEmail)) ||
                (userUid == 'user_bank_sbi' && (loanMgrId.isEmpty || loanMgrId == 'user_bank_sbi'));

            if (!isManagerMatch) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.gpp_bad_rounded, size: 64, color: AppColors.danger),
                      const SizedBox(height: 16),
                      const Text(
                        'Access Restricted',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.danger),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The beneficiary images and data are visible only to the bank manager who added their link.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          final canReview = user?.role == UserRole.stateOfficer ||
              user?.role == UserRole.bankManager ||
              user?.role == UserRole.admin;

          final photoPath = submission.photoUrls.isNotEmpty ? submission.photoUrls.first : '';
          final isAiGeneratedImage = AiVerificationEngine.isAiGeneratedPhoto(photoPath, submission.description);
          final isFakeImage = isAiGeneratedImage ||
              AiVerificationEngine.isFakePhoto(photoPath, submission.description) ||
              submission.description.toLowerCase().contains('fake');

          final isWrongAmountOrFake = (loan != null && submission.amountSpent > loan.remainingAmount) ||
              isFakeImage ||
              isAiGeneratedImage;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAiGeneratedImage) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade900.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.purple.shade800, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.smart_toy_rounded, color: Colors.purple.shade800, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🤖 AI-GENERATED FAKE IMAGE DETECTED',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade900, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'The uploaded photo was synthesized by AI (Generative Model / Deepfake) and is FLAGGED AS FAKE.',
                                style: TextStyle(fontSize: 12, color: Colors.purple.shade900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isFakeImage) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.danger, width: 1.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.gpp_bad_rounded, color: AppColors.danger, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚠️ FAKE / TAMPERED IMAGE DETECTED',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 13),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'The uploaded beneficiary photo is detected as FAKE / TAMPERED and flagged by the AI Verification engine.',
                                style: TextStyle(fontSize: 12, color: AppColors.danger),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isWrongAmountOrFake) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '❌ WRONG ENTERED AMOUNT / SUSPICIOUS PROOF ALERT',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                loan != null && submission.amountSpent > loan.remainingAmount
                                    ? 'Entered spent amount (₹${submission.amountSpent.toStringAsFixed(0)}) exceeds remaining loan balance (₹${loan.remainingAmount.toStringAsFixed(0)}).'
                                    : 'The entered amount or attached evidence has been flagged for inconsistencies by the AI Verification engine.',
                                style: const TextStyle(fontSize: 12, color: AppColors.danger),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SubmissionStatusChip(status: submission.status),
                    RiskLevelChip(level: submission.riskLevel),
                  ],
                ),
                const SizedBox(height: 16),

                // Claim Summary Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.description,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Claimed Amount: ₹${submission.amountSpent.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          Text(
                            'Captured: ${submission.capturedAt.day}/${submission.capturedAt.month}/${submission.capturedAt.year}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 12),

                const SizedBox(height: 20),
                const Text('📸 Original Geotag Photo Location (Unchanged)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.map_rounded, color: AppColors.primary),
                    title: Text('Lat: ${submission.latitude}° N, Long: ${submission.longitude}° E'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        const Text(
                          '📸 Photo Geotag Location Sent to Bank Manager',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.success),
                        ),
                        Text(
                          '📍 Real Village Name: ${submission.registeredVillage.isNotEmpty ? submission.registeredVillage : "Ojewadi"}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                        ),
                        const Text(
                          '🏛️ Taluka Area: Pandharpur Taluka, Solapur District',
                          style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Accuracy: ${submission.locationAccuracy}m',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
                      onPressed: () {
                        context.push('/map-view', extra: {
                          'latitude': submission.latitude,
                          'longitude': submission.longitude,
                          'title': submission.description,
                          'villageName': submission.registeredVillage.isNotEmpty ? submission.registeredVillage : 'Ojewadi',
                          'talukaArea': 'Pandharpur Taluka',
                        });
                      },
                      child: const Text('View Map'),
                    ),
                  ),
                ),

                if (submission.photoUrls.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Geotagged Photo Proof Evidence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (submission.photoUrls.first.startsWith('http') || submission.photoUrls.first.startsWith('https'))
                            ? Image.network(
                                submission.photoUrls.first,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.network(
                                  'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800',
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (File(submission.photoUrls.first).existsSync()
                                ? Image.file(
                                    File(submission.photoUrls.first),
                                    height: 220,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Image.network(
                                      'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800',
                                      height: 220,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.network(
                                    'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800',
                                    height: 220,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isAiGeneratedImage
                                ? Colors.purple.shade900
                                : (isFakeImage ? AppColors.danger : AppColors.success),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAiGeneratedImage
                                    ? Icons.smart_toy_rounded
                                    : (isFakeImage ? Icons.gpp_bad_rounded : Icons.verified_rounded),
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isAiGeneratedImage
                                    ? '🤖 AI GENERATED IMAGE (FAKE)'
                                    : (isFakeImage ? '⚠️ FAKE IMAGE' : '✅ REAL IMAGE'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (canReview && (submission.status != SubmissionStatus.approved && submission.status != SubmissionStatus.rejected)) ...[
                  const SizedBox(height: 32),
                  const Text('Human Officer Verification Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, minimumSize: const Size(0, 48)),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Approve Submission'),
                          onPressed: () async {
                            await ref.read(submitEvidenceNotifierProvider.notifier).review(
                                  submissionId: submissionId,
                                  status: SubmissionStatus.approved,
                                );
                            if (context.mounted) context.pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, minimumSize: const Size(0, 48)),
                          icon: const Icon(Icons.highlight_off_rounded),
                          label: const Text('Reject Evidence'),
                          onPressed: () => _showRejectDialog(context, ref),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error loading submission details: $e'),
      ),
    );
  }
}
