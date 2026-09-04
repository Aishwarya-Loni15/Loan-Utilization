import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/enums/submission_status.dart';
import 'package:laon/core/utils/currency_utils.dart';
import 'package:laon/core/utils/date_utils.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/ai_verification/presentation/widgets/ai_reason_card.dart';
import 'package:laon/features/ai_verification/presentation/widgets/ai_score_card.dart';
import 'package:laon/features/ai_verification/providers/ai_provider.dart';
import 'package:laon/features/loans/providers/loan_provider.dart';
import 'package:laon/features/utilization/providers/utilization_provider.dart';
import 'package:laon/core/enums/location_consistency_status.dart';
import 'package:laon/core/services/location_service.dart';
import 'package:laon/core/services/ai_verification_engine.dart';
import '../widgets/review_action_buttons.dart';

class ReviewSubmissionPage extends ConsumerStatefulWidget {
  final String submissionId;

  const ReviewSubmissionPage({super.key, required this.submissionId});

  @override
  ConsumerState<ReviewSubmissionPage> createState() => _ReviewSubmissionPageState();
}

class _ReviewSubmissionPageState extends ConsumerState<ReviewSubmissionPage> {
  bool _isProcessing = false;

  Future<void> _handleAction(ReviewAction action) async {
    String? reason;
    String? comment;

    if (action == ReviewAction.reject) {
      final controller = TextEditingController();
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reject Evidence Package'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter mandatory rejection reason...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reject'),
            ),
          ],
        ),
      );

      if (confirm != true || controller.text.trim().isEmpty) {
        if (confirm == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rejection reason is mandatory.')),
          );
        }
        return;
      }
      reason = controller.text.trim();
    } else if (action == ReviewAction.requestInfo) {
      final controller = TextEditingController();
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Request More Information'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter comment detailing requested evidence clarification...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Send Request'),
            ),
          ],
        ),
      );

      if (confirm != true || controller.text.trim().isEmpty) {
        if (confirm == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request comment is mandatory.')),
          );
        }
        return;
      }
      comment = controller.text.trim();
    }

    setState(() => _isProcessing = true);
    try {
      final status = action == ReviewAction.approve
          ? SubmissionStatus.approved
          : (action == ReviewAction.reject ? SubmissionStatus.rejected : SubmissionStatus.underReview);

      await ref.read(submitEvidenceNotifierProvider.notifier).review(
            submissionId: widget.submissionId,
            status: status,
            rejectionReason: reason ?? comment,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == ReviewAction.approve
                ? 'Submission Approved & Audit Log Created'
                : (action == ReviewAction.reject
                    ? 'Submission Rejected & Audit Log Created'
                    : 'More Info Requested & Audit Log Created')),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync = ref.watch(allSubmissionsProvider);
    final loansAsync = ref.watch(allLoansProvider);
    final aiAsync = ref.watch(aiAnalysisFamilyProvider(widget.submissionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Officer Final Verification Audit'),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          final sub = submissions.firstWhere(
            (s) => s.submissionId == widget.submissionId,
            orElse: () => throw Exception('Submission record not found'),
          );

          final loan = loansAsync.value?.firstWhere(
            (l) => l.loanId == sub.loanId,
            orElse: () => throw Exception('Loan record not found'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Beneficiary & Loan Information Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Beneficiary & Scheme Identification',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text('Beneficiary ID: ${sub.beneficiaryId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (loan != null) ...[
                        Text('Scheme: ${loan.schemeName}', style: const TextStyle(fontSize: 13)),
                        Text('Sanctioned Purpose: ${loan.purpose}', style: const TextStyle(fontSize: 13)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Claimed Amount & Description
                Text(
                  'Claimed Amount: ${CurrencyUtils.formatINR(sub.amountSpent)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Submitted Timestamp: ${AppDateUtils.formatDateTime(sub.uploadedAt)}'),
                const SizedBox(height: 12),
                Text('Description: ${sub.description}'),
                const SizedBox(height: 20),

                // Geotag & Media Artifacts Section
                Text(
                  'Evidence Artifacts & Geotag Lock',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                // Location Consistency Classification Chip
                Builder(
                  builder: (context) {
                    final status = LocationService().classifyLocationConsistency(
                      latitude: sub.latitude,
                      longitude: sub.longitude,
                    );
                    final isConsistent = status == LocationConsistencyStatus.locationConsistent;
                    final color = isConsistent
                        ? AppColors.success
                        : (status == LocationConsistencyStatus.locationPossiblyInconsistent ? AppColors.warning : Colors.grey);

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: color, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${status.label} • 📸 Photo Geotag',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '📸 Beneficiary Photo Geotag Location (Unchanged): ${sub.latitude.toStringAsFixed(5)}° N, ${sub.longitude.toStringAsFixed(5)}° E (±${sub.locationAccuracy.toStringAsFixed(1)}m)',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status.description,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          if (status == LocationConsistencyStatus.locationPossiblyInconsistent) ...[
                            const SizedBox(height: 4),
                            const Text(
                              'Note: System never auto-rejects based solely on GPS accuracy.',
                              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.warning),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                if (sub.photoUrls.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final photoPath = sub.photoUrls.first;
                      final isAiGen = AiVerificationEngine.isAiGeneratedPhoto(photoPath, sub.description);
                      final isFake = isAiGen || AiVerificationEngine.isFakePhoto(photoPath, sub.description) || sub.description.toLowerCase().contains('fake');

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Geotagged Photo Evidence:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: (photoPath.startsWith('http') || photoPath.startsWith('https'))
                                    ? Image.network(
                                        photoPath,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Image.network(
                                          'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800',
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (File(photoPath).existsSync()
                                        ? Image.file(
                                            File(photoPath),
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Image.network(
                                              'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800',
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.network(
                                            'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800',
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isAiGen
                                        ? Colors.purple.shade900
                                        : (isFake ? AppColors.danger : AppColors.success),
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
                                        isAiGen
                                            ? Icons.smart_toy_rounded
                                            : (isFake ? Icons.gpp_bad_rounded : Icons.verified_rounded),
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isAiGen
                                            ? '🤖 AI GENERATED IMAGE (FAKE)'
                                            : (isFake ? '⚠️ FAKE IMAGE' : '✅ REAL IMAGE'),
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
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.camera_alt_outlined),
                    title: const Text('Geotag Photo Artifact'),
                    subtitle: const Text('No photo uploaded'),
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.videocam_outlined),
                  title: const Text('Site Video Recording'),
                  subtitle: Text(sub.videoUrls.isNotEmpty ? sub.videoUrls.first : 'No video attached'),
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Invoice Document / Voucher'),
                  subtitle: Text(sub.documentUrls.isNotEmpty ? sub.documentUrls.first : 'No invoice attached'),
                ),
                const SizedBox(height: 20),

                // Assistive AI System Advisory Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.smart_toy_outlined, color: AppColors.info, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'IMPORTANT: AI is an assistive verification system. Final approval or rejection decision rests solely with the Bank Manager/Officer.',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // AI Assistive Verification (Image & Geotag Authenticity)
                aiAsync.when(
                  data: (ai) {
                    final aiResult = AiVerificationEngine().analyzeSubmission(
                      submissionId: sub.submissionId,
                      loanPurpose: loan?.purpose ?? 'Agricultural Equipment',
                      amountClaimed: sub.amountSpent,
                      photoUrls: sub.photoUrls,
                      videoUrls: sub.videoUrls,
                      documentUrls: sub.documentUrls,
                      latitude: sub.latitude,
                      longitude: sub.longitude,
                    );

                    final isAiGen = aiResult.isAiGenerated;
                    final isImageReal = aiResult.isImageReal;
                    final isGeotagReal = aiResult.isGeotagReal;
                    final isMismatch = aiResult.aiStatus == 'PURPOSE_MISMATCH';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Authenticity Badges: Image & Geotag
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isAiGen
                                      ? Colors.purple.shade50
                                      : (isImageReal ? Colors.green.shade50 : Colors.red.shade50),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isAiGen
                                        ? Colors.purple.shade400
                                        : (isImageReal ? Colors.green.shade300 : Colors.red.shade300),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAiGen
                                          ? '🤖 Image: FAKE (AI Gen)'
                                          : (isImageReal ? '🖼️ Image: REAL' : '🖼️ Image: FAKE'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: isAiGen
                                            ? Colors.purple.shade900
                                            : (isImageReal ? Colors.green.shade800 : Colors.red.shade800),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isAiGen
                                          ? 'Synthetic AI / Deepfake'
                                          : (isImageReal ? 'Authentic Photo' : 'Tampered / Fake'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isAiGen
                                            ? Colors.purple.shade900
                                            : (isImageReal ? Colors.green.shade900 : Colors.red.shade900),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isGeotagReal ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isGeotagReal ? Colors.green.shade300 : Colors.red.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isGeotagReal ? '📍 Geotag: REAL' : '📍 Geotag: FAKE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: isGeotagReal ? Colors.green.shade800 : Colors.red.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isGeotagReal ? 'GPS Lock Genuine' : 'Mock Location',
                                      style: TextStyle(fontSize: 10, color: isGeotagReal ? Colors.green.shade900 : Colors.red.shade900),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (isMismatch) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.danger),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'AI FLAG: PURPOSE_MISMATCH DETECTED',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        AiScoreCardWidget(score: aiResult.confidenceScore),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Detected Objects: ${aiResult.detectedObjects.join(", ")}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('Explanation: ${aiResult.verificationExplanation}', style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        AiReasonCardWidget(reasons: ai.reasons),
                      ],
                    );
                  },
                  loading: () => const LoadingWidget(message: 'Loading AI verification score & reason insights...'),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Final Action Buttons
                ReviewActionButtonsWidget(
                  isLoading: _isProcessing,
                  onActionSelected: _handleAction,
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading submission for audit...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
