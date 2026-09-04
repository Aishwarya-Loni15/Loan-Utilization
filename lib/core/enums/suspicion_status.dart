enum SuspicionStatus {
  normal('Normal', 'No suspicious signals detected'),
  reviewRequired('Review Required', 'Requires manual review by Bank Manager/Officer'),
  suspicious('Suspicious', 'Flagged as high-risk / potential anomaly');

  final String label;
  final String description;

  const SuspicionStatus(this.label, this.description);

  static SuspicionStatus fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'SUSPICIOUS':
      case 'HIGH':
        return SuspicionStatus.suspicious;
      case 'REVIEW_REQUIRED':
      case 'MEDIUM':
        return SuspicionStatus.reviewRequired;
      case 'NORMAL':
      case 'LOW':
      default:
        return SuspicionStatus.normal;
    }
  }
}
