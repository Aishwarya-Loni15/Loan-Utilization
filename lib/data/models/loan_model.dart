import '../../core/enums/loan_status.dart';
import '../../domain/entities/loan.dart';

class LoanModel extends LoanEntity {
  const LoanModel({
    required super.loanId,
    required super.beneficiaryId,
    required super.bankId,
    required super.schemeName,
    required super.purpose,
    required super.category,
    required super.sanctionedAmount,
    required super.disbursedAmount,
    required super.utilizedAmount,
    required super.remainingAmount,
    required super.utilizationPercentage,
    required super.disbursementDate,
    required super.expectedUtilizationDate,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.bankManagerId,
    super.loanAccountNumber,
    super.beneficiaryName,
    super.beneficiaryMobile,
    super.beneficiaryEmail,
    super.bankName,
    super.branchName,
    super.state,
    super.district,
    super.taluka,
    super.village,
    super.isLinked,
  });

  factory LoanModel.fromMap(Map<String, dynamic> map, String id) {
    final sanctioned = (map['sanctionedAmount'] as num?)?.toDouble() ?? (map['loanAmount'] as num?)?.toDouble() ?? 0.0;
    final disbursed = (map['disbursedAmount'] as num?)?.toDouble() ?? 0.0;
    final utilized = (map['utilizedAmount'] as num?)?.toDouble() ?? 0.0;
    final remaining = (disbursed - utilized).clamp(0.0, double.infinity);
    final percentage = disbursed > 0 ? ((utilized / disbursed) * 100).clamp(0.0, 100.0) : 0.0;
    final benId = map['beneficiaryId'] as String? ?? '';
    final isLinkedVal = map['isLinked'] as bool? ?? benId.isNotEmpty;
    final mgrId = map['bankManagerId'] as String? ?? map['createdBy'] as String? ?? map['bankManager'] as String? ?? 'user_bank_sbi';

    return LoanModel(
      loanId: id,
      beneficiaryId: benId,
      bankId: map['bankId'] ?? '',
      schemeName: map['schemeName'] ?? '',
      purpose: map['purpose'] ?? '',
      category: map['category'] ?? 'General',
      sanctionedAmount: sanctioned,
      disbursedAmount: disbursed,
      utilizedAmount: utilized,
      remainingAmount: remaining,
      utilizationPercentage: percentage,
      disbursementDate: map['disbursementDate'] != null ? DateTime.parse(map['disbursementDate']) : DateTime.now(),
      expectedUtilizationDate: map['expectedUtilizationDate'] != null ? DateTime.parse(map['expectedUtilizationDate']) : DateTime.now().add(const Duration(days: 90)),
      status: LoanStatus.fromString(map['status']),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
      bankManagerId: mgrId,
      loanAccountNumber: map['loanAccountNumber'] ?? map['loanAccountNo'] ?? id,
      beneficiaryName: map['beneficiaryName'],
      beneficiaryMobile: map['beneficiaryMobile'],
      beneficiaryEmail: map['beneficiaryEmail'],
      bankName: map['bankName'],
      branchName: map['branchName'] ?? map['branch'],
      state: map['state'] ?? 'Maharashtra',
      district: map['district'] ?? 'Solapur',
      taluka: map['taluka'] ?? 'Pandharpur',
      village: map['village'] ?? 'Kavathe',
      isLinked: isLinkedVal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loanId': loanId,
      'beneficiaryId': beneficiaryId,
      'bankId': bankId,
      'bankManagerId': bankManagerId ?? 'user_bank_sbi',
      'createdBy': bankManagerId ?? 'user_bank_sbi',
      'schemeName': schemeName,
      'purpose': purpose,
      'category': category,
      'sanctionedAmount': sanctionedAmount,
      'disbursedAmount': disbursedAmount,
      'utilizedAmount': utilizedAmount,
      'remainingAmount': remainingAmount,
      'utilizationPercentage': utilizationPercentage,
      'disbursementDate': disbursementDate.toIso8601String(),
      'expectedUtilizationDate': expectedUtilizationDate.toIso8601String(),
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'loanAccountNumber': loanAccountNumber ?? loanId,
      'beneficiaryName': beneficiaryName,
      'beneficiaryMobile': beneficiaryMobile,
      'beneficiaryEmail': beneficiaryEmail,
      'bankName': bankName,
      'branchName': branchName,
      'state': state ?? 'Maharashtra',
      'district': district ?? 'Solapur',
      'taluka': taluka ?? 'Pandharpur',
      'village': village ?? 'Kavathe',
      'isLinked': isLinked,
    };
  }

  double get loanAmount => sanctionedAmount;
}

