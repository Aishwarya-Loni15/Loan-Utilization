import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';

class OfficerJurisdictionPage extends ConsumerWidget {
  const OfficerJurisdictionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Jurisdiction Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jurisdiction Summary Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        user?.name ?? 'State Officer',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'State: ${user?.state ?? "Maharashtra"}  •  District: ${user?.district ?? "Solapur"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Jurisdiction Level: District Verification Officer',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Jurisdiction Breakdown & Coverage',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _CoverageRow(
                      icon: Icons.map_outlined,
                      title: 'Assigned Talukas',
                      value: '3 Talukas (Pandharpur, Malshiras, Baramati)',
                    ),
                    const Divider(height: 24),
                    _CoverageRow(
                      icon: Icons.location_city_outlined,
                      title: 'Registered Villages',
                      value: '12 Villages Monitored',
                    ),
                    const Divider(height: 24),
                    _CoverageRow(
                      icon: Icons.account_balance_outlined,
                      title: 'Partner Bank Branches',
                      value: '8 Partner Branches',
                    ),
                    const Divider(height: 24),
                    _CoverageRow(
                      icon: Icons.currency_rupee_outlined,
                      title: 'Total District Sanctioned',
                      value: '₹1.24 Cr across 142 Active Loans',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverageRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _CoverageRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
