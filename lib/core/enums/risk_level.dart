enum RiskLevel {
  low,
  medium,
  high;

  String get value {
    switch (this) {
      case RiskLevel.low:
        return 'LOW';
      case RiskLevel.medium:
        return 'MEDIUM';
      case RiskLevel.high:
        return 'HIGH';
    }
  }

  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  static RiskLevel fromString(String? level) {
    switch (level?.toUpperCase()) {
      case 'HIGH':
        return RiskLevel.high;
      case 'MEDIUM':
        return RiskLevel.medium;
      case 'LOW':
      default:
        return RiskLevel.low;
    }
  }

  static RiskLevel fromScore(double score) {
    if (score >= 80) return RiskLevel.low;
    if (score >= 50) return RiskLevel.medium;
    return RiskLevel.high;
  }
}
