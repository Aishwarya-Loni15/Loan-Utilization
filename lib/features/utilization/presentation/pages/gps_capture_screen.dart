import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/risk_level.dart';
import '../../../../core/enums/submission_status.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/gnss_location_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/services/photo_watermark_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/models/utilization_submission_model.dart';
import '../../../auth/providers/auth_provider.dart';

class GpsCaptureScreen extends ConsumerStatefulWidget {
  final String? loanId;

  const GpsCaptureScreen({super.key, this.loanId});

  @override
  ConsumerState<GpsCaptureScreen> createState() => _GpsCaptureScreenState();
}

class _GpsCaptureScreenState extends ConsumerState<GpsCaptureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _watermarkedPhoto;
  GnssFixResult? _currentGnssFix;
  LiveAddressResult? _liveAddress;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchLiveGnssFix();
    GnssLocationService().startLocationUpdates();
    GnssLocationService().addListener(_onGnssLocationChanged);
  }

  @override
  void dispose() {
    GnssLocationService().removeListener(_onGnssLocationChanged);
    GnssLocationService().stopLocationUpdates();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onGnssLocationChanged() {
    if (mounted) {
      final fix = GnssLocationService().currentFix;
      setState(() {
        _currentGnssFix = fix;
      });
      if (fix != null && fix.latitude != 0.0) {
        _updateAddress(fix.latitude, fix.longitude);
      }
    }
  }

  Future<void> _fetchLiveGnssFix() async {
    final fix = await GnssLocationService().getCurrentGnssFix();
    if (mounted) {
      setState(() {
        _currentGnssFix = fix;
      });
      if (fix.latitude != 0.0) {
        _updateAddress(fix.latitude, fix.longitude);
      }
    }
  }

  Future<void> _updateAddress(double lat, double lng) async {
    final addr = await LocationService().getLiveAddress(lat, lng);
    if (mounted) {
      setState(() {
        _liveAddress = addr;
      });
    }
  }

  Future<void> _captureOrPickPhoto() async {
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
              'LoanLens - Capture Geo-Tagged Proof',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.camera_alt_rounded, color: Colors.white),
              ),
              title: const Text('Camera Capture'),
              subtitle: const Text('Capture photo with mobile camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade600,
                child: const Icon(Icons.photo_library_rounded, color: Colors.white),
              ),
              title: const Text('Device Gallery'),
              subtitle: const Text('Select existing photo from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 90);

      if (pickedFile != null) {
        File photo = File(pickedFile.path);
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = 'raw_proof_${DateTime.now().millisecondsSinceEpoch}.jpg';
          photo = await File(pickedFile.path).copy('${appDir.path}/$fileName');
        } catch (_) {}

        // Ensure satellite GNSS fix is active
        final fix = await GnssLocationService().getCurrentGnssFix();

        if (fix.accuracyCategory == GnssAccuracyCategory.reject) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '❌ Cannot Attach Photo: Satellite GPS accuracy (${fix.accuracy.toStringAsFixed(1)}m) is > 30m limit! Move outdoors away from tall structures.',
                ),
                backgroundColor: AppColors.danger,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        final user = ref.read(currentUserProvider).value;
        final loanId = widget.loanId ?? 'LN000123';
        final benId = user?.uid ?? 'user_ben_01';
        final isOnline = ConnectivityService().isOnline;

        // Apply local photo watermark
        final watermarked = await PhotoWatermarkService().addWatermark(
          photo,
          WatermarkMetadata(
            latitude: fix.latitude,
            longitude: fix.longitude,
            accuracy: fix.accuracy,
            altitude: fix.altitude,
            timestamp: DateTime.now(),
            loanId: loanId,
            beneficiaryId: benId,
            isOnline: isOnline,
            gpsStatus: 'GNSS Satellite',
            villageName: _liveAddress?.villageName ?? 'Ojewadi',
          ),
        );

        setState(() {
          _watermarkedPhoto = watermarked;
          _currentGnssFix = fix;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '📸 Photo Captured & Watermarked Locally! GPS (±${fix.accuracy.toStringAsFixed(1)}m): ${fix.latitude.toStringAsFixed(6)}°, ${fix.longitude.toStringAsFixed(6)}°',
              ),
              backgroundColor: fix.accuracyCategory == GnssAccuracyCategory.good
                  ? AppColors.success
                  : Colors.orange.shade800,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera Error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _submitGeoTaggedProof() async {
    if (_watermarkedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a geotagged photo proof first.')),
      );
      return;
    }

    if (_currentGnssFix == null || !_currentGnssFix!.canCapture) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_currentGnssFix?.statusMessage ?? 'Acquiring valid satellite GNSS fix...'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isProcessing = true);
      try {
        final user = ref.read(currentUserProvider).value;
        final loanId = widget.loanId ?? 'LN000123';
        final benId = user?.uid ?? 'user_ben_01';
        final photoId = const Uuid().v4();
        final amount = double.parse(_amountController.text.trim());
        final isOnline = ConnectivityService().isOnline;
        final now = DateTime.now();

        final submissionModel = UtilizationSubmissionModel(
          submissionId: 'sub_$photoId',
          loanId: loanId,
          beneficiaryId: benId,
          amountSpent: amount,
          description: _descriptionController.text.trim(),
          photoUrls: [_watermarkedPhoto!.path],
          videoUrls: [],
          documentUrls: [],
          latitude: _currentGnssFix!.latitude,
          longitude: _currentGnssFix!.longitude,
          locationAccuracy: _currentGnssFix!.accuracy,
          altitude: _currentGnssFix!.altitude,
          registeredVillage: _liveAddress?.villageName ?? 'Ojewadi',
          gpsSource: _currentGnssFix!.gpsSource,
          isMocked: _currentGnssFix!.isMocked,
          capturedOffline: !isOnline,
          capturedAt: now,
          uploadedAt: now,
          status: SubmissionStatus.underReview,
          riskLevel: _currentGnssFix!.isMocked ? RiskLevel.high : RiskLevel.low,
          createdAt: now,
          updatedAt: now,
          deviceInfo: 'LoanLens GNSS (${isOnline ? "Online" : "Offline Satellite"})',
        );

        // Queue in offline sync engine & local database
        OfflineSyncService().savePendingSubmission(submissionModel);

        AuditLogService().logAction(
          userId: benId,
          role: 'BENEFICIARY',
          action: AuditAction.proofUpload,
          targetId: 'sub_$photoId',
          description:
              'Beneficiary captured geo-tagged proof (Acc: ${_currentGnssFix!.accuracy.toStringAsFixed(1)}m, Net: ${isOnline ? "Online" : "Offline"})',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isOnline
                    ? '✅ Geotagged photo proof uploaded and submitted to Bank Manager!'
                    : '💾 Saved Proof Offline! Live Satellite GPS Lat ${_currentGnssFix!.latitude.toStringAsFixed(5)}°, Lng ${_currentGnssFix!.longitude.toStringAsFixed(5)}° locked. Will auto-sync when online.',
              ),
              backgroundColor: isOnline ? AppColors.success : Colors.orange.shade800,
              duration: const Duration(seconds: 5),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submission Error: ${e.toString()}'), backgroundColor: AppColors.danger),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final loanId = widget.loanId ?? 'LN000123';
    final benId = user?.uid ?? 'user_ben_01';

    final isOnline = ConnectivityService().isOnline;
    final fix = _currentGnssFix;
    final accuracyCat = fix?.accuracyCategory ?? GnssAccuracyCategory.reject;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LoanLens GNSS Geo-Capture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchLiveGnssFix,
            tooltip: 'Refresh GNSS Satellite Fix',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Network Status & Simulator Switch Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.blue.shade50 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isOnline ? Colors.blue.shade300 : Colors.orange.shade700,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOnline ? Icons.wifi_rounded : Icons.cell_tower_rounded,
                        color: isOnline ? Colors.blue.shade700 : Colors.orange.shade900,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOnline ? 'Network Status: 🟢 Online' : 'Network Status: 🔴 Offline (No Internet)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isOnline ? Colors.blue.shade900 : Colors.orange.shade900,
                              ),
                            ),
                            Text(
                              isOnline
                                  ? 'Connected to server. Proofs sync automatically.'
                                  : 'Satellite GNSS operates 100% offline without cellular data/Wi-Fi.',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isOnline,
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
                const SizedBox(height: 16),

                // 2. Satellite GNSS Fix & Accuracy Dashboard Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accuracyCat == GnssAccuracyCategory.good
                        ? AppColors.success.withValues(alpha: 0.08)
                        : (accuracyCat == GnssAccuracyCategory.warning
                            ? Colors.amber.shade50
                            : AppColors.danger.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accuracyCat == GnssAccuracyCategory.good
                          ? AppColors.success
                          : (accuracyCat == GnssAccuracyCategory.warning
                              ? Colors.amber.shade700
                              : AppColors.danger),
                      width: 1.5,
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
                                accuracyCat == GnssAccuracyCategory.good
                                    ? Icons.gps_fixed_rounded
                                    : (accuracyCat == GnssAccuracyCategory.warning
                                        ? Icons.gps_not_fixed_rounded
                                        : Icons.gps_off_rounded),
                                color: accuracyCat == GnssAccuracyCategory.good
                                    ? AppColors.success
                                    : (accuracyCat == GnssAccuracyCategory.warning
                                        ? Colors.amber.shade900
                                        : AppColors.danger),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'GNSS Hardware Satellite Status',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accuracyCat == GnssAccuracyCategory.good
                                  ? AppColors.success
                                  : (accuracyCat == GnssAccuracyCategory.warning
                                      ? Colors.amber.shade800
                                      : AppColors.danger),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              accuracyCat == GnssAccuracyCategory.good
                                  ? '🟢 GOOD (≤10m)'
                                  : (accuracyCat == GnssAccuracyCategory.warning
                                      ? '🟡 WARNING (10-30m)'
                                      : '🔴 REJECT (>30m)'),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (fix != null) ...[
                        if (fix.isMocked) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.danger),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '⚠️ Mock Location / GPS Spoofing Detected! This submission will be flagged for officer review.',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Text(
                          'ACTUAL LIVE GPS LOCATION (Sensor & Offline Spatial Resolution)',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Latitude: ${fix.latitude.toStringAsFixed(6)}° N',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    'Longitude: ${fix.longitude.toStringAsFixed(6)}° E',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    '📍 Village: ${_liveAddress?.villageName ?? "Resolving village..."}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                                  ),
                                  Text(
                                    'Source: ${fix.gpsSource} Hardware (${_liveAddress?.isOffline ?? true ? "Offline Spatial" : "Online Geocoded"})',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Accuracy: ±${fix.accuracy.toStringAsFixed(1)} m',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: accuracyCat == GnssAccuracyCategory.good
                                          ? AppColors.success
                                          : (accuracyCat == GnssAccuracyCategory.warning
                                              ? Colors.amber.shade900
                                              : AppColors.danger),
                                    ),
                                  ),
                                  Text(
                                    'Altitude: ${fix.altitude.toStringAsFixed(1)} m',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    'Network: ${isOnline ? "Online" : "Offline"}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Captured: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(fix.timestamp)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const Divider(height: 16),
                        const Text(
                          'REGISTERED LOCATION (Reference Only)',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Registered Village: Ojewadi  |  District: Solapur',
                          style: TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Loan ID: $loanId  |  Beneficiary ID: $benId',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ] else ...[
                        const Row(
                          children: [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 10),
                            Text('Acquiring direct GNSS satellite signals...', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          fix?.statusMessage ?? 'Connecting to onboard GNSS hardware...',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accuracyCat == GnssAccuracyCategory.good
                                ? AppColors.success
                                : (accuracyCat == GnssAccuracyCategory.warning
                                    ? Colors.amber.shade900
                                    : AppColors.danger),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Photo Capture & Preview Area
                const Text('Photo Evidence with Local Watermark', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _captureOrPickPhoto,
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: _watermarkedPhoto != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Image.file(_watermarkedPhoto!, width: double.infinity, height: 220, fit: BoxFit.cover),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 14),
                                        SizedBox(width: 4),
                                        Text('Watermarked Locally', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.camera_alt_rounded, size: 30, color: AppColors.primary),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Tap to Capture Geo-Tagged Photo',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                              ),
                              const Text(
                                'Burns GPS Lat/Lng & Accuracy locally onto image',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Form Fields: Amount Spent & Details
                AppTextField(
                  controller: _amountController,
                  label: 'Utilization Spent Amount (₹)',
                  hint: 'Enter spent amount',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.payments_rounded,
                  validator: (v) => Validators.validateNumber(v, 'Spent Amount'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Utilization Purpose & Details',
                  hint: 'Describe purchase or utilization',
                  maxLines: 2,
                  validator: (v) => Validators.validateRequired(v, 'Utilization Details'),
                ),
                const SizedBox(height: 20),

                // 5. Main Action Button: Submit Geo-Tagged Proof
                AppButton(
                  text: '📸 SUBMIT GEO-TAGGED PROOF',
                  isLoading: _isProcessing,
                  onPressed: (fix != null && fix.canCapture && _watermarkedPhoto != null)
                      ? _submitGeoTaggedProof
                      : null,
                ),
                const SizedBox(height: 24),

                // 6. Pending Offline Submissions Queue List
                const Text('Offline Pending Sync Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                ListenableBuilder(
                  listenable: OfflineSyncService(),
                  builder: (context, _) {
                    final pending = OfflineSyncService().pendingCache;
                    if (pending.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.cloud_done_rounded, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text('All geotagged photos are synchronized with Cloud Firestore.', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: pending.map((item) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              item.isSynced ? Icons.check_circle_rounded : Icons.sync_rounded,
                              color: item.isSynced ? Colors.green : Colors.orange,
                            ),
                            title: Text('Proof #${item.submission.submissionId}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              'Lat ${item.submission.latitude.toStringAsFixed(4)}°, Lng ${item.submission.longitude.toStringAsFixed(4)}° | ₹${item.submission.amountSpent.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.isSynced ? Colors.green.shade100 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.isSynced ? 'Synced' : 'Pending Sync',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: item.isSynced ? Colors.green.shade900 : Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
