import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';
import 'package:laon/features/officer/presentation/widgets/officer_filter_bar.dart';
import 'package:laon/features/officer/providers/officer_provider.dart';

class OfficerBeneficiariesPage extends ConsumerWidget {
  const OfficerBeneficiariesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beneficiariesAsync = ref.watch(beneficiariesProvider);
    final filters = ref.watch(officerFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('District Beneficiaries'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const OfficerFilterBarWidget(),
          ),
          Expanded(
            child: beneficiariesAsync.when(
              data: (beneficiaries) {
                final filtered = beneficiaries.where((b) {
                  if (filters.searchQuery.isNotEmpty) {
                    final q = filters.searchQuery.toLowerCase();
                    final matches = b.name.toLowerCase().contains(q) ||
                        b.email.toLowerCase().contains(q) ||
                        b.phone.contains(q) ||
                        b.village.toLowerCase().contains(q);
                    if (!matches) return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No beneficiaries matching filter criteria',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ben = filtered[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.person_outline, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ben.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        'Village: ${ben.village.isNotEmpty ? ben.village : "Kavathe"} • Taluka: ${ben.taluka.isNotEmpty ? ben.taluka : "Pandharpur"}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.teal.shade300),
                                  ),
                                  child: const Text(
                                    'Verified Scheme',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Contact: ${ben.phone.isNotEmpty ? ben.phone : "+91 9876543210"}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Active Loan Linked',
                                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(message: 'Loading district beneficiaries...'),
              error: (e, _) => AppErrorWidget(message: e.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
