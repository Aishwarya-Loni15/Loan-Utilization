import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/state_model.dart';

class StateRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<StateModel>> getStates() async {
    final snapshot = await _firestore.collection('states').get();
    return snapshot.docs
        .map((doc) => StateModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
