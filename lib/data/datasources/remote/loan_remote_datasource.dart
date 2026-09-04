import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/loan_model.dart';
import '../mock_database_service.dart';

class LoanRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'loans';

  Future<List<LoanModel>> getLoans() async {
    try {
      final snapshot = await _firestore.collection(_collection).get().timeout(const Duration(seconds: 3));
      if (snapshot.docs.isNotEmpty) {
        final firestoreLoans = snapshot.docs
            .map((doc) => LoanModel.fromMap(doc.data(), doc.id))
            .toList();

        final existingIds = firestoreLoans.map((l) => l.loanId).toSet();
        for (final loan in firestoreLoans) {
          MockDatabaseService().loans.removeWhere((l) => l.loanId == loan.loanId);
          MockDatabaseService().loans.add(loan);
        }

        final mockRemaining = MockDatabaseService().loans.where((l) => !existingIds.contains(l.loanId));
        return [...firestoreLoans, ...mockRemaining];
      }
    } catch (_) {}

    return List.from(MockDatabaseService().loans);
  }

  Future<List<LoanModel>> getUserLoans(String userId, {String? userEmail}) async {
    final Map<String, LoanModel> resultMap = {};

    try {
      final snapshotByUid = await _firestore
          .collection(_collection)
          .where('beneficiaryId', isEqualTo: userId)
          .get();
      for (var doc in snapshotByUid.docs) {
        resultMap[doc.id] = LoanModel.fromMap(doc.data(), doc.id);
      }

      if (userEmail != null && userEmail.trim().isNotEmpty) {
        final cleanEmail = userEmail.trim().toLowerCase();
        final snapshotByEmail = await _firestore
            .collection(_collection)
            .where('beneficiaryEmail', isEqualTo: cleanEmail)
            .get();
        for (var doc in snapshotByEmail.docs) {
          resultMap[doc.id] = LoanModel.fromMap(doc.data(), doc.id);
        }
      }

      if (resultMap.isNotEmpty) {
        return resultMap.values.toList();
      }
    } catch (_) {}

    final cleanEmail = (userEmail ?? '').trim().toLowerCase();
    return MockDatabaseService()
        .loans
        .where((l) =>
            l.beneficiaryId == userId ||
            l.beneficiaryId.contains(userId) ||
            (cleanEmail.isNotEmpty && l.beneficiaryEmail?.toLowerCase() == cleanEmail))
        .toList();
  }

  Future<LoanModel?> getLoanById(String loanId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(loanId).get();
      if (doc.exists && doc.data() != null) {
        return LoanModel.fromMap(doc.data()!, doc.id);
      }
    } catch (_) {}

    return MockDatabaseService().loans.where((l) => l.loanId == loanId).firstOrNull;
  }

  Future<void> createLoan(LoanModel loan) async {
    try {
      await _firestore.collection(_collection).doc(loan.loanId).set(loan.toMap());
    } catch (_) {}

    MockDatabaseService().loans.removeWhere((l) => l.loanId == loan.loanId);
    MockDatabaseService().loans.add(loan);
  }

  Future<void> updateLoan(LoanModel loan) async {
    try {
      await _firestore.collection(_collection).doc(loan.loanId).update(loan.toMap());
    } catch (_) {}

    final idx = MockDatabaseService().loans.indexWhere((l) => l.loanId == loan.loanId);
    if (idx != -1) {
      MockDatabaseService().loans[idx] = loan;
    }
  }

  Future<void> deleteLoan(String loanId) async {
    try {
      await _firestore.collection(_collection).doc(loanId).delete();
    } catch (_) {}

    MockDatabaseService().loans.removeWhere((l) => l.loanId == loanId);
  }
}
