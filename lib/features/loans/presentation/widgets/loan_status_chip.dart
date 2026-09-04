import 'package:flutter/material.dart';
import '../../../../core/enums/loan_status.dart';
import '../../../../core/widgets/status_chip.dart';

class LoanStatusChipWidget extends StatelessWidget {
  final LoanStatus status;

  const LoanStatusChipWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return LoanStatusChip(status: status);
  }
}
