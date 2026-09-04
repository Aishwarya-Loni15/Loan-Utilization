import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/ai_verification_engine.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/models/utilization_submission_model.dart';
import '../../../loans/providers/loan_provider.dart';
import '../../../location/providers/location_provider.dart';
import '../../providers/utilization_provider.dart';
import '../widgets/document_picker.dart';
import '../widgets/evidence_picker.dart';
import '../widgets/evidence_preview.dart';

import '../widgets/upload_progress.dart';
import '../widgets/video_picker.dart';

class CreateSubmissionPage extends ConsumerStatefulWidget {
  final String? loanId;

  const CreateSubmissionPage({super.key, this.loanId});


  @override
  ConsumerState<CreateSubmissionPage> createState() =>
      _CreateSubmissionPageState();
}

class _CreateSubmissionPageState extends ConsumerState<CreateSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _photoFile;
  File? _videoFile;
  File? _docFile;
  LocationCaptureData? _locationData;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatusText = '';

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isLocating = false;

  Future<void> _pickPhoto() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Proof Photo Source',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.camera_alt_rounded, color: Colors.white),
              ),
              title: const Text('Camera Photo'),
              subtitle: const Text('Capture live geotagged photo with camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade600,
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                ),
              ),
              title: const Text('Gallery Photo'),
              subtitle: const Text('Select existing photo from device gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Copy captured image to permanent Application Documents Directory so it persists after USB disconnection
        File photo = File(pickedFile.path);
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final fileName =
              'geotag_proof_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final permanentPath = '${appDir.path}/$fileName';
          photo = await File(pickedFile.path).copy(permanentPath);
        } catch (_) {
          // Fallback to picked file if directory access fails
        }

        final locationSvc = LocationService();
        final photoGeotag = await locationSvc.extractPhotoGeotag(photo);
        final liveAddr = await locationSvc.getLiveAddress(
          photoGeotag.latitude,
          photoGeotag.longitude,
        );
        final locData = LocationCaptureData(
          latitude: photoGeotag.latitude,
          longitude: photoGeotag.longitude,
          accuracy: photoGeotag.isFromExif ? 1.0 : 4.2,
          timestamp: DateTime.now(),
          villageName: liveAddr.villageName,
          areaName: liveAddr.areaName,
          districtName: liveAddr.districtName,
          cityName: '${liveAddr.areaName}, ${liveAddr.districtName}',
          stateName: liveAddr.stateName,
          isFromPhotoExif: photoGeotag.isFromExif,
          isPhotoGeotag: true,
          isOfflineCaptured: liveAddr.isOffline || !ConnectivityService().isOnline,
        );

        final detectedAmt = AiVerificationEngine().extractReceiptAmount(photo.path, 150000.0);

        setState(() {
          _photoFile = photo;
          _locationData = locData;
          if (_amountController.text.trim().isEmpty || (double.tryParse(_amountController.text.trim()) ?? 0.0) == 0.0) {
            _amountController.text = detectedAmt.toStringAsFixed(0);
          }
        });

        if (mounted) {
          final isOffline = locData.isOfflineCaptured;
          final sourceDesc = photoGeotag.isFromExif
              ? 'Photo EXIF Tag'
              : (isOffline ? 'Offline Mobile Satellite GPS' : 'Live Photo Capture');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '📸 Photo Attached! Geotag ($sourceDesc): ${liveAddr.villageName}, ${liveAddr.areaName} (${photoGeotag.latitude.toStringAsFixed(4)}°, ${photoGeotag.longitude.toStringAsFixed(4)}°) locked for Bank Manager.',
              ),
              backgroundColor: isOffline ? Colors.orange.shade800 : AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Media/Location Error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _captureGPS() async {
    setState(() => _isLocating = true);
    try {
      final locationSvc = LocationService();
      final pos = await locationSvc.getCurrentPosition();
      final liveAddr = await locationSvc.getLiveAddress(
        pos.latitude,
        pos.longitude,
      );
      final locData = LocationCaptureData(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        timestamp: pos.timestamp,
        villageName: liveAddr.villageName,
        areaName: liveAddr.areaName,
        districtName: liveAddr.districtName,
        cityName: '${liveAddr.areaName}, ${liveAddr.districtName}',
        stateName: liveAddr.stateName,
        isOfflineCaptured: liveAddr.isOffline || !ConnectivityService().isOnline,
      );
      setState(() {
        _locationData = locData;
      });
      if (mounted) {
        final isOffline = locData.isOfflineCaptured;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isOffline
                  ? '📡 Offline Satellite GPS Lock! Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)} (±${pos.accuracy.toStringAsFixed(1)}m) locked from mobile device satellite chip.'
                  : '🎯 Automatic GPS Lock Acquired! Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)} (±${pos.accuracy.toStringAsFixed(1)}m)',
            ),
            backgroundColor: isOffline ? Colors.orange.shade800 : AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location Error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _submit() async {
    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture geotag photo evidence first.'),
        ),
      );
      return;
    }

    if (_locationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please acquire GPS location coordinates.'),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.1;
        _uploadStatusText = 'Preparing evidence package...';
      });

      try {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          _uploadProgress = 0.4;
          _uploadStatusText = 'Uploading geotag photo & site video...';
        });

        await Future.delayed(const Duration(milliseconds: 400));
        setState(() {
          _uploadProgress = 0.7;
          _uploadStatusText = 'Uploading invoice document & geotag metadata...';
        });

        final amount = double.parse(_amountController.text.trim());
        final now = DateTime.now();
        final subId = 'sub_${now.millisecondsSinceEpoch}';

        // Retrieve linked loan purpose and disbursed amount
        final loans = ref.read(allLoansProvider).value ?? [];
        final linkedLoan = loans
            .where((l) => l.loanId == (widget.loanId ?? 'loan_agri_201'))
            .firstOrNull;
        final loanDisbursed = linkedLoan?.disbursedAmount ?? 200000.0;
        final remainingBal = linkedLoan?.remainingAmount ?? loanDisbursed;

        final activeProofPath = _docFile?.path ?? _photoFile?.path ?? '';
        final detectedReceiptAmt = activeProofPath.isNotEmpty
            ? AiVerificationEngine().extractReceiptAmount(activeProofPath, 150000.0)
            : null;

        if (amount > remainingBal) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '❌ Cannot Submit: Spent amount (₹${amount.toStringAsFixed(0)}) is greater than remaining loan amount (₹${remainingBal.toStringAsFixed(0)})!',
                ),
                backgroundColor: AppColors.danger,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        if (detectedReceiptAmt != null && amount > detectedReceiptAmt) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '❌ Cannot Submit: Spent amount (₹${amount.toStringAsFixed(0)}) is MORE than the amount specified on receipt proof (₹${detectedReceiptAmt.toStringAsFixed(0)})! Only the right receipt amount can be taken.',
                ),
                backgroundColor: AppColors.danger,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        final isOnline = ConnectivityService().isOnline && OfflineSyncService().isOnline;

        final submittedEntity = await ref
            .read(submitEvidenceNotifierProvider.notifier)
            .submit(
              loanId: widget.loanId ?? 'loan_agri_201',
              amountSpent: amount,
              description: _descriptionController.text.trim(),
              photoUrls: [_photoFile!.path],
              videoUrls: _videoFile != null ? [_videoFile!.path] : [],
              documentUrls: _docFile != null ? [_docFile!.path] : [],
              latitude: _locationData!.latitude,
              longitude: _locationData!.longitude,
              accuracy: _locationData!.accuracy,
              aiScore: 0.0,
              aiAnalysis: null,
            );

        if (!isOnline) {
          final model = UtilizationSubmissionModel(
            submissionId: submittedEntity.submissionId,
            loanId: submittedEntity.loanId,
            beneficiaryId: submittedEntity.beneficiaryId,
            amountSpent: submittedEntity.amountSpent,
            description: submittedEntity.description,
            photoUrls: submittedEntity.photoUrls,
            videoUrls: submittedEntity.videoUrls,
            documentUrls: submittedEntity.documentUrls,
            latitude: submittedEntity.latitude,
            longitude: submittedEntity.longitude,
            locationAccuracy: submittedEntity.locationAccuracy,
            capturedAt: submittedEntity.capturedAt,
            uploadedAt: submittedEntity.uploadedAt,
            status: submittedEntity.status,
            riskLevel: submittedEntity.riskLevel,
            createdAt: submittedEntity.createdAt,
            updatedAt: submittedEntity.updatedAt,
          );
          OfflineSyncService().savePendingSubmission(model);
        }

        // Audit Logging & Offline Sync Service
        AuditLogService().logAction(
          userId: 'user_ben_01',
          role: 'BENEFICIARY',
          action: AuditAction.proofUpload,
          targetId: subId,
          description: isOnline
              ? 'Beneficiary submitted geotagged proof for ₹${amount.toStringAsFixed(0)}'
              : 'Beneficiary created offline proof with mobile satellite GPS for ₹${amount.toStringAsFixed(0)}',
        );

        setState(() {
          _uploadProgress = 1.0;
          _uploadStatusText = isOnline
              ? 'Submission Package Verified & Synced Successfully!'
              : 'Saved Offline! Geotagged Satellite GPS Proof Queued for Auto-Sync.';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isOnline
                    ? '✅ Geotagged photo proof submitted! Direct notification & evidence sent to Bank Manager for audit.'
                    : '💾 Saved Proof Offline! Live Satellite GPS coordinates (${_locationData!.latitude.toStringAsFixed(4)}°, ${_locationData!.longitude.toStringAsFixed(4)}°) locked. Proof will auto-sync to Bank Manager when internet is restored.',
              ),
              backgroundColor: isOnline ? AppColors.success : Colors.orange.shade800,
              duration: const Duration(seconds: 5),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loans = ref.watch(allLoansProvider).value ?? [];
    final linkedLoan = loans
        .where((l) => l.loanId == (widget.loanId ?? 'loan_agri_201'))
        .firstOrNull;
    final totalDisbursed = linkedLoan?.disbursedAmount ?? 200000.0;
    final remainingBal = linkedLoan?.remainingAmount ?? 15000.0;

    final activeProofPath = _docFile?.path ?? _photoFile?.path ?? '';
    final activePhotoPath = _photoFile?.path ?? '';
    final activeDesc = _descriptionController.text.trim();
    final isAiGeneratedImage = (activePhotoPath.isNotEmpty && AiVerificationEngine.isAiGeneratedPhoto(activePhotoPath, activeDesc)) ||
        (_docFile != null && AiVerificationEngine.isAiGeneratedPhoto(_docFile!.path, activeDesc));
    final isFakeImage = (activePhotoPath.isNotEmpty && AiVerificationEngine.isFakePhoto(activePhotoPath, activeDesc)) ||
        (_docFile != null && AiVerificationEngine.isFakePhoto(_docFile!.path, activeDesc)) ||
        activeDesc.toLowerCase().contains('fake');

    final detectedReceiptAmt = activeProofPath.isNotEmpty
        ? AiVerificationEngine().extractReceiptAmount(activeProofPath, 150000.0)
        : null;

    final enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final isExcessOfRemaining = enteredAmount > remainingBal;
    final isExcessOfReceipt = detectedReceiptAmt != null && enteredAmount > detectedReceiptAmt;
    final isFakeOrWrongAmount = isExcessOfReceipt || isFakeImage || isAiGeneratedImage;

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Utilization Evidence')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Network Status & Offline Mobile GPS Mode Toggle Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ConnectivityService().isOnline
                        ? Colors.blue.shade50
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ConnectivityService().isOnline
                          ? Colors.blue.shade300
                          : Colors.orange.shade700,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        ConnectivityService().isOnline
                            ? Icons.wifi_rounded
                            : Icons.cell_tower_rounded,
                        color: ConnectivityService().isOnline
                            ? Colors.blue.shade700
                            : Colors.orange.shade900,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ConnectivityService().isOnline
                                  ? 'Network Connected (Online)'
                                  : 'Out of Network / Offline Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: ConnectivityService().isOnline
                                    ? Colors.blue.shade900
                                    : Colors.orange.shade900,
                              ),
                            ),
                            Text(
                              ConnectivityService().isOnline
                                  ? 'Proofs sync immediately to Bank Manager.'
                                  : 'Hardware Satellite GPS records coordinates offline without internet.',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: ConnectivityService().isOnline,
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: Colors.blue.shade200,
                        inactiveThumbColor: Colors.orange.shade800,
                        inactiveTrackColor: Colors.orange.shade200,
                        onChanged: (online) {
                          setState(() {
                            ConnectivityService().setConnectivityState(online);
                            OfflineSyncService().toggleOnlineStatus(online);
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Bank Manager Disbursed Total Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Bank Manager Disbursed Capital',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Static Total',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Disbursed: ₹${totalDisbursed.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Remaining Balance: ₹${remainingBal.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: remainingBal > 0 ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Proof of Utilization Media Picker
                const SizedBox(height: 8),
                Text(
                  'Attach Proof of Utilization (Photo / PDF)',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                EvidencePickerWidget(
                  photoFile: _photoFile,
                  videoFile: _videoFile,
                  documentFile: _docFile,
                  onPickPhoto: _pickPhoto,
                  onPickVideo: () {},
                  onPickDocument: () {},
                ),
                const SizedBox(height: 12),
                VideoPickerWidget(
                  videoFile: _videoFile,
                  onVideoCaptured: (file) => setState(() => _videoFile = file),
                ),
                const SizedBox(height: 12),
                DocumentPickerWidget(
                  documentFile: _docFile,
                  onDocumentPicked: (file) {
                    final detected = AiVerificationEngine().extractReceiptAmount(file.path, 150000.0);
                    setState(() {
                      _docFile = file;
                      if (_amountController.text.trim().isEmpty || (double.tryParse(_amountController.text.trim()) ?? 0.0) == 0.0) {
                        _amountController.text = detected.toStringAsFixed(0);
                      }
                    });
                  },
                ),

                const SizedBox(height: 16),

                // 3. Utilization Spent Amount Input (Auto-filled to match Photo/PDF amount)
                AppTextField(
                  controller: _amountController,
                  label: 'Utilization Spent Amount (₹)',
                  hint: 'Should match amount in photo/PDF receipt',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.payments_rounded,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final err = Validators.validateNumber(v, 'Spent Amount');
                    if (err != null) return err;
                    final val = double.tryParse(v?.trim() ?? '') ?? 0.0;
                    if (val > remainingBal) {
                      return 'Spent amount cannot be greater than remaining loan amount (₹${remainingBal.toStringAsFixed(0)})!';
                    }
                    if (detectedReceiptAmt != null && val > detectedReceiptAmt) {
                      return '❌ EXCESS AMOUNT: Spent amount (₹${val.toStringAsFixed(0)}) exceeds receipt proof amount (₹${detectedReceiptAmt.toStringAsFixed(0)})!';
                    }
                    return null;
                  },
                ),

                // Excess Warnings
                if (isExcessOfRemaining) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.danger,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '❌ EXCESS AMOUNT ALERT: Entered spent amount (₹${enteredAmount.toStringAsFixed(0)}) is greater than the remaining loan amount (₹${remainingBal.toStringAsFixed(0)})!',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (isExcessOfReceipt) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.danger,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '❌ EXCESS RECEIPT AMOUNT ALERT: Entered spent amount (₹${enteredAmount.toStringAsFixed(0)}) is MORE than the amount specified on receipt/proof (₹${detectedReceiptAmt.toStringAsFixed(0)})!',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Only the exact right amount (₹${detectedReceiptAmt.toStringAsFixed(0)}) given on the receipt or proof can be submitted.',
                          style: const TextStyle(fontSize: 11, color: AppColors.danger),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                            label: Text(
                              'Fix Amount to Exact Receipt Value (₹${detectedReceiptAmt.toStringAsFixed(0)})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            onPressed: () {
                              setState(() {
                                _amountController.text = detectedReceiptAmt.toStringAsFixed(0);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (isAiGeneratedImage) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade900.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.purple.shade800,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.purple.shade800,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🤖 AI-GENERATED FAKE IMAGE DETECTED',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'This uploaded image is detected as AI-Generated and is FLAGGED AS FAKE! It will be shown as a Fake Image to Officers & Bank Managers.',
                                style: TextStyle(fontSize: 11, color: Colors.purple.shade900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isFakeImage) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.gpp_bad_rounded,
                          color: AppColors.danger,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '⚠️ FAKE / TAMPERED IMAGE DETECTED',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.danger,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'This uploaded photo is detected as FAKE / TAMPERED and will be shown as a Fake Image to Officers & Bank Managers.',
                                style: TextStyle(fontSize: 11, color: AppColors.danger),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isFakeOrWrongAmount) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.shade800,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '⚠️ WRONG ENTERED AMOUNT / FAKE DATA ALERT: The entered spent amount differs from attached proof document receipt or contains suspicious proof data.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Utilization Details',
                  maxLines: 3,
                  validator: (v) =>
                      Validators.validateRequired(v, 'Description'),
                ),

                const SizedBox(height: 16),
                EvidencePreviewWidget(
                  photoFile: _photoFile,
                  videoFile: _videoFile,
                  documentFile: _docFile,
                  onRemovePhoto: () => setState(() => _photoFile = null),
                  onRemoveVideo: () => setState(() => _videoFile = null),
                  onRemoveDocument: () => setState(() => _docFile = null),
                ),
                const SizedBox(height: 16),
                if (_locationData != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _locationData!.isOfflineCaptured
                          ? Colors.orange.shade50
                          : AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _locationData!.isOfflineCaptured
                            ? Colors.orange.shade400
                            : AppColors.success.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _locationData!.isOfflineCaptured
                                  ? Icons.cell_tower_rounded
                                  : Icons.verified_rounded,
                              color: _locationData!.isOfflineCaptured
                                  ? Colors.orange.shade800
                                  : AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationData!.isOfflineCaptured
                                    ? '📡 Hardware Satellite GPS Locked (Offline)'
                                    : (_locationData!.isPhotoGeotag
                                        ? '📸 Geotag Photo Location Locked for Manager'
                                        : 'Automatic GPS Geotag Locked'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: _locationData!.isOfflineCaptured
                                      ? Colors.orange.shade900
                                      : AppColors.success,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _locationData!.isOfflineCaptured
                                    ? Colors.orange.shade700
                                    : AppColors.success,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _locationData!.isOfflineCaptured
                                    ? 'Offline Satellite GPS'
                                    : '±${_locationData!.accuracy.toStringAsFixed(1)}m Accuracy',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_locationData!.isOfflineCaptured) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.wifi_off_rounded, size: 14, color: Colors.orange),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'NO INTERNET CONNECTION: Geolocation captured directly via mobile device hardware satellite chip without active data network.',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Latitude: ${_locationData!.latitude.toStringAsFixed(6)}° N',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Longitude: ${_locationData!.longitude.toStringAsFixed(6)}° E',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📍 Village Name: ${_locationData!.villageName ?? "Ojewadi"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '🏢 City / District: ${_locationData!.cityName ?? "Ojewadi, Solapur District"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '🏛️ State: ${_locationData!.stateName ?? "Maharashtra"}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Captured At: ${_locationData!.timestamp}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLocating ? null : _captureGPS,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: _locationData != null
                            ? AppColors.success
                            : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    icon: _isLocating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _locationData != null
                                ? Icons.gps_fixed_rounded
                                : Icons.my_location_rounded,
                            color: _locationData != null
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                    label: Text(
                      _isLocating
                          ? 'Acquiring High-Precision GPS Lock...'
                          : _locationData != null
                          ? 'Re-Acquire Automatic GPS Geotag'
                          : 'Acquire Automatic GPS Geotag',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _locationData != null
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isUploading) ...[
                  UploadProgressWidget(
                    progress: _uploadProgress,
                    statusText: _uploadStatusText,
                  ),
                  const SizedBox(height: 16),
                ],
                AppButton(
                  text: 'Submit Evidence Package',
                  isLoading: _isUploading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
