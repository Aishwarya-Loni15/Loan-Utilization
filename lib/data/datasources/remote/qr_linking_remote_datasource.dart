import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/qr_linking_token_model.dart';
import '../../models/loan_model.dart';
import '../mock_database_service.dart';

class QrLinkingRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _tokenCollection = 'qr_linking_tokens';
  static const String _loansCollection = 'loans';

  /// Generates a unique, temporary, single-use linking token for a registered offline loan.
  Future<QrLinkingTokenModel> createToken({
    required String loanId,
    required String bankId,
    required String bankManagerId,
    Duration validity = const Duration(minutes: 15),
  }) async {
    final randomSuffix = List.generate(8, (_) => Random().nextInt(36).toRadixString(36).toUpperCase()).join();
    final tokenId = 'LL-TOKEN-$randomSuffix';

    final now = DateTime.now();
    final tokenModel = QrLinkingTokenModel(
      tokenId: tokenId,
      loanId: loanId,
      bankId: bankId,
      bankManagerId: bankManagerId,
      createdAt: now,
      expiresAt: now.add(validity),
      isUsed: false,
    );

    try {
      await _firestore.collection(_tokenCollection).doc(tokenId).set(tokenModel.toMap());
    } catch (_) {}

    // Synchronize to MockDatabaseService for offline/in-memory fallback
    MockDatabaseService().qrTokens.removeWhere((t) => t.tokenId == tokenId);
    MockDatabaseService().qrTokens.add(tokenModel);

    return tokenModel;
  }

  /// Retrieves a token by its token ID.
  Future<QrLinkingTokenModel?> getToken(String tokenId) async {
    final cleanToken = tokenId.trim().toUpperCase();

    try {
      final doc = await _firestore.collection(_tokenCollection).doc(cleanToken).get();
      if (doc.exists && doc.data() != null) {
        return QrLinkingTokenModel.fromMap(doc.data()!, doc.id);
      }
    } catch (_) {}

    return MockDatabaseService().qrTokens.where((t) => t.tokenId == cleanToken).firstOrNull;
  }

  /// Redeems the token and links the loan to the beneficiary.
  Future<LoanModel> redeemAndLinkLoan({
    required String tokenId,
    required String beneficiaryId,
    String? beneficiaryName,
    String? beneficiaryMobile,
  }) async {
    final cleanToken = tokenId.trim().toUpperCase();
    final tokenModel = await getToken(cleanToken);

    if (tokenModel == null) {
      throw Exception('Invalid QR Token. Token not found.');
    }

    if (tokenModel.isUsed) {
      throw Exception('This QR Token has already been used.');
    }

    if (tokenModel.isExpired) {
      throw Exception('This QR Token has expired. Please ask your bank manager to generate a new QR.');
    }

    final loanId = tokenModel.loanId;
    final now = DateTime.now();

    // 1. Update Token doc in Firestore
    try {
      await _firestore.collection(_tokenCollection).doc(cleanToken).update({
        'isUsed': true,
        'redeemedByBeneficiaryId': beneficiaryId,
        'redeemedAt': now.toIso8601String(),
      });
    } catch (_) {}

    // 2. Update Loan doc in Firestore
    final updateData = <String, dynamic>{
      'beneficiaryId': beneficiaryId,
      'bankManagerId': tokenModel.bankManagerId,
      'createdBy': tokenModel.bankManagerId,
      'isLinked': true,
      'updatedAt': now.toIso8601String(),
    };
    if (beneficiaryName != null && beneficiaryName.isNotEmpty) {
      updateData['beneficiaryName'] = beneficiaryName;
    }
    if (beneficiaryMobile != null && beneficiaryMobile.isNotEmpty) {
      updateData['beneficiaryMobile'] = beneficiaryMobile;
    }

    try {
      await _firestore.collection(_loansCollection).doc(loanId).update(updateData);
    } catch (_) {}

    // Update local mock database service
    final tokenIdx = MockDatabaseService().qrTokens.indexWhere((t) => t.tokenId == cleanToken);
    if (tokenIdx != -1) {
      MockDatabaseService().qrTokens[tokenIdx] = QrLinkingTokenModel(
        tokenId: tokenModel.tokenId,
        loanId: tokenModel.loanId,
        bankId: tokenModel.bankId,
        bankManagerId: tokenModel.bankManagerId,
        createdAt: tokenModel.createdAt,
        expiresAt: tokenModel.expiresAt,
        isUsed: true,
        redeemedByBeneficiaryId: beneficiaryId,
      );
    }

    final loanIdx = MockDatabaseService().loans.indexWhere((l) => l.loanId == loanId);
    if (loanIdx != -1) {
      final oldLoan = MockDatabaseService().loans[loanIdx];
      final updatedLoan = LoanModel(
        loanId: oldLoan.loanId,
        beneficiaryId: beneficiaryId,
        bankId: oldLoan.bankId,
        bankManagerId: tokenModel.bankManagerId,
        schemeName: oldLoan.schemeName,
        purpose: oldLoan.purpose,
        category: oldLoan.category,
        sanctionedAmount: oldLoan.sanctionedAmount,
        disbursedAmount: oldLoan.disbursedAmount,
        utilizedAmount: oldLoan.utilizedAmount,
        remainingAmount: oldLoan.remainingAmount,
        utilizationPercentage: oldLoan.utilizationPercentage,
        disbursementDate: oldLoan.disbursementDate,
        expectedUtilizationDate: oldLoan.expectedUtilizationDate,
        status: oldLoan.status,
        createdAt: oldLoan.createdAt,
        updatedAt: now,
        loanAccountNumber: oldLoan.loanAccountNumber,
        beneficiaryName: beneficiaryName ?? oldLoan.beneficiaryName,
        beneficiaryMobile: beneficiaryMobile ?? oldLoan.beneficiaryMobile,
        bankName: oldLoan.bankName,
        branchName: oldLoan.branchName,
        district: oldLoan.district,
        taluka: oldLoan.taluka,
        village: oldLoan.village,
        isLinked: true,
      );
      MockDatabaseService().loans[loanIdx] = updatedLoan;
      return updatedLoan;
    }

    // Return current remote loan state
    final loanDoc = await _firestore.collection(_loansCollection).doc(loanId).get();
    if (loanDoc.exists && loanDoc.data() != null) {
      return LoanModel.fromMap(loanDoc.data()!, loanDoc.id);
    }

    throw Exception('Loan record $loanId not found.');
  }

  /// Manually invalidates an active token.
  Future<void> invalidateToken(String tokenId) async {
    final cleanToken = tokenId.trim().toUpperCase();
    try {
      await _firestore.collection(_tokenCollection).doc(cleanToken).update({
        'isInvalidated': true,
      });
    } catch (_) {}

    final tokenIdx = MockDatabaseService().qrTokens.indexWhere((t) => t.tokenId == cleanToken);
    if (tokenIdx != -1) {
      final old = MockDatabaseService().qrTokens[tokenIdx];
      MockDatabaseService().qrTokens[tokenIdx] = QrLinkingTokenModel(
        tokenId: old.tokenId,
        loanId: old.loanId,
        bankId: old.bankId,
        bankManagerId: old.bankManagerId,
        createdAt: old.createdAt,
        expiresAt: old.expiresAt,
        isUsed: old.isUsed,
        isInvalidated: true,
        redeemedByBeneficiaryId: old.redeemedByBeneficiaryId,
      );
    }
  }
}
