import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/district_model.dart';
import '../../models/taluka_model.dart';
import '../../models/village_model.dart';

class LocationRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DistrictModel>> getDistricts(String stateId) async {
    final snapshot = await _firestore
        .collection('districts')
        .where('stateId', isEqualTo: stateId)
        .get();
    return snapshot.docs
        .map((doc) => DistrictModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<TalukaModel>> getTalukas(String districtId) async {
    final snapshot = await _firestore
        .collection('talukas')
        .where('districtId', isEqualTo: districtId)
        .get();
    return snapshot.docs
        .map((doc) => TalukaModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<VillageModel>> getVillages(String talukaId) async {
    final snapshot = await _firestore
        .collection('villages')
        .where('talukaId', isEqualTo: talukaId)
        .get();
    return snapshot.docs
        .map((doc) => VillageModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
