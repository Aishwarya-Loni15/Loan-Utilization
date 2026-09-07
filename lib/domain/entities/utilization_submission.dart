import '../../core/enums/risk_level.dart';
import '../../core/enums/submission_status.dart';
import '../../core/services/ai_verification_engine.dart';

class UtilizationSubmissionEntity {
  final String submissionId;
  final String loanId;
  final String beneficiaryId;
  final double amountSpent;
  final String description;
  final List<String> photoUrls;
  final List<String> videoUrls;
  final List<String> documentUrls;
  final double latitude;
  final double longitude;
  final double locationAccuracy;
  final double altitude;
  final String registeredVillage;
  final String gpsSource;
  final bool isMocked;
  final bool capturedOffline;
  final DateTime capturedAt;
  final DateTime uploadedAt;
  final SubmissionStatus status;
  final double? aiScore;
  final RiskLevel riskLevel;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final String? deviceInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UtilizationSubmissionEntity({
    required this.submissionId,
    required this.loanId,
    required this.beneficiaryId,
    required this.amountSpent,
    required this.description,
    required this.photoUrls,
    required this.videoUrls,
    required this.documentUrls,
    required this.latitude,
    required this.longitude,
    required this.locationAccuracy,
    this.altitude = 0.0,
    this.registeredVillage = 'Ojewadi',
    this.gpsSource = 'GNSS',
    this.isMocked = false,
    this.capturedOffline = false,
    required this.capturedAt,
    required this.uploadedAt,
    required this.status,
    this.aiScore,
    required this.riskLevel,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    this.deviceInfo = 'Android 14 (Mobile Geotagged)',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAiGeneratedImage {
    final photo = photoUrls.isNotEmpty ? photoUrls.first : '';
    return AiVerificationEngine.isAiGeneratedPhoto(photo, description);
  }

  bool get isImageFake {
    final photo = photoUrls.isNotEmpty ? photoUrls.first : '';
    return isAiGeneratedImage ||
        AiVerificationEngine.isFakePhoto(photo, description) ||
        description.toLowerCase().contains('fake') ||
        photo.toLowerCase().contains('fake');
  }

  String get fileType {
    if (photoUrls.isNotEmpty && videoUrls.isEmpty && documentUrls.isEmpty) return 'photo';
    if (videoUrls.isNotEmpty && photoUrls.isEmpty && documentUrls.isEmpty) return 'video';
    if (documentUrls.isNotEmpty && photoUrls.isEmpty && videoUrls.isEmpty) return 'document';
    return 'mixed';
  }

  String get fileUrl => photoUrls.isNotEmpty ? photoUrls.first : (videoUrls.isNotEmpty ? videoUrls.first : (documentUrls.isNotEmpty ? documentUrls.first : ''));
  DateTime get submittedAt => uploadedAt;
  String get aiStatus => (isMocked || riskLevel == RiskLevel.high || isImageFake) ? 'PURPOSE_MISMATCH' : 'PURPOSE_MATCH';
  double get aiConfidence => aiScore ?? 92.5;
  String get officerStatus => status.value;
  String? get officerRemarks => rejectionReason;
}

