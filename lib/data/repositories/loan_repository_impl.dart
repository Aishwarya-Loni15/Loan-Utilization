import '../../core/enums/loan_status.dart';
import '../../core/errors/firebase_exception_handler.dart';
import '../../domain/entities/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../datasources/remote/loan_remote_datasource.dart';
import '../models/loan_model.dart';

class LoanRepositoryImpl implements LoanRepository {
  final LoanRemoteDataSource _remoteDataSource;

  LoanRepositoryImpl({LoanRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? LoanRemoteDataSource();

  @override
  Future<List<LoanEntity>> getLoans() async {
    try {
      return await _remoteDataSource.getLoans();
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<List<LoanEntity>> getUserLoans(String userId, {String? userEmail}) async {
    try {
      return await _remoteDataSource.getUserLoans(userId, userEmail: userEmail);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<LoanEntity?> getLoanById(String loanId) async {
    try {
      return await _remoteDataSource.getLoanById(loanId);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> createLoan(LoanEntity loan) async {
    try {
      final model = LoanModel(
        loanId: loan.loanId,
        beneficiaryId: loan.beneficiaryId,
        bankId: loan.bankId,
        bankManagerId: loan.bankManagerId,
        schemeName: loan.schemeName,
        purpose: loan.purpose,
        category: loan.category,
        sanctionedAmount: loan.sanctionedAmount,
        disbursedAmount: loan.disbursedAmount,
        utilizedAmount: loan.utilizedAmount,
        remainingAmount: loan.remainingAmount,
        utilizationPercentage: loan.utilizationPercentage,
        disbursementDate: loan.disbursementDate,
        expectedUtilizationDate: loan.expectedUtilizationDate,
        status: loan.status,
        createdAt: loan.createdAt,
        updatedAt: loan.updatedAt,
        loanAccountNumber: loan.loanAccountNumber,
        beneficiaryName: loan.beneficiaryName,
        beneficiaryMobile: loan.beneficiaryMobile,
        beneficiaryEmail: loan.beneficiaryEmail,
        bankName: loan.bankName,
        branchName: loan.branchName,
        district: loan.district,
        taluka: loan.taluka,
        village: loan.village,
        isLinked: loan.isLinked,
      );
      await _remoteDataSource.createLoan(model);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> updateLoan(LoanEntity loan) async {
    try {
      final model = LoanModel(
        loanId: loan.loanId,
        beneficiaryId: loan.beneficiaryId,
        bankId: loan.bankId,
        bankManagerId: loan.bankManagerId,
        schemeName: loan.schemeName,
        purpose: loan.purpose,
        category: loan.category,
        sanctionedAmount: loan.sanctionedAmount,
        disbursedAmount: loan.disbursedAmount,
        utilizedAmount: loan.utilizedAmount,
        remainingAmount: loan.remainingAmount,
        utilizationPercentage: loan.utilizationPercentage,
        disbursementDate: loan.disbursementDate,
        expectedUtilizationDate: loan.expectedUtilizationDate,
        status: loan.status,
        createdAt: loan.createdAt,
        updatedAt: loan.updatedAt,
        loanAccountNumber: loan.loanAccountNumber,
        beneficiaryName: loan.beneficiaryName,
        beneficiaryMobile: loan.beneficiaryMobile,
        beneficiaryEmail: loan.beneficiaryEmail,
        bankName: loan.bankName,
        branchName: loan.branchName,
        district: loan.district,
        taluka: loan.taluka,
        village: loan.village,
        isLinked: loan.isLinked,
      );
      await _remoteDataSource.updateLoan(model);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<LoanEntity> calculateUtilization(String loanId, double additionalUtilizedAmount) async {
    try {
      final existingLoan = await _remoteDataSource.getLoanById(loanId);
      if (existingLoan == null) {
        throw Exception('Loan record not found.');
      }

      final newUtilized = existingLoan.utilizedAmount + additionalUtilizedAmount;
      final newRemaining = (existingLoan.disbursedAmount - newUtilized).clamp(0.0, double.infinity);
      final newPercentage = existingLoan.disbursedAmount > 0
          ? ((newUtilized / existingLoan.disbursedAmount) * 100).clamp(0.0, 100.0)
          : 0.0;

      LoanStatus newStatus = existingLoan.status;
      if (newPercentage >= 100) {
        newStatus = LoanStatus.completed;
      } else if (newPercentage > 0) {
        newStatus = LoanStatus.active;
      }

      final updatedModel = LoanModel(
        loanId: existingLoan.loanId,
        beneficiaryId: existingLoan.beneficiaryId,
        bankId: existingLoan.bankId,
        bankManagerId: existingLoan.bankManagerId,
        schemeName: existingLoan.schemeName,
        purpose: existingLoan.purpose,
        category: existingLoan.category,
        sanctionedAmount: existingLoan.sanctionedAmount,
        disbursedAmount: existingLoan.disbursedAmount,
        utilizedAmount: newUtilized,
        remainingAmount: newRemaining,
        utilizationPercentage: newPercentage,
        disbursementDate: existingLoan.disbursementDate,
        expectedUtilizationDate: existingLoan.expectedUtilizationDate,
        status: newStatus,
        createdAt: existingLoan.createdAt,
        updatedAt: DateTime.now(),
        loanAccountNumber: existingLoan.loanAccountNumber,
        beneficiaryName: existingLoan.beneficiaryName,
        beneficiaryMobile: existingLoan.beneficiaryMobile,
        beneficiaryEmail: existingLoan.beneficiaryEmail,
        bankName: existingLoan.bankName,
        branchName: existingLoan.branchName,
        district: existingLoan.district,
        taluka: existingLoan.taluka,
        village: existingLoan.village,
        isLinked: existingLoan.isLinked,
      );


      await _remoteDataSource.updateLoan(updatedModel);
      return updatedModel;
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> deleteLoan(String loanId) async {
    try {
      await _remoteDataSource.deleteLoan(loanId);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  // Compatibility helpers
  Future<List<LoanEntity>> getAllLoans() => getLoans();
  Future<List<LoanEntity>> getLoansForBeneficiary(String id) => getUserLoans(id);
  Future<List<LoanEntity>> getLoansForBank(String bankId) async {
    final all = await getLoans();
    return all.where((l) => l.bankId == bankId).toList();
  }
}
