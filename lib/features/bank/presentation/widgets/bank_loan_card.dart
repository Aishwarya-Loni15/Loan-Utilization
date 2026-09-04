import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../domain/entities/loan.dart';
import '../../../loans/presentation/widgets/loan_progress.dart';
import '../../../loans/presentation/widgets/loan_status_chip.dart';
import '../../../../core/widgets/loan_qr_dialog.dart';

class BankLoanCardWidget extends StatelessWidget {
  final LoanEntity loan;
  final VoidCallback? onTap;

  const BankLoanCardWidget({
    super.key,
    required this.loan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loanNumber = loan.loanAccountNumber ?? loan.loanId;
    final benName = loan.beneficiaryName != null && loan.beneficiaryName!.isNotEmpty
        ? loan.beneficiaryName!
        : (loan.beneficiaryId.isNotEmpty ? loan.beneficiaryId : 'Pending Linking');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    loan.schemeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.qr_code_2_rounded, size: 22, color: AppColors.primary),
                  tooltip: 'View QR Code',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => LoanQrDialog.show(context, loan),
                ),
                const SizedBox(width: 4),
                LoanStatusChipWidget(status: loan.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Acc: $loanNumber • Beneficiary: $benName',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disbursed Capital',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      CurrencyUtils.formatINR(loan.disbursedAmount),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Utilized (Verified)',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      CurrencyUtils.formatINR(loan.utilizedAmount),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LoanProgressWidget(
              disbursedAmount: loan.disbursedAmount,
              utilizedAmount: loan.utilizedAmount,
              utilizationPercentage: loan.utilizationPercentage,
            ),
            if (onTap != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View Full Loan Details', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
