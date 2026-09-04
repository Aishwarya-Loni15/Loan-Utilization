import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/loan_status.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loan_qr_dialog.dart';
import '../../../../domain/entities/loan.dart';
import '../../../../data/datasources/remote/user_remote_datasource.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../loans/providers/loan_provider.dart';
import '../../providers/bank_provider.dart';

import '../../../../data/models/user_model.dart';

class LinkOfflineLoanDialog extends ConsumerStatefulWidget {
  final String? initialEmail;

  const LinkOfflineLoanDialog({super.key, this.initialEmail});

  static Future<void> show(BuildContext context, {String? initialEmail}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        child: LinkOfflineLoanDialog(initialEmail: initialEmail),
      ),
    );
  }

  @override
  ConsumerState<LinkOfflineLoanDialog> createState() => _LinkOfflineLoanDialogState();
}

class _LinkOfflineLoanDialogState extends ConsumerState<LinkOfflineLoanDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _loanAccountController;
  late final TextEditingController _emailController;
  final _beneficiaryNameController = TextEditingController(text: 'Ramesh Vitthal Patil');
  final _mobileController = TextEditingController(text: '9850123456');
  final _amountController = TextEditingController(text: '100000');
  final _disbursedAmountController = TextEditingController(text: '100000');
  final _purposeController = TextEditingController(text: 'Agricultural Equipment');
  final _schemeController = TextEditingController(text: 'PM-KUSUM Solar Tractor Scheme');
  final _bankController = TextEditingController(text: 'State Bank of India');
  final _branchController = TextEditingController(text: 'Pandharpur');
  final _stateController = TextEditingController(text: 'Maharashtra');
  final _districtController = TextEditingController(text: 'Solapur');
  final _talukaController = TextEditingController(text: 'Pandharpur');
  final _villageController = TextEditingController(text: 'Kavathe');

  DateTime _disbursementDate = DateTime.now();
  bool _isLoading = false;
  bool _isSearchingUser = false;
  String? _matchedUid;
  UserModel? _matchedUser;
  String? _userLookupError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: widget.initialEmail ?? 'ramesh.farmer@gmail.com',
    );
    _loanAccountController = TextEditingController(
      text: 'LN2026${Random().nextInt(8999) + 1000}',
    );
    _lookupBeneficiaryByEmail();
  }

  @override
  void dispose() {
    _loanAccountController.dispose();
    _emailController.dispose();
    _beneficiaryNameController.dispose();
    _mobileController.dispose();
    _amountController.dispose();
    _disbursedAmountController.dispose();
    _purposeController.dispose();
    _schemeController.dispose();
    _bankController.dispose();
    _branchController.dispose();
    _districtController.dispose();
    _talukaController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _lookupBeneficiaryByEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _matchedUid = null;
        _matchedUser = null;
        _userLookupError = 'Enter a registered beneficiary email.';
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
          _matchedUid = user.uid;
          _matchedUser = user;
          _userLookupError = null;
          _beneficiaryNameController.text = user.name;
          _mobileController.text = user.phone;
          if (user.state.isNotEmpty) _stateController.text = user.state;
          if (user.district.isNotEmpty) _districtController.text = user.district;
          if (user.taluka.isNotEmpty) _talukaController.text = user.taluka;
          if (user.village.isNotEmpty) _villageController.text = user.village;
        });
      } else {
        setState(() {
          _matchedUid = null;
          _matchedUser = null;
          _userLookupError = 'No registered user for "$email". Only registered emails can be assigned a loan.';
        });
      }
    } catch (e) {
      setState(() {
        _matchedUid = null;
        _matchedUser = null;
        _userLookupError = 'Verification error: $e';
      });
    } finally {
      if (mounted) setState(() => _isSearchingUser = false);
    }
  }

  Future<void> _selectDisbursementDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _disbursementDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _disbursementDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_matchedUid == null) {
      await _lookupBeneficiaryByEmail();
      if (!mounted) return;
      if (_matchedUid == null) {
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
      final currentUser = ref.read(currentUserProvider).value;
      final loanAccNo = _loanAccountController.text.trim().toUpperCase();
      final sanctionedAmount = double.parse(_amountController.text.trim());
      final disbursedAmount = double.parse(_disbursedAmountController.text.trim());
      final now = DateTime.now();

      final stateVal = _stateController.text.trim();
      final districtVal = _districtController.text.trim();
      final talukaVal = _talukaController.text.trim();
      final villageVal = _villageController.text.trim();

      final internalLoanId = 'loan_int_${loanAccNo.replaceAll(RegExp(r'\s+'), '_')}_${Random().nextInt(8999) + 1000}';

      final newLoan = LoanEntity(
        loanId: internalLoanId,
        loanAccountNumber: loanAccNo,
        beneficiaryId: _matchedUid ?? '',
        beneficiaryName: _beneficiaryNameController.text.trim(),
        beneficiaryMobile: _mobileController.text.trim(),
        beneficiaryEmail: _emailController.text.trim(),
        bankId: currentUser?.bankId ?? 'bnk_sbi_sol',
        bankManagerId: currentUser?.uid ?? 'user_bank_sbi',
        bankName: _bankController.text.trim(),
        branchName: _branchController.text.trim(),
        state: stateVal.isEmpty ? 'Maharashtra' : stateVal,
        district: districtVal.isEmpty ? 'Solapur' : districtVal,
        taluka: talukaVal.isEmpty ? 'Pandharpur' : talukaVal,
        village: villageVal.isEmpty ? 'Kavathe' : villageVal,
        schemeName: _schemeController.text.trim(),
        purpose: _purposeController.text.trim(),
        category: 'Agricultural Equipment',
        sanctionedAmount: sanctionedAmount,
        disbursedAmount: disbursedAmount,
        utilizedAmount: 0.0,
        remainingAmount: disbursedAmount,
        utilizationPercentage: 0.0,
        disbursementDate: _disbursementDate,
        expectedUtilizationDate: now.add(const Duration(days: 90)),
        status: LoanStatus.active,
        createdAt: now,
        updatedAt: now,
        isLinked: true,
      );

      await ref.read(createLoanUseCaseProvider).call(newLoan);

      ref.invalidate(allLoansProvider);
      ref.invalidate(bankLoansProvider);
      ref.invalidate(userLoansProvider);
      ref.invalidate(bankDashboardMetricsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Offline Loan "$loanAccNo" for ₹${disbursedAmount.toStringAsFixed(0)} money disbursed successfully registered & redirected to ${_matchedUser?.name ?? _emailController.text.trim()}!'),
            backgroundColor: AppColors.success,
          ),
        );
        LoanQrDialog.show(context, newLoan);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register loan: ${e.toString()}'),
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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 28),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register Offline Loan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Sanctioned offline by bank manager',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Loan Identification & Beneficiary Details
                const Text(
                  'Loan & Beneficiary Info',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
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
                          if (_matchedUid != null || _userLookupError != null) {
                            setState(() {
                              _matchedUid = null;
                              _userLookupError = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: OutlinedButton(
                        onPressed: _isSearchingUser ? null : _lookupBeneficiaryByEmail,
                        child: _isSearchingUser
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Verify'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_matchedUser != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                            SizedBox(width: 6),
                            Text('Verified Beneficiary Profile', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 12),
                        Text('• Name: ${_matchedUser!.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('• Mobile: ${_matchedUser!.phone}', style: const TextStyle(fontSize: 12)),
                        Text('• Village: ${_matchedUser!.village.isEmpty ? "N/A" : _matchedUser!.village}', style: const TextStyle(fontSize: 12)),
                        Text('• Taluka: ${_matchedUser!.taluka.isEmpty ? "N/A" : _matchedUser!.taluka}', style: const TextStyle(fontSize: 12)),
                        Text('• District: ${_matchedUser!.district.isEmpty ? "N/A" : _matchedUser!.district}', style: const TextStyle(fontSize: 12)),
                        Text('• State: ${_matchedUser!.state.isEmpty ? "N/A" : _matchedUser!.state}', style: const TextStyle(fontSize: 12)),
                        if (_matchedUser!.address.isNotEmpty)
                          Text('• Address: ${_matchedUser!.address}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else if (_userLookupError != null) ...[
                  Text(
                    _userLookupError!,
                    style: const TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                ],

                AppTextField(
                  controller: _loanAccountController,
                  label: 'Loan Account Number',
                  hint: 'e.g. LN20260001',
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) => Validators.validateRequired(v, 'Loan Account Number'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _amountController,
                        label: 'Sanctioned Amount (₹)',
                        hint: '100000',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.account_balance_rounded,
                        onChanged: (_) => setState(() {}),
                        validator: (v) => Validators.validateNumber(v, 'Sanctioned Amount'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _disbursedAmountController,
                        label: 'Money Disbursed (₹)',
                        hint: '100000',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payments_rounded,
                        onChanged: (_) => setState(() {}),
                        validator: (v) => Validators.validateNumber(v, 'Money Disbursed'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Loan Amount Redirection Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horizontal_circle_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Money Disbursed to Beneficiary Account',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₹${_disbursedAmountController.text.trim().isEmpty ? "0" : _disbursedAmountController.text.trim()} money disbursed to ${_matchedUser?.name ?? _beneficiaryNameController.text.trim()}',
                              style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _beneficiaryNameController,
                        label: 'Beneficiary Name',
                        hint: 'e.g. Rahul Patil',
                        prefixIcon: Icons.person_outline,
                        validator: (v) => Validators.validateName(v, 'Beneficiary Name'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _mobileController,
                        label: 'Mobile Number',
                        hint: '9850123456',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_android_rounded,
                        validator: (v) => Validators.validateMobile(v, 'Mobile Number'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                AppTextField(
                  controller: _purposeController,
                  label: 'Loan Purpose',
                  hint: 'e.g. Agricultural Equipment',
                  prefixIcon: Icons.precision_manufacturing_outlined,
                  validator: (v) => Validators.validateRequired(v, 'Loan Purpose'),
                ),
                const SizedBox(height: 12),

                AppTextField(
                  controller: _schemeController,
                  label: 'Scheme Name',
                  hint: 'e.g. PM-KUSUM Solar Sprayer Scheme',
                  prefixIcon: Icons.assignment_outlined,
                  validator: (v) => Validators.validateRequired(v, 'Scheme Name'),
                ),
                const SizedBox(height: 16),

                // Bank & Branch
                const Text(
                  'Bank & Branch Information',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _bankController,
                        label: 'Bank Name',
                        hint: 'State Bank of India',
                        prefixIcon: Icons.account_balance_outlined,
                        validator: (v) => Validators.validateRequired(v, 'Bank Name'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _branchController,
                        label: 'Branch',
                        hint: 'Pandharpur',
                        prefixIcon: Icons.location_city_outlined,
                        validator: (v) => Validators.validateRequired(v, 'Branch'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location Hierarchy
                const Text(
                  'Geographical Location',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _districtController,
                        label: 'District',
                        hint: 'Solapur',
                        prefixIcon: Icons.map_outlined,
                        validator: (v) => Validators.validateRequired(v, 'District'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppTextField(
                        controller: _talukaController,
                        label: 'Taluka',
                        hint: 'Pandharpur',
                        prefixIcon: Icons.explore_outlined,
                        validator: (v) => Validators.validateRequired(v, 'Taluka'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppTextField(
                        controller: _villageController,
                        label: 'Village',
                        hint: 'Kavathe',
                        prefixIcon: Icons.home_work_outlined,
                        validator: (v) => Validators.validateRequired(v, 'Village'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Disbursement Date Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Disbursement Date',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          '${_disbursementDate.day}/${_disbursementDate.month}/${_disbursementDate.year}',
                          style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: _selectDisbursementDate,
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: const Text('Change Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                AppButton(
                  text: 'Register Loan & Generate QR Token',
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
