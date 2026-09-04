import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/enums/loan_status.dart';
import 'package:laon/core/utils/validators.dart';
import 'package:laon/core/widgets/app_button.dart';
import 'package:laon/core/widgets/app_text_field.dart';
import 'package:laon/data/datasources/remote/user_remote_datasource.dart';
import 'package:laon/data/models/user_model.dart';
import 'package:laon/domain/entities/loan.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import 'package:laon/features/loans/providers/loan_provider.dart';

class CreateLoanPage extends ConsumerStatefulWidget {
  const CreateLoanPage({super.key});

  @override
  ConsumerState<CreateLoanPage> createState() => _CreateLoanPageState();
}

class _CreateLoanPageState extends ConsumerState<CreateLoanPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'ramesh.farmer@gmail.com');
  final _schemeController = TextEditingController();
  final _purposeController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Agriculture');
  final _sanctionedController = TextEditingController();
  final _disbursedController = TextEditingController();

  bool _isLoading = false;
  bool _isSearchingUser = false;
  UserModel? _matchedBeneficiary;
  String? _userLookupError;

  @override
  void initState() {
    super.initState();
    _lookupBeneficiaryByEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _schemeController.dispose();
    _purposeController.dispose();
    _categoryController.dispose();
    _sanctionedController.dispose();
    _disbursedController.dispose();
    super.dispose();
  }

  Future<void> _lookupBeneficiaryByEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _matchedBeneficiary = null;
        _userLookupError = 'Please enter a registered beneficiary email.';
      });
      return;
    }

    setState(() {
      _isSearchingUser = true;
      _userLookupError = null;
    });

    try {
      final user = await UserRemoteDataSource().getUserByEmail(email);
      if (user != null) {
        setState(() {
          _matchedBeneficiary = user;
          _userLookupError = null;
        });
      } else {
        setState(() {
          _matchedBeneficiary = null;
          _userLookupError = 'No registered user found for "$email". Only registered emails can be assigned a loan and access it.';
        });
      }
    } catch (e) {
      setState(() {
        _matchedBeneficiary = null;
        _userLookupError = 'Error checking user registration: $e';
      });
    } finally {
      if (mounted) setState(() => _isSearchingUser = false);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_matchedBeneficiary == null) {
      await _lookupBeneficiaryByEmail();
      if (!mounted) return;
      if (_matchedBeneficiary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_userLookupError ?? 'Only registered emails can be assigned a loan.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final managerUser = ref.read(currentUserProvider).value;
      final sanctioned = double.parse(_sanctionedController.text.trim());
      final disbursed = double.parse(_disbursedController.text.trim());
      final now = DateTime.now();

      final ben = _matchedBeneficiary!;

      final newLoan = LoanEntity(
        loanId: 'loan_${now.millisecondsSinceEpoch}',
        beneficiaryId: ben.uid,
        beneficiaryName: ben.name,
        beneficiaryMobile: ben.phone,
        beneficiaryEmail: ben.email,
        bankId: managerUser?.bankId ?? 'bnk_sbi_sol',
        bankManagerId: managerUser?.uid ?? 'user_bank_sbi',
        state: ben.state.isNotEmpty ? ben.state : 'st_mah',
        district: ben.district.isNotEmpty ? ben.district : 'dst_sol',
        taluka: ben.taluka.isNotEmpty ? ben.taluka : 'tlk_pan',
        village: ben.village.isNotEmpty ? ben.village : 'vlg_kav',
        schemeName: _schemeController.text.trim(),
        purpose: _purposeController.text.trim(),
        category: _categoryController.text.trim(),
        sanctionedAmount: sanctioned,
        disbursedAmount: disbursed,
        utilizedAmount: 0.0,
        remainingAmount: disbursed,
        utilizationPercentage: 0.0,
        disbursementDate: now,
        expectedUtilizationDate: now.add(const Duration(days: 90)),
        status: LoanStatus.active,
        createdAt: now,
        updatedAt: now,
        isLinked: true,
      );

      await ref.read(createLoanUseCaseProvider).call(newLoan);
      if (mounted) {
        ref.invalidate(allLoansProvider);
        ref.invalidate(userLoansProvider);
        ref.invalidate(bankLoansProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loan created successfully for registered beneficiary ${ben.name} (${ben.email})!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disburse New Loan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sanction & Disburse Capital',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Assign loan details to a registered email beneficiary.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Registered Beneficiary Email Lookup Section
                const Text(
                  'Registered Beneficiary Email',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _emailController,
                        label: 'Beneficiary Registered Email',
                        hint: 'e.g. ramesh.farmer@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) => Validators.validateEmail(v),
                        onChanged: (_) {
                          if (_matchedBeneficiary != null || _userLookupError != null) {
                            setState(() {
                              _matchedBeneficiary = null;
                              _userLookupError = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: OutlinedButton.icon(
                        onPressed: _isSearchingUser ? null : _lookupBeneficiaryByEmail,
                        icon: _isSearchingUser
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.person_search_rounded),
                        label: const Text('Verify'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Beneficiary Lookup Status / Details Preview Card
                if (_matchedBeneficiary != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 22),
                            const SizedBox(width: 8),
                            const Text(
                              'Registered Beneficiary Found',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 14),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Text('• Name: ${_matchedBeneficiary!.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('• Email: ${_matchedBeneficiary!.email}', style: const TextStyle(fontSize: 13)),
                        Text('• Mobile: ${_matchedBeneficiary!.phone}', style: const TextStyle(fontSize: 13)),
                        Text('• UID (Beneficiary Key): ${_matchedBeneficiary!.uid}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('• Location: ${_matchedBeneficiary!.village}, ${_matchedBeneficiary!.taluka}, ${_matchedBeneficiary!.district}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else if (_userLookupError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _userLookupError!,
                            style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                AppTextField(
                  controller: _schemeController,
                  label: 'Scheme Name',
                  hint: 'PM-KISAN Agri Infrastructure Loan',
                  validator: (v) => Validators.validateRequired(v, 'Scheme Name'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _purposeController,
                  label: 'Loan Utilization Purpose',
                  hint: 'Tractor purchase & Solar pump installation',
                  validator: (v) => Validators.validateRequired(v, 'Purpose'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _categoryController,
                  label: 'Sector Category',
                  hint: 'Agriculture / Micro-Enterprise / Animal Husbandry',
                  validator: (v) => Validators.validateRequired(v, 'Category'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _sanctionedController,
                        label: 'Sanctioned Amount (₹)',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.currency_rupee_rounded,
                        onChanged: (val) {
                          if (_disbursedController.text.isEmpty) {
                            _disbursedController.text = val;
                          }
                          setState(() {});
                        },
                        validator: (v) => Validators.validateNumber(v, 'Sanctioned Amount'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _disbursedController,
                        label: 'Disbursed Amount (₹)',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.account_balance_wallet_outlined,
                        onChanged: (_) => setState(() {}),
                        validator: (v) => Validators.validateNumber(v, 'Disbursed Amount'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Loan Amount Redirection Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horizontal_circle_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Loan Amount Redirection to Beneficiary',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₹${_disbursedController.text.trim().isEmpty ? (_sanctionedController.text.trim().isEmpty ? "0" : _sanctionedController.text.trim()) : _disbursedController.text.trim()} redirected & credited to ${_matchedBeneficiary?.name ?? "registered beneficiary"}',
                              style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Confirm & Disburse Loan',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
