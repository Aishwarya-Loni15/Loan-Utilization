import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/datasources/remote/loan_remote_datasource.dart';
import '../../../../data/datasources/remote/qr_linking_remote_datasource.dart';
import '../../../../data/models/loan_model.dart';
import '../../../../data/models/qr_linking_token_model.dart';
import '../../../../data/datasources/mock_database_service.dart';
import '../../providers/beneficiary_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../loans/providers/loan_provider.dart';

enum LinkStep {
  scanToken,
  confirmDetails,
  linkedSuccess,
}

class LinkLoanDialog extends ConsumerStatefulWidget {
  final String? initialToken;

  const LinkLoanDialog({super.key, this.initialToken});

  static Future<void> show(BuildContext context, {String? initialToken}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        child: LinkLoanDialog(initialToken: initialToken),
      ),
    );
  }

  @override
  ConsumerState<LinkLoanDialog> createState() => _LinkLoanDialogState();
}

class _LinkLoanDialogState extends ConsumerState<LinkLoanDialog> {
  final _tokenController = TextEditingController();

  LinkStep _currentStep = LinkStep.scanToken;
  bool _isLoading = false;
  QrLinkingTokenModel? _validatedToken;
  LoanModel? _foundLoan;


  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      _tokenController.text = widget.initialToken!;
      _validateToken();
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _validateToken() async {
    final tokenStr = _tokenController.text.trim().toUpperCase();
    if (tokenStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or scan a valid QR linking token.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await QrLinkingRemoteDataSource().getToken(tokenStr);
      if (token == null) {
        throw Exception('Invalid QR Token. Token not found.');
      }
      if (token.isUsed) {
        throw Exception('This QR Token has already been used.');
      }
      if (token.isExpired) {
        throw Exception('This QR Token has expired. Ask your bank manager for a fresh QR.');
      }

      final loan = await LoanRemoteDataSource().getLoanById(token.loanId);
      if (loan == null) {
        throw Exception('Associated loan details could not be retrieved.');
      }

      setState(() {
        _validatedToken = token;
        _foundLoan = loan;
        _currentStep = LinkStep.confirmDetails;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _directLinkLoan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        throw Exception('User session invalid. Please log in again.');
      }

      await QrLinkingRemoteDataSource().redeemAndLinkLoan(
        tokenId: _validatedToken!.tokenId,
        beneficiaryId: user.uid,
        beneficiaryName: user.name,
        beneficiaryMobile: user.phone,
      );

      ref.invalidate(userLoansProvider);
      ref.invalidate(allLoansProvider);
      ref.invalidate(beneficiaryMetricsProvider);

      setState(() {
        _currentStep = LinkStep.linkedSuccess;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Linking failed: $e'),
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
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Link My Loan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

              if (_currentStep == LinkStep.scanToken) ...[
                const Text(
                  'Scan Bank Manager\'s QR Code or Enter Token',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _tokenController,
                  label: 'QR Token Code',
                  hint: 'e.g. LL-TOKEN-A1B2C3D4',
                  prefixIcon: Icons.qr_code_2_rounded,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Pre-fill latest token from mock if available
                          final tokens = MockDatabaseService().qrTokens.where((t) => !t.isUsed && !t.isExpired).toList();
                          if (tokens.isNotEmpty) {
                            _tokenController.text = tokens.last.tokenId;
                          } else {
                            _tokenController.text = 'LL-TOKEN-SAMPLE';
                          }
                        },
                        icon: const Icon(Icons.paste_rounded, size: 16),
                        label: const Text('Paste Demo Token'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _validateToken,
                        icon: _isLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.search_rounded),
                        label: const Text('Validate QR'),
                      ),
                    ),
                  ],
                ),
              ],

              if (_currentStep == LinkStep.confirmDetails && _foundLoan != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            _foundLoan!.bankName ?? 'Bank Account Details',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(label: 'Loan Account:', value: _foundLoan!.loanAccountNumber ?? _foundLoan!.loanId),
                      const SizedBox(height: 6),
                      _DetailRow(label: 'Disbursed by Bank Manager:', value: '₹ ${_foundLoan!.disbursedAmount.toStringAsFixed(0)} (Static)', isBold: true),
                      const SizedBox(height: 6),
                      _DetailRow(label: 'Purpose:', value: _foundLoan!.purpose),
                      const SizedBox(height: 6),
                      _DetailRow(label: 'Bank:', value: _foundLoan!.bankName ?? 'State Bank of India'),
                      const SizedBox(height: 6),
                      _DetailRow(label: 'Branch:', value: _foundLoan!.branchName ?? 'Pandharpur'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified_user_outlined, color: AppColors.success, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Direct Link (No Authentication Required)\nClick Confirm to link this loan account directly to your profile.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep = LinkStep.scanToken),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _directLinkLoan,
                        icon: _isLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Confirm & Link Loan'),
                      ),
                    ),
                  ],
                ),
              ],

              if (_currentStep == LinkStep.linkedSuccess) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.success,
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Loan Successfully Linked! 🎉',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Loan Account "${_foundLoan?.loanAccountNumber ?? _foundLoan?.loanId}" is now permanently connected to your Laon Utilization account.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Verified Relationship Path:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '🏦 Bank Manager  ➔  💰 Loan (${'LN20260001'})  ➔  👤 Beneficiary',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Return to Dashboard'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
              color: isBold ? AppColors.success : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
