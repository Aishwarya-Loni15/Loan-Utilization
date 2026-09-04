enum LoanStatus {
  registered,
  linked,
  active,
  completed,
  closed,
  flagged,
  pending,
  partiallyUtilized,
  fullyUtilized,
  disbursed,
  approved,
  underReview,
  rejected;

  String get value {
    switch (this) {
      case LoanStatus.registered:
        return 'REGISTERED';
      case LoanStatus.linked:
        return 'LINKED';
      case LoanStatus.active:
        return 'ACTIVE';
      case LoanStatus.completed:
        return 'COMPLETED';
      case LoanStatus.closed:
        return 'CLOSED';
      case LoanStatus.flagged:
        return 'FLAGGED';
      case LoanStatus.pending:
        return 'PENDING';
      case LoanStatus.partiallyUtilized:
        return 'PARTIALLY_UTILIZED';
      case LoanStatus.fullyUtilized:
        return 'FULLY_UTILIZED';
      case LoanStatus.disbursed:
        return 'DISBURSED';
      case LoanStatus.approved:
        return 'APPROVED';
      case LoanStatus.underReview:
        return 'UNDER_REVIEW';
      case LoanStatus.rejected:
        return 'REJECTED';
    }
  }

  String get displayName {
    switch (this) {
      case LoanStatus.registered:
        return 'Registered';
      case LoanStatus.linked:
        return 'Linked';
      case LoanStatus.active:
        return 'Active';
      case LoanStatus.completed:
        return 'Completed';
      case LoanStatus.closed:
        return 'Closed';
      case LoanStatus.flagged:
        return 'Flagged';
      case LoanStatus.pending:
        return 'Pending';
      case LoanStatus.partiallyUtilized:
        return 'Partially Utilized';
      case LoanStatus.fullyUtilized:
        return 'Fully Utilized';
      case LoanStatus.disbursed:
        return 'Disbursed';
      case LoanStatus.approved:
        return 'Approved';
      case LoanStatus.underReview:
        return 'Under Review';
      case LoanStatus.rejected:
        return 'Rejected';
    }
  }

  static LoanStatus fromString(String? status) {
    switch (status?.toUpperCase()) {
      case 'REGISTERED':
        return LoanStatus.registered;
      case 'LINKED':
        return LoanStatus.linked;
      case 'ACTIVE':
        return LoanStatus.active;
      case 'COMPLETED':
        return LoanStatus.completed;
      case 'CLOSED':
        return LoanStatus.closed;
      case 'FLAGGED':
        return LoanStatus.flagged;
      case 'PARTIALLY_UTILIZED':
        return LoanStatus.partiallyUtilized;
      case 'FULLY_UTILIZED':
        return LoanStatus.fullyUtilized;
      case 'DISBURSED':
        return LoanStatus.disbursed;
      case 'APPROVED':
        return LoanStatus.approved;
      case 'UNDER_REVIEW':
        return LoanStatus.underReview;
      case 'REJECTED':
        return LoanStatus.rejected;
      case 'PENDING':
      default:
        return LoanStatus.pending;
    }
  }
}
