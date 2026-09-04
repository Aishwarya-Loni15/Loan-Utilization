class StateModel {
  final String stateId;
  final String name;
  final String code;

  StateModel({required this.stateId, required this.name, required this.code});

  Map<String, dynamic> toMap() => {'stateId': stateId, 'name': name, 'code': code};

  factory StateModel.fromMap(Map<String, dynamic> map, String id) =>
      StateModel(stateId: id, name: map['name'] ?? '', code: map['code'] ?? '');
}

class DistrictModel {
  final String districtId;
  final String stateId;
  final String name;

  DistrictModel({required this.districtId, required this.stateId, required this.name});

  Map<String, dynamic> toMap() => {'districtId': districtId, 'stateId': stateId, 'name': name};

  factory DistrictModel.fromMap(Map<String, dynamic> map, String id) =>
      DistrictModel(districtId: id, stateId: map['stateId'] ?? '', name: map['name'] ?? '');
}

class TalukaModel {
  final String talukaId;
  final String districtId;
  final String name;

  TalukaModel({required this.talukaId, required this.districtId, required this.name});

  Map<String, dynamic> toMap() => {'talukaId': talukaId, 'districtId': districtId, 'name': name};

  factory TalukaModel.fromMap(Map<String, dynamic> map, String id) =>
      TalukaModel(talukaId: id, districtId: map['districtId'] ?? '', name: map['name'] ?? '');
}

class VillageModel {
  final String villageId;
  final String talukaId;
  final String name;

  VillageModel({required this.villageId, required this.talukaId, required this.name});

  Map<String, dynamic> toMap() => {'villageId': villageId, 'talukaId': talukaId, 'name': name};

  factory VillageModel.fromMap(Map<String, dynamic> map, String id) =>
      VillageModel(villageId: id, talukaId: map['talukaId'] ?? '', name: map['name'] ?? '');
}
