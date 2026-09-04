import '../../domain/entities/beneficiary.dart';

class BeneficiaryModel extends Beneficiary {
  const BeneficiaryModel({
    required super.beneficiaryId,
    required super.userId,
    required super.name,
    required super.phone,
    required super.address,
    required super.state,
    required super.district,
    required super.taluka,
    required super.village,
    required super.createdAt,
  });

  factory BeneficiaryModel.fromMap(Map<String, dynamic> map, String id) {
    return BeneficiaryModel(
      beneficiaryId: id.isNotEmpty ? id : (map['beneficiaryId'] ?? ''),
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      state: map['state'] ?? '',
      district: map['district'] ?? '',
      taluka: map['taluka'] ?? '',
      village: map['village'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'beneficiaryId': beneficiaryId,
      'userId': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'state': state,
      'district': district,
      'taluka': taluka,
      'village': village,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
