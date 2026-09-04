import '../../core/errors/firebase_exception_handler.dart';
import '../../domain/entities/bank.dart';
import '../../domain/repositories/bank_repository.dart';
import '../datasources/remote/bank_remote_datasource.dart';
import '../models/bank_model.dart';

class BankRepositoryImpl implements BankRepository {
  final BankRemoteDataSource _remoteDataSource;

  BankRepositoryImpl({BankRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? BankRemoteDataSource();

  @override
  Future<List<BankEntity>> getBanks() async {
    try {
      return await _remoteDataSource.getBanks();
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<BankEntity?> getBankById(String id) async {
    try {
      return await _remoteDataSource.getBankById(id);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> createBank(BankEntity bank) async {
    try {
      final model = BankModel(
        id: bank.id,
        name: bank.name,
        branchName: bank.branchName,
        ifscCode: bank.ifscCode,
        district: bank.district,
        state: bank.state,
        managerId: bank.managerId,
        managerName: bank.managerName,
        totalLoansDisbursed: bank.totalLoansDisbursed,
        totalAmountDisbursed: bank.totalAmountDisbursed,
      );
      await _remoteDataSource.createBank(model);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> updateBank(BankEntity bank) async {
    try {
      final model = BankModel(
        id: bank.id,
        name: bank.name,
        branchName: bank.branchName,
        ifscCode: bank.ifscCode,
        district: bank.district,
        state: bank.state,
        managerId: bank.managerId,
        managerName: bank.managerName,
        totalLoansDisbursed: bank.totalLoansDisbursed,
        totalAmountDisbursed: bank.totalAmountDisbursed,
      );
      await _remoteDataSource.updateBank(model);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> assignBankManager(String bankId, String managerId, String managerName) async {
    try {
      await _remoteDataSource.assignBankManager(bankId, managerId, managerName);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }
}
