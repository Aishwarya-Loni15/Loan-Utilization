import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/features/officer/providers/officer_provider.dart';

class OfficerFilterBarWidget extends ConsumerWidget {
  const OfficerFilterBarWidget({super.key});

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const _FilterBottomSheetContent();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(officerFilterProvider);
    final notifier = ref.read(officerFilterProvider.notifier);

    return Column(
      children: [
        // Search Input & Filter Button Row
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by ID, beneficiary name, scheme...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: filters.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => notifier.setSearchQuery(''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                onChanged: (val) => notifier.setSearchQuery(val),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              icon: Badge(
                isLabelVisible: filters.hasActiveFilters,
                child: const Icon(Icons.tune_rounded),
              ),
              tooltip: 'Filter Parameters',
              onPressed: () => _showFilterBottomSheet(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Active Filter Chips Display
        if (filters.hasActiveFilters)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (filters.district != 'All')
                  _FilterChipItem(
                    label: 'District: ${filters.district}',
                    onDeleted: () => notifier.setDistrict('All'),
                  ),
                if (filters.taluka != 'All')
                  _FilterChipItem(
                    label: 'Taluka: ${filters.taluka}',
                    onDeleted: () => notifier.setTaluka('All'),
                  ),
                if (filters.village != 'All')
                  _FilterChipItem(
                    label: 'Village: ${filters.village}',
                    onDeleted: () => notifier.setVillage('All'),
                  ),
                if (filters.bank != 'All')
                  _FilterChipItem(
                    label: 'Bank: ${filters.bank}',
                    onDeleted: () => notifier.setBank('All'),
                  ),
                if (filters.loanStatus != 'All')
                  _FilterChipItem(
                    label: 'Loan Status: ${filters.loanStatus}',
                    onDeleted: () => notifier.setLoanStatus('All'),
                  ),
                if (filters.verificationStatus != 'All')
                  _FilterChipItem(
                    label: 'Verification: ${filters.verificationStatus}',
                    onDeleted: () => notifier.setVerificationStatus('All'),
                  ),
                TextButton(
                  onPressed: () => notifier.resetFilters(),
                  child: const Text('Clear All', style: TextStyle(fontSize: 12, color: AppColors.danger)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChipItem({required this.label, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onDeleted,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _FilterBottomSheetContent extends ConsumerWidget {
  const _FilterBottomSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(officerFilterProvider);
    final notifier = ref.read(officerFilterProvider.notifier);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Data Options',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextButton(
                onPressed: () {
                  notifier.resetFilters();
                  Navigator.pop(context);
                },
                child: const Text('Reset All'),
              ),
            ],
          ),
          const Divider(height: 16),

          // District Filter
          DropdownButtonFormField<String>(
            initialValue: filters.district,
            decoration: const InputDecoration(labelText: 'District Jurisdiction'),
            items: ['All', 'Solapur', 'Pune', 'Nashik']
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) => notifier.setDistrict(val ?? 'All'),
          ),
          const SizedBox(height: 12),

          // Taluka Filter
          DropdownButtonFormField<String>(
            initialValue: filters.taluka,
            decoration: const InputDecoration(labelText: 'Taluka'),
            items: ['All', 'Pandharpur', 'Malshiras', 'Baramati']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (val) => notifier.setTaluka(val ?? 'All'),
          ),
          const SizedBox(height: 12),

          // Village Filter
          DropdownButtonFormField<String>(
            initialValue: filters.village,
            decoration: const InputDecoration(labelText: 'Village'),
            items: ['All', 'Kavathe', 'Bhalwani', 'Natepute']
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (val) => notifier.setVillage(val ?? 'All'),
          ),
          const SizedBox(height: 12),

          // Bank Filter
          DropdownButtonFormField<String>(
            initialValue: filters.bank,
            decoration: const InputDecoration(labelText: 'Bank Branch'),
            items: ['All', 'State Bank of India', 'Bank of Maharashtra']
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (val) => notifier.setBank(val ?? 'All'),
          ),
          const SizedBox(height: 12),

          // Loan Status Filter
          DropdownButtonFormField<String>(
            initialValue: filters.loanStatus,
            decoration: const InputDecoration(labelText: 'Loan Status'),
            items: ['All', 'Sanctioned', 'Disbursed', 'Verified', 'Completed']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) => notifier.setLoanStatus(val ?? 'All'),
          ),
          const SizedBox(height: 12),

          // Verification Status Filter
          DropdownButtonFormField<String>(
            initialValue: filters.verificationStatus,
            decoration: const InputDecoration(labelText: 'Verification Status'),
            items: ['All', 'Pending Review', 'Approved', 'Rejected', 'High Risk']
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (val) => notifier.setVerificationStatus(val ?? 'All'),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
