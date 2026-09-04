enum VerificationStatus {
  unverified,
  aiVerified,
  officerVerified,
  rejected;

  String get value {
    switch (this) {
      case VerificationStatus.unverified:
        return 'UNVERIFIED';
      case VerificationStatus.aiVerified:
        return 'AI_VERIFIED';
      case VerificationStatus.officerVerified:
        return 'OFFICER_VERIFIED';
      case VerificationStatus.rejected:
        return 'REJECTED';
    }
  }

  String get displayName {
    switch (this) {
      case VerificationStatus.unverified:
        return 'Unverified';
      case VerificationStatus.aiVerified:
        return 'AI Verified';
      case VerificationStatus.officerVerified:
        return 'Officer Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  static VerificationStatus fromString(String? status) {
    switch (status?.toUpperCase()) {
      case 'AI_VERIFIED':
        return VerificationStatus.aiVerified;
      case 'OFFICER_VERIFIED':
        return VerificationStatus.officerVerified;
      case 'REJECTED':
        return VerificationStatus.rejected;
      case 'UNVERIFIED':
      default:
        return VerificationStatus.unverified;
    }
  }
}
