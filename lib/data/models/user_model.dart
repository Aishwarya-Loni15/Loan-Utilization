import '../../core/enums/user_role.dart';
import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    required super.state,
    required super.district,
    required super.taluka,
    required super.village,
    required super.role,
    super.bankId,
    super.branchId,
    super.createdAt,
    super.updatedAt,
    super.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    final role = UserRole.fromString(map['role']);
    final rawBankId = map['bankId']?.toString();
    final bankId = (rawBankId != null && rawBankId.isNotEmpty)
        ? rawBankId
        : (role == UserRole.bankManager ? 'bnk_sbi_sol' : null);

    return UserModel(
      uid: id.isNotEmpty ? id : (map['userId'] ?? map['uid'] ?? ''),
      name: map['name'] ?? map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      state: map['stateId'] ?? map['state'] ?? '',
      district: map['districtId'] ?? map['district'] ?? '',
      taluka: map['talukaId'] ?? map['taluka'] ?? '',
      village: map['villageId'] ?? map['village'] ?? '',
      role: role,
      bankId: bankId,
      branchId: map['branchId'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': uid,
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'stateId': state,
      'districtId': district,
      'talukaId': taluka,
      'villageId': village,
      'role': role.value,
      'bankId': bankId,
      'branchId': branchId,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      'isActive': isActive,
    };
  }
}
