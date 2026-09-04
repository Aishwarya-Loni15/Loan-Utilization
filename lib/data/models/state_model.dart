import '../../domain/entities/state.dart';

class StateModel extends StateEntity {
  const StateModel({
    required super.id,
    required super.name,
    required super.code,
  });

  factory StateModel.fromMap(Map<String, dynamic> map, String id) {
    return StateModel(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}
