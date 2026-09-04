class Beneficiary {
  final String beneficiaryId;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final String state;
  final String district;
  final String taluka;
  final String village;
  final DateTime createdAt;

  const Beneficiary({
    required this.beneficiaryId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.state,
    required this.district,
    required this.taluka,
    required this.village,
    required this.createdAt,
  });
}
