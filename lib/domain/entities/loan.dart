import '../../core/enums/loan_status.dart';

class LoanEntity {
  final String loanId;
  final String beneficiaryId;
  final String bankId;
  final String schemeName;
  final String purpose;
  final String category;
  final double sanctionedAmount;
  final double disbursedAmount;
  final double utilizedAmount;
  final double remainingAmount;
  final double utilizationPercentage;
  final DateTime disbursementDate;
  final DateTime expectedUtilizationDate;
  final LoanStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? bankManagerId;
  final String? loanAccountNumber;
  final String? beneficiaryName;
  final String? beneficiaryMobile;
  final String? beneficiaryEmail;
  final String? bankName;
  final String? branchName;
  final String? state;
  final String? district;
  final String? taluka;
  final String? village;
  final bool isLinked;

  const LoanEntity({
    required this.loanId,
    required this.beneficiaryId,
    required this.bankId,
    required this.schemeName,
    required this.purpose,
    required this.category,
    required this.sanctionedAmount,
    required this.disbursedAmount,
    required this.utilizedAmount,
    required this.remainingAmount,
    required this.utilizationPercentage,
    required this.disbursementDate,
    required this.expectedUtilizationDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.bankManagerId,
    this.loanAccountNumber,
    this.beneficiaryName,
    this.beneficiaryMobile,
    this.beneficiaryEmail,
    this.bankName,
    this.branchName,
    this.state,
    this.district,
    this.taluka,
    this.village,
    this.isLinked = false,
  });

  String get branchId => branchName ?? 'br_sbi_sol';
  double get amount => sanctionedAmount;
  DateTime get sanctionDate => createdAt;
}

