class BankEntity {
  final String id;
  final String name;
  final String branchName;
  final String ifscCode;
  final String district;
  final String state;
  final String? managerId;
  final String? managerName;
  final int totalLoansDisbursed;
  final double totalAmountDisbursed;

  const BankEntity({
    required this.id,
    required this.name,
    required this.branchName,
    required this.ifscCode,
    required this.district,
    required this.state,
    this.managerId,
    this.managerName,
    this.totalLoansDisbursed = 0,
    this.totalAmountDisbursed = 0.0,
  });
}
