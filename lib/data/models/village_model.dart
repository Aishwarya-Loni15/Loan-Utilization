import '../../domain/entities/village.dart';

class VillageModel extends VillageEntity {
  const VillageModel({
    required super.id,
    required super.talukaId,
    required super.name,
  });

  factory VillageModel.fromMap(Map<String, dynamic> map, String id) {
    return VillageModel(
      id: id,
      talukaId: map['talukaId'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'talukaId': talukaId,
      'name': name,
    };
  }
}
