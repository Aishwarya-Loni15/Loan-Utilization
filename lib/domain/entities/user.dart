import '../../core/enums/user_role.dart';

class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String state;
  final String district;
  final String taluka;
  final String village;
  final UserRole role;
  final String? bankId;
  final String? branchId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.state,
    required this.district,
    required this.taluka,
    required this.village,
    required this.role,
    this.bankId,
    this.branchId,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  String get userId => uid;
  String get fullName => name;
  String get phoneNumber => phone;
  String get stateId => state;
  String get districtId => district;
  String get talukaId => taluka;
  String get villageId => village;
  String get referenceId => 'REF_${uid.take(6)}';
  bool get isBlocked => !isActive;
}

extension on String {
  String take(int n) => length > n ? substring(0, n) : this;
}
