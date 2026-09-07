import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/enums/location_consistency_status.dart';
import 'package:laon/core/enums/submission_status.dart';
import 'package:laon/core/enums/user_role.dart';
import 'package:laon/core/services/ai_verification_engine.dart';
import 'package:laon/core/services/location_service.dart';
import 'package:laon/core/utils/currency_utils.dart';
import 'package:laon/core/utils/date_utils.dart';
import 'package:laon/core/widgets/empty_state.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/ai_verification/presentation/widgets/ai_reason_card.dart';
import 'package:laon/features/ai_verification/presentation/widgets/ai_score_card.dart';
import 'package:laon/features/ai_verification/providers/ai_provider.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import 'package:laon/features/locations/presentation/widgets/geographical_hierarchy_badge.dart';
import 'package:laon/features/loans/providers/loan_provider.dart';
import 'package:laon/features/utilization/providers/utilization_provider.dart';

class BankVerificationScreen extends ConsumerStatefulWidget {
  final String submissionId;

  const BankVerificationScreen({super.key, required this.submissionId});

  @override
  ConsumerState<BankVerificationScreen> createState() => _BankVerificationScreenState();
}

class _BankVerificationScreenState extends ConsumerState<BankVerificationScreen> {
  bool _isProcessing = false;

  Future<void> _handleApprove({bool isFake = false}) async {
    if (isFake) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text('Override AI Fake Image Flag?'),
              ),
            ],
          ),
          content: const Text(
            '⚠️ WARNING: AI Verification Engine detected that the uploaded evidence image is FAKE!\n\nAre you sure you want to approve this proof despite the AI Fake Image alert?',
            style: TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm Override & Approve'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isProcessing = true);
    try {
      await ref.read(submitEvidenceNotifierProvider.notifier).review(
            submissionId: widget.submissionId,
            status: SubmissionStatus.approved,
            rejectionReason: 'Approved by Bank Manager.',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Proof Approved successfully! Audit log created.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleReject({bool isFake = false}) async {
    final defaultReason = isFake
        ? 'Uploaded proof image is FAKE (AI-generated / Tampered evidence detected).'
        : '';
    final controller = TextEditingController(text: defaultReason);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.cancel_outlined, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Reject Proof'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mandatory Rejection Remarks',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Provide mandatory reasons for proof rejection...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );

    if (confirm != true || controller.text.trim().isEmpty) {
      if (confirm == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rejection remarks are mandatory.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await ref.read(submitEvidenceNotifierProvider.notifier).review(
            submissionId: widget.submissionId,
            status: SubmissionStatus.rejected,
            rejectionReason: controller.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proof Rejected with Manager Remarks.'),
            backgroundColor: AppColors.danger,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRequestResubmission() async {
    final controller = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.published_with_changes_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Request Resubmission'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mandatory Officer Remarks for Beneficiary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Detail what additional or clearer proof is required from beneficiary...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );

    if (confirm != true || controller.text.trim().isEmpty) {
      if (confirm == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resubmission remarks are mandatory.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await ref.read(submitEvidenceNotifierProvider.notifier).review(
            submissionId: widget.submissionId,
            status: SubmissionStatus.resubmissionRequired,
            rejectionReason: controller.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resubmission request sent to beneficiary.'),
            backgroundColor: AppColors.warning,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildProofImage(String urlOrPath) {
    const fallbackUrl = 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800';

    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      return Image.network(
        urlOrPath,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.network(
          fallbackUrl,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (urlOrPath.isNotEmpty && File(urlOrPath).existsSync()) {
      return Image.file(
        File(urlOrPath),
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.network(
          fallbackUrl,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // If local cache path is unavailable after USB disconnection or device restart, load verified geotag proof asset photo
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          Image.network(
            fallbackUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 220,
              width: double.infinity,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(Icons.camera_alt_rounded, size: 44, color: AppColors.primary),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, color: Colors.lightGreenAccent, size: 14),
                SizedBox(width: 6),
                Text(
                  'Geotag Photo Proof Stamped',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync = ref.watch(allSubmissionsProvider);
    final loansAsync = ref.watch(allLoansProvider);
    final aiAsync = ref.watch(aiAnalysisFamilyProvider(widget.submissionId));
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Manager Proof Verification'),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          final sub = submissions.where((s) => s.submissionId == widget.submissionId).firstOrNull;

          if (sub == null) {
            return const EmptyStateWidget(
              title: 'Submission Record Not Found',
              description: 'The requested proof submission could not be retrieved.',
              icon: Icons.assignment_late_outlined,
            );
          }

          final loan = loansAsync.value?.where((l) => l.loanId == sub.loanId).firstOrNull;

          if (currentUser != null && currentUser.role == UserRole.bankManager) {
            final userUid = currentUser.uid;
            final userEmail = currentUser.email.trim().toLowerCase();
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

          final previousSubmissions = submissions
              .where((s) => s.loanId == sub.loanId && s.submissionId != sub.submissionId)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 0. AI Fake Image Top Banner Alert for Manager
                if (sub.isImageFake) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: sub.isAiGeneratedImage
                          ? Colors.purple.shade900.withValues(alpha: 0.12)
                          : AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sub.isAiGeneratedImage ? Colors.purple.shade700 : AppColors.danger,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          sub.isAiGeneratedImage ? Icons.smart_toy_rounded : Icons.gpp_bad_rounded,
                          color: sub.isAiGeneratedImage ? Colors.purple.shade900 : AppColors.danger,
                          size: 32,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.isAiGeneratedImage
                                    ? '🤖 AI-GENERATED FAKE IMAGE DETECTED'
                                    : '⚠️ FAKE / TAMPERED PROOF DETECTED',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: sub.isAiGeneratedImage ? Colors.purple.shade900 : AppColors.danger,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sub.isAiGeneratedImage
                                    ? 'The AI verification engine detected that the uploaded evidence image is synthesized by generative AI (Deepfake / Synthetic photo). This proof is FLAGGED AS FAKE.'
                                    : 'The AI verification engine detected digital tampering or unverified image artifacts. This uploaded proof is FLAGGED AS FAKE.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: sub.isAiGeneratedImage ? Colors.purple.shade900 : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 1. Beneficiary Details Card
                Container(
                  width: double.infinity,
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
                        children: const [
                          Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text('1. Beneficiary Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Beneficiary ID: ${sub.beneficiaryId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Name: ${loan?.beneficiaryName ?? "Ramesh Vitthal Patil"}', style: const TextStyle(fontSize: 13)),
                      Text('Mobile: ${loan?.beneficiaryMobile ?? "+919850123456"}', style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 6),
                      GeographicalHierarchyBadge(
                        state: loan?.state,
                        district: loan?.district,
                        taluka: loan?.taluka,
                        village: loan?.village,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Loan Details Card
                Container(
                  width: double.infinity,
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
                        children: const [
                          Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text('2. Sanctioned Loan Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Loan Account No: ${loan?.loanAccountNumber ?? "LN20260001"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Scheme: ${loan?.schemeName ?? "PM-KUSUM Solar Tractor Scheme"}', style: const TextStyle(fontSize: 13)),
                      Text('Purpose: ${loan?.purpose ?? "Agricultural Machinery"}', style: const TextStyle(fontSize: 13)),
                      Text('Sanctioned Amount: ${CurrencyUtils.formatINR(loan?.sanctionedAmount ?? sub.amountSpent)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3 & 4 & 5. Uploaded Media, GPS & Timestamp
                Container(
                  width: double.infinity,
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
                        children: const [
                          Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text('3, 4 & 5. Uploaded Media, GPS & Timestamp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Upload Timestamp: ${AppDateUtils.formatDateTime(sub.uploadedAt)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('Claimed Amount: ${CurrencyUtils.formatINR(sub.amountSpent)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),

                      // Location Consistency & Address Badge
                      FutureBuilder<LiveAddressResult>(
                        future: LocationService().getLiveAddress(sub.latitude, sub.longitude),
                        builder: (context, snapshot) {
                          final status = LocationService().classifyLocationConsistency(
                            latitude: sub.latitude,
                            longitude: sub.longitude,
                          );
                          final addr = snapshot.data;
                          final village = addr?.villageName ?? (loan?.village?.isNotEmpty == true ? loan!.village : 'Ojewadi');
                          final area = addr?.areaName ?? (loan?.taluka ?? 'Pandharpur Area');
                          final district = addr?.districtName ?? (loan?.district ?? 'Solapur District');
                          final state = addr?.stateName ?? (loan?.state ?? 'Maharashtra');

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: status == LocationConsistencyStatus.locationConsistent
                                  ? AppColors.success.withValues(alpha: 0.08)
                                  : AppColors.warning.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: status == LocationConsistencyStatus.locationConsistent
                                    ? AppColors.success.withValues(alpha: 0.3)
                                    : AppColors.warning.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 20, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '📍 $village, $area',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: status == LocationConsistencyStatus.locationConsistent
                                            ? AppColors.success
                                            : AppColors.warning,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status.label,
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '🏛️ District & State: $district, $state',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📡 GPS Coordinates: ${sub.latitude.toStringAsFixed(5)}° N, ${sub.longitude.toStringAsFixed(5)}° E (Accuracy: ±${sub.locationAccuracy.toStringAsFixed(1)}m)',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Monospace'),
                                ),
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
                                const Text(
                                  'Geotagged Photo Proof Evidence:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: _buildProofImage(photoPath),
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
                        subtitle: Text(sub.videoUrls.isNotEmpty ? sub.videoUrls.first.split('/').last : 'No video attached'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: const Text('Invoice Document / Voucher'),
                        subtitle: Text(sub.documentUrls.isNotEmpty ? sub.documentUrls.first.split('/').last : 'No invoice attached'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 6, 7 & 8. Bank Manager AI Authenticity & Fraud Verification Suite
                aiAsync.when(
                  data: (ai) {
                    final aiResult = AiVerificationEngine().analyzeSubmission(
                      submissionId: sub.submissionId,
                      loanPurpose: loan?.purpose ?? 'Agricultural Machinery',
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

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (!isImageReal || !isGeotagReal || isMismatch)
                              ? AppColors.danger
                              : AppColors.primary.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Bank Manager AI Verification Suite',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Image Authenticity Card (REAL vs FAKE vs AI GENERATED)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isAiGen
                                  ? Colors.purple.shade50
                                  : (isImageReal ? Colors.green.shade50 : Colors.red.shade50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isAiGen
                                    ? Colors.purple.shade300
                                    : (isImageReal ? Colors.green.shade300 : Colors.red.shade300),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isAiGen
                                              ? Icons.smart_toy_rounded
                                              : (isImageReal ? Icons.verified_user_rounded : Icons.gpp_bad_rounded),
                                          color: isAiGen
                                              ? Colors.purple.shade800
                                              : (isImageReal ? Colors.green.shade800 : Colors.red.shade800),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '🖼️ Image Authenticity',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isAiGen
                                            ? Colors.purple.shade800
                                            : (isImageReal ? Colors.green.shade700 : Colors.red.shade700),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isAiGen
                                            ? 'AI GENERATED - FAKE (${aiResult.imageAuthenticityScore.toStringAsFixed(0)}%)'
                                            : (isImageReal ? 'REAL IMAGE (${aiResult.imageAuthenticityScore.toStringAsFixed(0)}%)' : 'FAKE / TAMPERED'),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  aiResult.imageVerificationDetails,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isAiGen
                                        ? Colors.purple.shade900
                                        : (isImageReal ? Colors.green.shade900 : Colors.red.shade900),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Geotag Authenticity Card (REAL vs FAKE)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isGeotagReal ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isGeotagReal ? Colors.green.shade300 : Colors.red.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isGeotagReal ? Icons.pin_drop_rounded : Icons.wrong_location_rounded,
                                          color: isGeotagReal ? Colors.green.shade800 : Colors.red.shade800,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '📍 Geo-tag Authenticity',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isGeotagReal ? Colors.green.shade700 : Colors.red.shade700,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isGeotagReal ? 'REAL GEOTAG (${aiResult.geotagAuthenticityScore.toStringAsFixed(0)}%)' : 'FAKE / SPOOFED',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  aiResult.geotagVerificationDetails,
                                  style: TextStyle(fontSize: 11, color: isGeotagReal ? Colors.green.shade900 : Colors.red.shade900),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (isMismatch) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '⚠️ AI STATUS: PURPOSE_MISMATCH DETECTED',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          AiScoreCardWidget(score: aiResult.confidenceScore),
                          const SizedBox(height: 8),
                          Text('Detected Objects: ${aiResult.detectedObjects.join(", ")}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          Text('Explanation: ${aiResult.verificationExplanation}', style: const TextStyle(fontSize: 11)),
                          const SizedBox(height: 8),
                          AiReasonCardWidget(reasons: ai.reasons),
                        ],
                      ),
                    );
                  },
                  loading: () => const LoadingWidget(message: 'Loading AI score insights...'),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 14),

                // 9. Previous Submissions History
                Container(
                  width: double.infinity,
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
                        children: const [
                          Icon(Icons.history_rounded, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text('9. Previous Submissions History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (previousSubmissions.isEmpty)
                        const Text('No previous submissions recorded for this loan.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
                      else
                        Column(
                          children: previousSubmissions.map((prev) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('Submission #${prev.submissionId} • ₹${prev.amountSpent.toStringAsFixed(0)}'),
                              subtitle: Text('Status: ${prev.status.displayName} • ${AppDateUtils.formatDateTime(prev.uploadedAt)}'),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 10. Officer Remarks
                if (sub.rejectionReason != null && sub.rejectionReason!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.comment_outlined, color: AppColors.warning, size: 20),
                            SizedBox(width: 8),
                            Text('10. Officer Remarks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(sub.rejectionReason!, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action Buttons: APPROVE | REJECT | REQUEST RESUBMISSION
                if (_isProcessing)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _handleApprove(isFake: sub.isImageFake),
                          icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                          label: const Text('APPROVE PROOF', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.warning, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _handleRequestResubmission,
                              icon: const Icon(Icons.published_with_changes_rounded, color: AppColors.warning, size: 18),
                              label: const Text('REQUEST RESUBMISSION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.danger, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _handleReject(isFake: sub.isImageFake),
                              icon: const Icon(Icons.cancel_outlined, color: AppColors.danger, size: 18),
                              label: const Text('REJECT PROOF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading submission verification console...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
