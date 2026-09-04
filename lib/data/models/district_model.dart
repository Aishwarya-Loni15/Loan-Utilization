import '../../domain/entities/district.dart';

class DistrictModel extends DistrictEntity {
  const DistrictModel({
    required super.id,
    required super.stateId,
    required super.name,
  });

  factory DistrictModel.fromMap(Map<String, dynamic> map, String id) {
    return DistrictModel(
      id: id,
      stateId: map['stateId'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stateId': stateId,
      'name': name,
    };
  }
}
