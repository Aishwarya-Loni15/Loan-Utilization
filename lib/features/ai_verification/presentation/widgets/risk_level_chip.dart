import 'package:flutter/material.dart';
import '../../../../core/enums/risk_level.dart';
import '../../../../core/widgets/status_chip.dart';

class RiskLevelChipWidget extends StatelessWidget {
  final RiskLevel riskLevel;

  const RiskLevelChipWidget({super.key, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    return RiskLevelChip(level: riskLevel);
  }
}
