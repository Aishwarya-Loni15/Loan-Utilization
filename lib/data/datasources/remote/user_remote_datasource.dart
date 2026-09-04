import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../models/user_model.dart';
import '../mock_database_service.dart';

class UserRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel userModel) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userModel.uid)
          .set(userModel.toMap(), SetOptions(merge: true));
    } catch (e) {
      // Log Firestore write error for diagnostic visibility
      // ignore: avoid_print
      print('UserRemoteDataSource.createUser Firestore write error: $e');
    }

    MockDatabaseService().users.removeWhere((u) => u.uid == userModel.uid);
    MockDatabaseService().users.add(userModel);
  }


  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 3));

      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromMap(doc.data()!, doc.id);
        MockDatabaseService().users.removeWhere((u) => u.uid == user.uid);
        MockDatabaseService().users.add(user);
        return user;
      }
    } catch (_) {}

    final mockUser = MockDatabaseService().users.where((u) => u.uid == uid).firstOrNull;
    return mockUser;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return null;

    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where('email', isEqualTo: cleanEmail)
          .get()
          .timeout(const Duration(seconds: 3));

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final user = UserModel.fromMap(doc.data(), doc.id);
        MockDatabaseService().users.removeWhere((u) => u.uid == user.uid);
        MockDatabaseService().users.add(user);
        return user;
      }
    } catch (_) {}

    return MockDatabaseService()
        .users
        .where((u) => u.email.trim().toLowerCase() == cleanEmail)
        .firstOrNull;
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .get()
          .timeout(const Duration(seconds: 3));
      if (snapshot.docs.isNotEmpty) {
        final firestoreUsers = snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList();

        final existingUids = firestoreUsers.map((u) => u.uid).toSet();
        for (final user in firestoreUsers) {
          MockDatabaseService().users.removeWhere((u) => u.uid == user.uid);
          MockDatabaseService().users.add(user);
        }

        final mockRemaining = MockDatabaseService().users.where((u) => !existingUids.contains(u.uid));
        return [...firestoreUsers, ...mockRemaining];
      }
    } catch (_) {}

    return List.from(MockDatabaseService().users);
  }
}
