import 'package:flutter/material.dart';
import 'package:laon/core/utils/currency_utils.dart';
import 'package:laon/core/widgets/app_card.dart';
import 'package:laon/domain/entities/loan.dart';
import 'package:laon/features/locations/presentation/widgets/geographical_hierarchy_badge.dart';
import 'loan_progress.dart';
import 'loan_status_chip.dart';

class LoanCard extends StatelessWidget {
  final LoanEntity loan;
  final VoidCallback? onTap;

  const LoanCard({
    super.key,
    required this.loan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
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
              LoanStatusChipWidget(status: loan.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Purpose: ${loan.purpose}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          GeographicalHierarchyBadge(
            state: loan.state,
            district: loan.district,
            taluka: loan.taluka,
            village: loan.village,
            compact: true,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sanctioned Amount',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    CurrencyUtils.formatINR(loan.sanctionedAmount),
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
                    'Disbursed Amount',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    CurrencyUtils.formatINR(loan.disbursedAmount),
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
        ],
      ),
    );
  }
}
