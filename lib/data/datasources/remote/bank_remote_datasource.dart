import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/bank_model.dart';
import '../mock_database_service.dart';

class BankRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'banks';

  Future<List<BankModel>> getBanks() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      if (snapshot.docs.isNotEmpty) {
        final firestoreBanks = snapshot.docs
            .map((doc) => BankModel.fromMap(doc.data(), doc.id))
            .toList();

        final existingIds = firestoreBanks.map((b) => b.id).toSet();
        for (final bank in firestoreBanks) {
          MockDatabaseService().banks.removeWhere((b) => b.id == bank.id);
          MockDatabaseService().banks.add(bank);
        }

        final mockRemaining = MockDatabaseService().banks.where((b) => !existingIds.contains(b.id));
        return [...firestoreBanks, ...mockRemaining];
      }
    } catch (_) {}

    return List.from(MockDatabaseService().banks);
  }

  Future<BankModel?> getBankById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return BankModel.fromMap(doc.data()!, doc.id);
      }
    } catch (_) {}

    return MockDatabaseService().banks.where((b) => b.id == id).firstOrNull;
  }

  Future<void> createBank(BankModel bank) async {
    try {
      await _firestore.collection(_collection).doc(bank.id).set(bank.toMap());
    } catch (_) {}

    MockDatabaseService().banks.removeWhere((b) => b.id == bank.id);
    MockDatabaseService().banks.add(bank);
  }

  Future<void> updateBank(BankModel bank) async {
    try {
      await _firestore.collection(_collection).doc(bank.id).update(bank.toMap());
    } catch (_) {}

    final idx = MockDatabaseService().banks.indexWhere((b) => b.id == bank.id);
    if (idx != -1) {
      MockDatabaseService().banks[idx] = bank;
    }
  }

  Future<void> assignBankManager(String bankId, String managerId, String managerName) async {
    try {
      await _firestore.collection(_collection).doc(bankId).set({
        'managerId': managerId,
        'managerName': managerName,
      }, SetOptions(merge: true));
    } catch (e) {
      // ignore: avoid_print
      print('BankRemoteDataSource.assignBankManager error: $e');
    }


    final idx = MockDatabaseService().banks.indexWhere((b) => b.id == bankId);
    if (idx != -1) {
      final old = MockDatabaseService().banks[idx];
      MockDatabaseService().banks[idx] = BankModel(
        id: old.id,
        name: old.name,
        branchName: old.branchName,
        ifscCode: old.ifscCode,
        district: old.district,
        state: old.state,
        managerId: managerId,
        managerName: managerName,
        totalLoansDisbursed: old.totalLoansDisbursed,
        totalAmountDisbursed: old.totalAmountDisbursed,
      );
    }
  }
}
