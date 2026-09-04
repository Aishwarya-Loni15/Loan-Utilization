import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/data/repositories/loan_repository_impl.dart';
import 'package:laon/domain/entities/loan.dart';
import 'package:laon/domain/repositories/loan_repository.dart';
import 'package:laon/domain/usecases/loans/calculate_utilization.dart';
import 'package:laon/domain/usecases/loans/create_loan.dart';
import 'package:laon/domain/usecases/loans/delete_loan.dart';
import 'package:laon/domain/usecases/loans/get_loan.dart';
import 'package:laon/domain/usecases/loans/get_user_loans.dart';
import 'package:laon/domain/usecases/loans/update_loan.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return LoanRepositoryImpl();
});

final getLoanUseCaseProvider = Provider<GetLoan>((ref) {
  return GetLoan(ref.watch(loanRepositoryProvider));
});

final getUserLoansUseCaseProvider = Provider<GetUserLoans>((ref) {
  return GetUserLoans(ref.watch(loanRepositoryProvider));
});

final createLoanUseCaseProvider = Provider<CreateLoan>((ref) {
  return CreateLoan(ref.watch(loanRepositoryProvider));
});

final updateLoanUseCaseProvider = Provider<UpdateLoan>((ref) {
  return UpdateLoan(ref.watch(loanRepositoryProvider));
});

final deleteLoanUseCaseProvider = Provider<DeleteLoan>((ref) {
  return DeleteLoan(ref.watch(loanRepositoryProvider));
});

final calculateUtilizationUseCaseProvider = Provider<CalculateUtilization>((ref) {
  return CalculateUtilization(ref.watch(loanRepositoryProvider));
});

final allLoansProvider = FutureProvider<List<LoanEntity>>((ref) async {
  final repository = ref.watch(loanRepositoryProvider);
  return await repository.getLoans();
});

final userLoansProvider = FutureProvider<List<LoanEntity>>((ref) async {
  final getUserLoans = ref.watch(getUserLoansUseCaseProvider);
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  return await getUserLoans.call(user.uid, userEmail: user.email);
});

final loanDetailsProvider = FutureProvider.family<LoanEntity?, String>((ref, loanId) async {
  final getLoan = ref.watch(getLoanUseCaseProvider);
  return await getLoan.call(loanId);
});

final bankLoansProvider = FutureProvider<List<LoanEntity>>((ref) async {
  try {
    final repository = ref.watch(loanRepositoryProvider);
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return [];

    final allLoans = await repository.getLoans();
    final userUid = user.uid;
    final userEmail = user.email.trim().toLowerCase();

    // Restrict to ONLY loans added/linked by THIS bank manager
    final matchingLoans = allLoans.where((l) {
      final mgrId = (l.bankManagerId ?? '').trim();
      final isDirectMatch = (mgrId.isNotEmpty && (mgrId == userUid || mgrId.toLowerCase() == userEmail));
      final isLegacySampleMatch = (userUid == 'user_bank_sbi' && (mgrId.isEmpty || mgrId == 'user_bank_sbi'));
      return isDirectMatch || isLegacySampleMatch;
    }).toList();

    return matchingLoans;
  } catch (e) {
    return [];
  }
});
