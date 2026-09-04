enum SubmissionStatus {
  notSubmitted,
  submitted,
  aiProcessing,
  aiVerified,
  underOfficerReview,
  approved,
  rejected,
  resubmissionRequired;

  String get value {
    switch (this) {
      case SubmissionStatus.notSubmitted:
        return 'NOT_SUBMITTED';
      case SubmissionStatus.submitted:
        return 'SUBMITTED';
      case SubmissionStatus.aiProcessing:
        return 'AI_PROCESSING';
      case SubmissionStatus.aiVerified:
        return 'AI_VERIFIED';
      case SubmissionStatus.underOfficerReview:
        return 'UNDER_OFFICER_REVIEW';
      case SubmissionStatus.approved:
        return 'APPROVED';
      case SubmissionStatus.rejected:
        return 'REJECTED';
      case SubmissionStatus.resubmissionRequired:
        return 'RESUBMISSION_REQUIRED';
    }
  }

  String get displayName {
    switch (this) {
      case SubmissionStatus.notSubmitted:
        return 'Not Submitted';
      case SubmissionStatus.submitted:
        return 'Submitted';
      case SubmissionStatus.aiProcessing:
        return 'AI Processing';
      case SubmissionStatus.aiVerified:
        return 'AI Verified';
      case SubmissionStatus.underOfficerReview:
        return 'Under Officer Review';
      case SubmissionStatus.approved:
        return 'Approved';
      case SubmissionStatus.rejected:
        return 'Rejected';
      case SubmissionStatus.resubmissionRequired:
        return 'Resubmission Required';
    }
  }

  static SubmissionStatus fromString(String? status) {
    switch (status?.toUpperCase()) {
      case 'NOT_SUBMITTED':
        return SubmissionStatus.notSubmitted;
      case 'SUBMITTED':
        return SubmissionStatus.submitted;
      case 'AI_PROCESSING':
        return SubmissionStatus.aiProcessing;
      case 'AI_VERIFIED':
        return SubmissionStatus.aiVerified;
      case 'UNDER_OFFICER_REVIEW':
      case 'UNDER_REVIEW':
        return SubmissionStatus.underOfficerReview;
      case 'APPROVED':
        return SubmissionStatus.approved;
      case 'REJECTED':
        return SubmissionStatus.rejected;
      case 'RESUBMISSION_REQUIRED':
      case 'MORE_INFO_REQUESTED':
        return SubmissionStatus.resubmissionRequired;
      case 'PENDING':
      default:
        return SubmissionStatus.submitted;
    }
  }

  static SubmissionStatus get underReview => SubmissionStatus.underOfficerReview;
  static SubmissionStatus get moreInfoRequested => SubmissionStatus.resubmissionRequired;
  static SubmissionStatus get pending => SubmissionStatus.submitted;
}
