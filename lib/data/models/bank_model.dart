import '../../domain/entities/bank.dart';

class BankModel extends BankEntity {
  const BankModel({
    required super.id,
    required super.name,
    required super.branchName,
    required super.ifscCode,
    required super.district,
    required super.state,
    super.managerId,
    super.managerName,
    super.totalLoansDisbursed,
    super.totalAmountDisbursed,
  });

  factory BankModel.fromMap(Map<String, dynamic> map, String id) {
    return BankModel(
      id: id,
      name: map['name'] ?? '',
      branchName: map['branchName'] ?? '',
      ifscCode: map['ifscCode'] ?? '',
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      managerId: map['managerId'],
      managerName: map['managerName'],
      totalLoansDisbursed: map['totalLoansDisbursed'] ?? 0,
      totalAmountDisbursed: (map['totalAmountDisbursed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'branchName': branchName,
      'ifscCode': ifscCode,
      'district': district,
      'state': state,
      'managerId': managerId,
      'managerName': managerName,
      'totalLoansDisbursed': totalLoansDisbursed,
      'totalAmountDisbursed': totalAmountDisbursed,
    };
  }
}
