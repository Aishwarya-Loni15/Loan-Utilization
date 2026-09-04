import '../../domain/entities/taluka.dart';

class TalukaModel extends TalukaEntity {
  const TalukaModel({
    required super.id,
    required super.districtId,
    required super.name,
  });

  factory TalukaModel.fromMap(Map<String, dynamic> map, String id) {
    return TalukaModel(
      id: id,
      districtId: map['districtId'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'districtId': districtId,
      'name': name,
    };
  }
}
